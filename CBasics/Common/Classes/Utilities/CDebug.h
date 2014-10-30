#pragma once

#include <errno.h>      // C Standard
#include <stdio.h>      // C Standard
#include <string.h>     // C Standard

#pragma mark - Debug logging macros

// If we are NOT in debug mode, the the debug() macros will be replaced by empty spaces.
#if defined(NDEBUG)
    #define debug(msj, ...)
#else
    #define debug(msj, ...)     fprintf(stderr, "[DEBUG] %s:%d\n  |---- " msj "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#endif

#pragma mark - Error/Warning/Info logging only macros

#define clean_errno()           (errno == 0 ? "None" : strerror(errno))
#define log_err(msj, ...)       fprintf(stderr, "[ERROR] %s:%d\n  |---- errno: %s\n   |---- " msj "\n", __FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
#define log_warn(msj, ...)      fprintf(stderr, "[WARN] %s:%d\n   |---- errno: %s\n   |---- " msj "\n", __FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
#define log_info(msj, ...)      fprintf(stderr, "[INFO] %s:%d\n   |----  " msj "\n", __FILE__, __LINE__, ##__VA_ARGS__)

#pragma mark - Verification macros (with debug/messaging options)

#define verify_dbg(assertion, goto_label, msj, ...)     if ( unlikely(!(assertion)) ) { debug(msj, ##__VA_ARGS__);  goto goto_label; }
#define verify_err(assertion, goto_label, msj, ...)     if ( unlikely(!(assertion)) ) { log_err(msj, ##__VA_ARGS__);  errno=0;  goto goto_label; }
#define verify_warn(assertion, goto_label, msj, ...)    if ( unlikely(!(assertion)) ) { log_warn(msj, ##__VA_ARGS__); errno=0;  goto goto_label; }
#define verify_info(assertion, goto_label, msj, ...)    if ( unlikely(!(assertion)) ) { log_info(msj, ##__VA_ARGS__); errno=0;  goto goto_label; }

// It is placed in any part of a function that shouldn't run, and if it does, it prints an error message then jumps to the error: label. You put this in if-statements and switch-statements to catch conditions that shouldn't happen.
#define sentinel(msj, ...)      { log_err(msj, ##__VA_ARGS__); errno=0; goto error; }
