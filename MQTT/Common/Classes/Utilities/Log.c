#include "Log.h"            // Header
#include "MQTTPacket.h"
#include "MQTTProtocol.h"
#include "MQTTProtocolClient.h"
#include "Messages.h"
#include "LinkedList.h"
#include "StackTrace.h"
#include "Thread.h"

#include <stdio.h>          // C Standard
#include <stdlib.h>         // C Standard
#include <stdarg.h>         // C Standard
#include <time.h>           // C Standard
#include <string.h>         // C Standard

#include <syslog.h>         // POSIX
#include <sys/stat.h>       // POSIX
#define GETTIMEOFDAY 1

#if defined(GETTIMEOFDAY)
	#include <sys/time.h>   // POSIX
#else
	#include <sys/timeb.h>  // POSIX
#endif


// _unlink mapping for linux
#define _unlink unlink

#if !defined(min)
    #define min(A,B) ( (A) < (B) ? (A):(B))
#endif

#pragma mark - Definitions

#define MAX_FUNCTION_NAME_LENGTH 256

typedef struct
{
#if defined(GETTIMEOFDAY)
	struct timeval ts;
#else
	struct timeb ts;
#endif
	int sametime_count;
	int number;
	int thread_id;
	int depth;
	char name[MAX_FUNCTION_NAME_LENGTH + 1];
	int line;
	int has_rc;
	int rc;
	int level;
} traceEntry;

#pragma mark - Variables

trace_settings_type trace_settings = { TRACE_MINIMUM, 400, -1 };

static int start_index = -1;
static int next_index = 0;
static traceEntry* trace_queue = NULL;
static int trace_queue_size = 0;

static FILE* trace_destination = NULL;      // Flag to indicate if trace is to be sent to a stream
static char* trace_destination_name = NULL; // The name of the trace file
static char* trace_destination_backup_name = NULL; // The name of the backup trace file
static int lines_written = 0;               // Number of lines written to the current output file
static int max_lines_per_file = 1000;       // Maximum number of lines to write to one trace file
static int trace_output_level = -1;
static Log_traceCallback* trace_callback = NULL;

static int sametime_count = 0;
#if defined(GETTIMEOFDAY)
struct timeval ts, last_ts;
#else
struct timeb ts, last_ts;
#endif
static char msg_buf[512];

static pthread_mutex_t log_mutex_store = PTHREAD_MUTEX_INITIALIZER;
static mutex_type log_mutex = &log_mutex_store;

#pragma mark - Private prototypes

static void Log_output(int log_level, char* msg);
static char* Log_formatTraceEntry(traceEntry* cur_entry);
static traceEntry* Log_pretrace();
static void Log_trace(int log_level, char* buf);
static void Log_posttrace(int log_level, traceEntry* cur_entry);
FILE* Log_destToFile(char* dest);

#pragma mark - Public API

int Log_initialize(Log_nameValue* info)
{
	int rc = -1;
	char* envval = NULL;

    if ((trace_queue = malloc(sizeof(traceEntry) * trace_settings.max_trace_entries)) == NULL) { return rc; }
	trace_queue_size = trace_settings.max_trace_entries;

	if ((envval = getenv("MQTT_C_CLIENT_TRACE")) != NULL && strlen(envval) > 0)
	{
		if (strcmp(envval, "ON") == 0 || (trace_destination = fopen(envval, "w")) == NULL)
			trace_destination = stdout;
		else
		{
			trace_destination_name = malloc(strlen(envval) + 1);
			strcpy(trace_destination_name, envval);
			trace_destination_backup_name = malloc(strlen(envval) + 3);
			sprintf(trace_destination_backup_name, "%s.0", trace_destination_name);
		}
	}
	if ((envval = getenv("MQTT_C_CLIENT_TRACE_MAX_LINES")) != NULL && strlen(envval) > 0)
	{
		max_lines_per_file = atoi(envval);
		if (max_lines_per_file <= 0)
			max_lines_per_file = 1000;
	}
	if ((envval = getenv("MQTT_C_CLIENT_TRACE_LEVEL")) != NULL && strlen(envval) > 0)
	{
		if (strcmp(envval, "MAXIMUM") == 0 || strcmp(envval, "TRACE_MAXIMUM") == 0)
			trace_settings.trace_level = TRACE_MAXIMUM;
		else if (strcmp(envval, "MEDIUM") == 0 || strcmp(envval, "TRACE_MEDIUM") == 0)
			trace_settings.trace_level = TRACE_MEDIUM;
		else if (strcmp(envval, "MINIMUM") == 0 || strcmp(envval, "TRACE_MEDIUM") == 0)
			trace_settings.trace_level = TRACE_MINIMUM;
		else if (strcmp(envval, "PROTOCOL") == 0  || strcmp(envval, "TRACE_PROTOCOL") == 0)
			trace_output_level = TRACE_PROTOCOL;
		else if (strcmp(envval, "ERROR") == 0  || strcmp(envval, "TRACE_ERROR") == 0)
			trace_output_level = LOG_ERROR;
	}
	Log_output(TRACE_MINIMUM, "=========================================================");
	Log_output(TRACE_MINIMUM, "                   Trace Output");
	if (info)
	{
		while (info->name)
		{
			snprintf(msg_buf, sizeof(msg_buf), "%s: %s", info->name, info->value);
			Log_output(TRACE_MINIMUM, msg_buf);
			info++;
		}
	}

	struct stat buf;
	if (stat("/proc/version", &buf) != -1)
	{
		FILE* vfile = fopen("/proc/version", "r");
		if (vfile != NULL)
		{
			strcpy(msg_buf, "/proc/version: ");
			size_t const len = strlen(msg_buf);
            if ( fgets(&msg_buf[len], (int)(sizeof(msg_buf)-len), vfile) ) { Log_output(TRACE_MINIMUM, msg_buf); }
			fclose(vfile);
		}
	}

	Log_output(TRACE_MINIMUM, "=========================================================");

	return rc;
}

