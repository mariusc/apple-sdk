#include "utf-8.h"      // Header
#include <string.h>     // C Standard
#include "StackTrace.h" // MQTT (Utilities)

// Macro to determine the number of elements in a single-dimension array
#if !defined(ARRAY_SIZE)
    #define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))
#endif

#pragma mark - Private prototypes

char const* UTF8_char_validate(size_t const len, char const* restrict data) __attribute__((pure));

#pragma mark - Public API

bool UTF8_validate(size_t const len, char const* restrict data)
{
	int isValid = false;

	FUNC_ENTRY;
	if (len == 0)
	{
		isValid = true;
		goto exit;
	}
    
	char const* curdata = UTF8_char_validate(len, data);
    while (curdata && (curdata < data + len))
    {
        curdata = UTF8_char_validate(len, curdata);
    }

	isValid = (curdata != NULL);
    
exit:
	FUNC_EXIT_RC(isValid);
	return isValid;
}

bool UTF8_validateString(char const* restrict string)
{
	FUNC_ENTRY;
	int const rc = UTF8_validate(strlen(string), string);
	FUNC_EXIT_RC(rc);
	return rc;
}

#pragma mark - Private functionality

/*!
 *  @abstract Structure to hold the valid ranges of UTF-8 characters, for each byte up to 4.
 */
struct utf8_validRanges
{
    int len;        // Number of elements in the following array (1 to 4).
    struct {
        char lower; // Lower limit of valid range.
        char upper; // Upper limit of valid range */
    } bytes[4];     // Up to 4 bytes can be used per character */
};

static struct utf8_validRanges const valid_ranges[] = {
    {1, { {00, 0x7F} } },
    {2, { {0xC2, 0xDF}, {0x80, 0xBF} } },
    {3, { {0xE0, 0xE0}, {0xA0, 0xBF}, {0x80, 0xBF} } },
    {3, { {0xE1, 0xEC}, {0x80, 0xBF}, {0x80, 0xBF} } },
    {3, { {0xED, 0xED}, {0x80, 0x9F}, {0x80, 0xBF} } },
    {3, { {0xEE, 0xEF}, {0x80, 0xBF}, {0x80, 0xBF} } },
    {4, { {0xF0, 0xF0}, {0x90, 0xBF}, {0x80, 0xBF}, {0x80, 0xBF} } },
    {4, { {0xF1, 0xF3}, {0x80, 0xBF}, {0x80, 0xBF}, {0x80, 0xBF} } },
    {4, { {0xF4, 0xF4}, {0x80, 0x8F}, {0x80, 0xBF}, {0x80, 0xBF} } },
};

/*!
 * @abstract Validate a single UTF-8 character.
 *
 * @param len The length of the string in "data".
 * @param data The bytes to check for a valid UTF-8 char.
 * @return Pointer to the start of the next UTF-8 character in "data".
 */
char const* UTF8_char_validate(size_t const len, char const* restrict data)
{
    char const* rc = NULL;
    
    FUNC_ENTRY;
    // First work out how many bytes this char is encoded in.
    int const charlen = ((data[0] & 128) == 0) ? 1 :
                        ((data[0] & 0xF0) == 0xF0) ? 4 :
                        ((data[0] & 0xE0) == 0xE0) ? 3 : 2;
    
    // Not enough characters in the string we were given
    if (charlen > len) { goto exit; }
    
    int good = 0;
    for (int i = 0; i < ARRAY_SIZE(valid_ranges); ++i)
    {   // Just has to match one of these rows.
        if (valid_ranges[i].len == charlen)
        {
            good = 1;
            for (int j = 0; j < charlen; ++j)
            {
                if ( data[j] < valid_ranges[i].bytes[j].lower ||
                     data[j] > valid_ranges[i].bytes[j].upper )
                {
                    good = 0;   // failed the check
                    break;
                }
            }
            if (good) { break; }
        }
    }
    
    if (good) { rc = data + charlen; }
    
exit:
    FUNC_EXIT;
    return rc;
}
