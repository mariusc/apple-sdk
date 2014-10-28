/*!
 *  @abstract Functions for checking that strings contain UTF-8 characters only
 *  @discussion See page 104 of the Unicode Standard 5.0 for the list of well formed UTF-8 byte sequences.
 */
#pragma once

#include <stdbool.h>    // C Standard
#include <stdlib.h>     // C Standard

/*!
 *  @abstract Validate a length-delimited string has only UTF-8 characters.
 *
 *  @param len the length of the string in "data"
 *  @param data the bytes to check for valid UTF-8 characters
 *  @return 1 (true) if the string has only UTF-8 characters, 0 (false) otherwise
 */
bool UTF8_validate(size_t const len, char const* restrict data);

/*!
 *  @abstract Validate a null-terminated string has only UTF-8 characters.
 *
 *  @param string the string to check for valid UTF-8 characters.
 *  @return 1 (true) if the string has only UTF-8 characters, 0 (false) otherwise.
 */
bool UTF8_validateString(char const* restrict string);