void Log(int log_level, int msgno, char const* format, ...)
{
    if (log_level >= trace_settings.trace_level)
    {
        char* temp = NULL;
        static char msg_buf[512];
        va_list args;
        
        /* we're using a static character buffer, so we need to make sure only one thread uses it at a time */
        Thread_lock_mutex(log_mutex);
        if (format == NULL && (temp = Messages_get(msgno, log_level)) != NULL)
            format = temp;
        
        va_start(args, format);
        vsnprintf(msg_buf, sizeof(msg_buf), format, args);
        
        Log_trace(log_level, msg_buf);
        va_end(args);
        Thread_unlock_mutex(log_mutex);
    }
    
    /*if (log_level >= LOG_ERROR)
     {
     char* filename = NULL;
     Log_recordFFDC(&msg_buf[7]);
     } */
}

void Log_stackTrace(int log_level, int msgno, int thread_id, int current_depth, const char* name, int line, int const* restrict rc)
{
    traceEntry* cur_entry = NULL;
    
    if (trace_queue == NULL) { return; }
    if (log_level < trace_settings.trace_level) { return; }
    
    Thread_lock_mutex(log_mutex);
    cur_entry = Log_pretrace();
    
    memcpy(&(cur_entry->ts), &ts, sizeof(ts));
    cur_entry->sametime_count = sametime_count;
    cur_entry->number = msgno;
    cur_entry->thread_id = thread_id;
    cur_entry->depth = current_depth;
    strcpy(cur_entry->name, name);
    cur_entry->level = log_level;
    cur_entry->line = line;
    if (rc == NULL)
    {
        cur_entry->has_rc = 0;
    }
    else
    {
        cur_entry->has_rc = 1;
        cur_entry->rc = *rc;
    }
    
    Log_posttrace(log_level, cur_entry);
    Thread_unlock_mutex(log_mutex);
}

void Log_setTraceCallback(Log_traceCallback* callback)
{
	trace_callback = callback;
}

void Log_setTraceLevel(enum LOG_LEVELS level)
{
	if (level < TRACE_MINIMUM) /* the lowest we can go is TRACE_MINIMUM*/
		trace_settings.trace_level = level;
	trace_output_level = level;
}

void Log_terminate()
{
    free(trace_queue);
    trace_queue = NULL;
    trace_queue_size = 0;
    if (trace_destination)
    {
        if (trace_destination != stdout)
            fclose(trace_destination);
        trace_destination = NULL;
    }
    if (trace_destination_name)
        free(trace_destination_name);
    if (trace_destination_backup_name)
        free(trace_destination_backup_name);
    start_index = -1;
    next_index = 0;
    trace_output_level = -1;
    sametime_count = 0;
}

#pragma mark - Private functionality

static void Log_output(int log_level, char* msg)
{
	if (trace_destination)
	{
		fprintf(trace_destination, "%s\n", msg);

		if (trace_destination != stdout && ++lines_written >= max_lines_per_file)
		{

			fclose(trace_destination);
			_unlink(trace_destination_backup_name); /* remove any old backup trace file */
			rename(trace_destination_name, trace_destination_backup_name); /* rename recently closed to backup */
			trace_destination = fopen(trace_destination_name, "w"); /* open new trace file */
			if (trace_destination == NULL)
				trace_destination = stdout;
			lines_written = 0;
		}
		else
			fflush(trace_destination);
	}

	if (trace_callback)
		(*trace_callback)(log_level, msg);
}

