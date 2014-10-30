#pragma once

#include "CDebug.h"     // CBasics (Utilities)

#include <stdio.h>      // C Standard
#include <stdlib.h>     // C Standard
#include <string.h>     // C Standard

#pragma mark - Main functions

// This macro will call name(), which will return a char* type. The string returned will be NULL if the test succeded, or it will contain an error message.
// If name() contained several mu_run_test() and any failed, name() will stop executing and return the message immediately, without being able to run the other tests that haven't been run.
#define TEST_MAIN(test_name)                    \
unsigned int test_level;                        \
int main(int argc, char const* argv[])          \
{                                               \
    printf("\n------------------------------------------\nRUNNING: %s()\n------------------------------------------\n", #test_name);\
                                                \
    test_level = 0;                             \
                                                \
    if (test_name()) {                          \
        printf("\n\nALL TESTS PASSED!\n\n");    \
    } else {                                    \
        printf("\n\n[ERROR] TEST FAILED\n\n\n");\
        exit(1);                                \
    }                                           \
}

#define TEST_INITIALIZE()                       \
    extern unsigned int test_level;             \
    char* test_str = NULL;                      \
    unsigned int test_num_run = 0;              \
    {                                                       \
        if (test_level == 0)                                \
        {                                                   \
            test_str = malloc(sizeof(char)*3);              \
            if (likely(test_str != NULL)) { test_str[0] = ' '; test_str[1] = 'T'; test_str[2] = '\0'; }  \
        } else {                                            \
            unsigned int amount_white_spaces = 1 + 3*test_level; \
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
    }                                                       \
    ++test_level

#define TEST_FINALIZE()                         \
    --test_level;                               \
    free(test_str);                             \
    return true

// This macro will call test(), which will return a char* type. The string returned will be NULL if the test succeded, or it will contain an error message.
#define TEST_RUN(test, ...) \
    printf("%sest %u: %s\n", test_str, ++test_num_run, #test); \
    if ( unlikely(!test(__VA_ARGS__)) ) return false

// This method checks whether an assertion is true. If it is not, it returns a custom error message
#define TEST_ASSERT(assert_expression, msg)     \
    if ( unlikely(!(assert_expression)) )       \
    {                                           \
        log_err("\n" msg);                           \
        return false;                           \
    }
