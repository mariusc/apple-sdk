#pragma once

#include "CDebug.h"     // CBasics (Utilities)
#include "CMacros.h"    // CBasics (Utilities)

#include <stdio.h>      // C Standard
#include <stdlib.h>     // C Standard
#include <string.h>     // C Standard
#include <stdbool.h>    // C Standard

#pragma mark - Main functions

/*!
 *  @abstract This macro represents the <code>main</code> function of the test file.
 *  @discussion The macro will initialize the test command-line program and execute the function name passed as an argument.
 *
 *  @param test_name The function to execute as the main function for the test.
 *  @return It returns an integer as any <code>main</code> C function.
 */
#define TEST_MAIN(test_name)                    \
unsigned int cbasics_testLevel;                 \
int main(int argc, char const* argv[])          \
{                                               \
    printf("\n------------------------------------------\nRUNNING: %s()\n------------------------------------------\n", #test_name);\
                                                \
    cbasics_testLevel = 0;                      \
                                                \
    if (test_name()) {                          \
        printf("\n\nALL TESTS PASSED!\n\n");    \
    } else {                                    \
        printf("\n\n[ERROR] TEST FAILED\n\n\n");\
        exit(1);                                \
    }                                           \
}

/*!
 *  @abstract It initialises the top function on a test C file.
 *  @discussion A call to this macro must be paired in the same scope by a call to <code>TEST_FINALIZE</code> macro.
 */
#define TEST_INITIALIZE()                       \
    extern unsigned int cbasics_testLevel;      \
    char* test_str = NULL;                      \
    unsigned int test_num_run = 0;              \
    {                                           \
        if (cbasics_testLevel++ == 0)           \
        {                                       \
            test_str = malloc( 3*sizeof(char) );\
            if (likely(test_str != NULL))       \
            {                                   \
                test_str[0] = ' ';              \
                test_str[1] = 'T';              \
                test_str[2] = '\0';             \
            }                                   \
        }                                       \
        else                                    \
        {                                       \
            unsigned int amount_white_spaces = 1 + 3*cbasics_testLevel;                     \
            char symbols[] = "|--- Subt";                   \
            unsigned int amount_symbols = sizeof(symbols) / sizeof(symbols[0]);             \
            test_str = malloc(sizeof(char) * (amount_white_spaces + amount_symbols));       \
            if (likely(test_str != NULL))                   \
            {                                               \
                char const empty = ' ';                     \
                for (unsigned int i=0; i<amount_white_spaces; ++i) { test_str[i] = empty; } \
                test_str[amount_white_spaces] = '\0';       \
                strcat(test_str, symbols);                  \
            }                                               \
        }                                                   \
    }

/*!
 *  @abstract It cleans up the variables initialised by <code>TEST_INITIALIZE</code> macro.
 */
#define TEST_FINALIZE()                         \
    --cbasics_testLevel;                        \
    free(test_str);                             \
    return true

/*!
 *  @abstract It runs a test function.
 */
#define TEST_RUN(test, ...) \
    printf("%sest %u: %s\n", test_str, ++test_num_run, #test); \
    if ( unlikely(!test(__VA_ARGS__)) ) return false

/*!
 *  @abstract This macro checks whether an assertion is true. If it is not, it returns a custom error message
 */
#define TEST_ASSERT(assert_expression, msg)     \
    if ( unlikely(!(assert_expression)) )       \
    {                                           \
        log_err("\n" msg);                      \
        return false;                           \
    }