static char* Log_formatTraceEntry(traceEntry* cur_entry)
{
    struct tm *timeinfo;
    int buf_pos = 31;
    
    #if defined(GETTIMEOFDAY)
    timeinfo = localtime(&cur_entry->ts.tv_sec);
    #else
    timeinfo = localtime(&cur_entry->ts.time);
    #endif
    strftime(&msg_buf[7], 80, "%Y%m%d %H%M%S ", timeinfo);
    #if defined(GETTIMEOFDAY)
    sprintf(&msg_buf[22], ".%.3lu ", cur_entry->ts.tv_usec / 1000L);
    #else
    sprintf(&msg_buf[22], ".%.3hu ", cur_entry->ts.millitm);
    #endif
    buf_pos = 27;
    
    sprintf(msg_buf, "(%.4d)", cur_entry->sametime_count);
    msg_buf[6] = ' ';
    
    if (cur_entry->has_rc == 2)
        strncpy(&msg_buf[buf_pos], cur_entry->name, sizeof(msg_buf)-buf_pos);
    else
    {
        char* format = Messages_get(cur_entry->number, cur_entry->level);
        if (cur_entry->has_rc == 1)
            snprintf(&msg_buf[buf_pos], sizeof(msg_buf)-buf_pos, format, cur_entry->thread_id,
                     cur_entry->depth, "", cur_entry->depth, cur_entry->name, cur_entry->line, cur_entry->rc);
        else
            snprintf(&msg_buf[buf_pos], sizeof(msg_buf)-buf_pos, format, cur_entry->thread_id,
                     cur_entry->depth, "", cur_entry->depth, cur_entry->name, cur_entry->line);
    }
    return msg_buf;
}

static traceEntry* Log_pretrace()
{
    traceEntry *cur_entry = NULL;
    
    /* calling ftime/gettimeofday seems to be comparatively expensive, so we need to limit its use */
    if (++sametime_count % 20 == 0)
    {
        #if defined(GETTIMEOFDAY)
        gettimeofday(&ts, NULL);
        if (ts.tv_sec != last_ts.tv_sec || ts.tv_usec != last_ts.tv_usec)
        #else
            ftime(&ts);
        if (ts.time != last_ts.time || ts.millitm != last_ts.millitm)
        #endif
        {
            sametime_count = 0;
            last_ts = ts;
        }
    }
    
    if (trace_queue_size != trace_settings.max_trace_entries)
    {
        traceEntry* new_trace_queue = malloc(sizeof(traceEntry) * trace_settings.max_trace_entries);
        
        memcpy(new_trace_queue, trace_queue, min(trace_queue_size, trace_settings.max_trace_entries) * sizeof(traceEntry));
        free(trace_queue);
        trace_queue = new_trace_queue;
        trace_queue_size = trace_settings.max_trace_entries;
        
        if (start_index > trace_settings.max_trace_entries + 1 ||
            next_index > trace_settings.max_trace_entries + 1)
        {
            start_index = -1;
            next_index = 0;
        }
    }
    
    /* add to trace buffer */
    cur_entry = &trace_queue[next_index];
    if (next_index == start_index) /* means the buffer is full */
    {
        if (++start_index == trace_settings.max_trace_entries)
            start_index = 0;
    } else if (start_index == -1)
        start_index = 0;
    if (++next_index == trace_settings.max_trace_entries)
        next_index = 0;
    
    return cur_entry;
}

static void Log_trace(int log_level, char* buf)
{
	traceEntry *cur_entry = NULL;

	if (trace_queue == NULL)
		return;

	cur_entry = Log_pretrace();

	memcpy(&(cur_entry->ts), &ts, sizeof(ts));
	cur_entry->sametime_count = sametime_count;

	cur_entry->has_rc = 2;
	strncpy(cur_entry->name, buf, sizeof(cur_entry->name));
	cur_entry->name[MAX_FUNCTION_NAME_LENGTH] = '\0';

	Log_posttrace(log_level, cur_entry);
}

static void Log_posttrace(int log_level, traceEntry* cur_entry)
{
    if (((trace_output_level == -1) ? log_level >= trace_settings.trace_level : log_level >= trace_output_level))
    {
        char* msg = NULL;
        
        if (trace_destination || trace_callback)
            msg = &Log_formatTraceEntry(cur_entry)[7];
        
        Log_output(log_level, msg);
    }
}

FILE* Log_destToFile(char* dest)
{
	FILE* file = NULL;

	if (strcmp(dest, "stdout") == 0)
		file = stdout;
	else if (strcmp(dest, "stderr") == 0)
		file = stderr;
	else
	{
		if (strstr(dest, "FFDC"))
			file = fopen(dest, "ab");
		else
			file = fopen(dest, "wb");
	}
	return file;
}


int Log_compareEntries(char* entry1, char* entry2)
{
	int comp = strncmp(&entry1[7], &entry2[7], 19);
    if (comp == 0) { comp = strncmp(&entry1[1], &entry2[1], 4); }   // If timestamps are equal, use the sequence numbers
	return comp;
}
