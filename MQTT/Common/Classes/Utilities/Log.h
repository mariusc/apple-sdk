/*!
 *  @abstract Logging and tracing module.
 */
#pragma once

#pragma mark Definitions

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
	int trace_level;			// Trace level.
	int max_trace_entries;		// Max no of entries in the trace buffer.
	int trace_output_level;		// Trace level to output to destination.
} trace_settings_type;

#define LOG_PROTOCOL TRACE_PROTOCOL
#define TRACE_MAX TRACE_MAXIMUM
#define TRACE_MIN TRACE_MINIMUM
#define TRACE_MED TRACE_MEDIUM

typedef struct
{
    const char* name;
    const char* value;
} Log_nameValue;

#pragma mark Variables

extern trace_settings_type trace_settings;

#pragma mark Public API


int Log_initialize(Log_nameValue*);

/*!
 *  @abstract Log a message.  If possible, all messages should be indexed by message number, and the use of the format string should be minimized or negated altogether.  If format is provided, the message number is only used as a message label.
 *
 *  @param log_level the log level of the message.
 *  @param msgno the id of the message to use if the format string is NULL.
 *  @param format the printf format string to be used if the message id does not exist.
 *  @param ... the printf inserts.
 */
void Log(int, int, char const*, ...);

/*!
 *  @abstract The reason for this function is to make trace logging as fast as possible so that the function exit/entry history can be captured by default without unduly impacting performance.  Therefore it must do as little as possible.
 *
 *  @param log_level the log level of the message
 *  @param msgno the id of the message to use if the format string is NULL
 *  @param aFormat the printf format string to be used if the message id does not exist
 *  @param ... the printf inserts
 */
void Log_stackTrace(int, int, int, int, const char*, int, int const* restrict);

typedef void Log_traceCallback(enum LOG_LEVELS level, char* message);

void Log_setTraceCallback(Log_traceCallback* callback);

void Log_setTraceLevel(enum LOG_LEVELS level);

void Log_terminate();
