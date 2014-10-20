#pragma once

enum LOG_LEVELS {
	TRACE_MAXIMUM = 1,
	TRACE_MEDIUM,
	TRACE_MINIMUM,
	TRACE_PROTOCOL,
	LOG_ERROR,
	LOG_SEVERE,
	LOG_FATAL,
} Log_levels;

typedef struct
{
	int trace_level;			/**< trace level */
	int max_trace_entries;		/**< max no of entries in the trace buffer */
	int trace_output_level;		/**< trace level to output to destination */
} trace_settings_type;

extern trace_settings_type trace_settings;

#define LOG_PROTOCOL TRACE_PROTOCOL
#define TRACE_MAX TRACE_MAXIMUM
#define TRACE_MIN TRACE_MINIMUM
#define TRACE_MED TRACE_MEDIUM

typedef struct
{
	const char* name;
	const char* value;
} Log_nameValue;

int Log_initialize(Log_nameValue*);
void Log_terminate();

void Log(int, int, char *, ...);
void Log_stackTrace(int, int, int, int, const char*, int, int const* restrict);

typedef void Log_traceCallback(enum LOG_LEVELS level, char* message);
void Log_setTraceCallback(Log_traceCallback* callback);
void Log_setTraceLevel(enum LOG_LEVELS level);
