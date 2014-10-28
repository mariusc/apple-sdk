/*!
 *  @abstract Trace messages.
 */
#pragma once

/*!
 *  @abstract Get a log message by its index.
 *
 *  @param index The integer index.
 *  @param log_level The log level, used to determine which message list to use.
 *  @return The message format string.
 */
char* Messages_get(int, int);
