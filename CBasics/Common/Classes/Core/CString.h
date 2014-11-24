#pragma once

#include "CCore.h"      // CBasics (Core)
#include <string.h>     // C Standard

#pragma mark - CString

/*!
 *  @abstract Structure holding the character counter (without taking in count '\0') and a pointer to the char buffer (with the '\0').
 *
 *  @field length The number of <code>char</code>s in the <code>chars</code> buffer, not including the Null character ('\0').
 *  @field chars Pointer to a space of memory containing a <code>char</code> array (with the '\0' character).
 */
struct CString
{
    size_t length;
    char* chars;
};

/*!
 *  @abstract This macro is replaced with <code>struct CString</code> compound literal with the specific length and pointer to <code>char</code> buffer.
 */
#define cstring(count, characters)  ((struct CString){.length=count, .chars=characters})

/*!
 *  @abstract It replaces this macro with the <code>struct CString</code> compound literal containing the calculated length and the value pointing to the <code>char</code> buffer.
 */
#define cstring_unsafe(characters)  ((struct CString){.length=strlen(characters), .chars=characters})

/*!
 *  @abstract It deeply copies the <code>cstringToCopy</code> to <code>cstringResult</code>.
 *  @discussion Deeply copied means changing the <code>length</code> value and memcopying the character buffer. Don't forget to release it later.
 */
#define cstring_copy(cstringResult, cstringToCopy)                  \
    do {                                                            \
        size_t const length = cstringToCopy.length;                 \
        cstringResult.length = length;                              \
        memcpy(cstringResult.chars, cstringToCopy.chars, length);   \
    } while(0)

/*!
 *  @abstract It allocates space enoug for a <code>struct CString</code>.
 *
 *  @return A pointer to an initialised <code>struct CString</code> or <code>NULL</code>.
 */
#define cstring_malloc()    malloc(sizeof(struct CString))

/*!
 *  @abstract It duplicates a full <code>struct CString</code>.
 *
 *  @return It returns an allocated pointer to the duplicated <code>struct CString</code>.
 */
#define cstring_duplicate(cstringPtrToCopy)    memcpy(NULL, cstringPtrToCopy, sizeof(*cstringPtrToCopy))

// TODO: Append, preppend, tokenizer

#pragma mark - CObjString

/*!
 *  @abstract Structure holding an C object representing a string and an identifying and retain-counting system.
 *
 *  @field core Structure identifying the object and containing a retain count mechanism.
 *  @field string <code>struct CString</code> representing the actual C string (chars and length).
 */
struct CObjString
{
    struct CCore core;
    struct CString string;
};

/*!
 *  @abstract It allocates space in the heap for a <code>CObjString</code> and bump the retain count to one.
 *  @discussion The <code>CString</code> is initialised with <code>length</code> zero and <code>chars</code> <code>NULL</code>.
 */
struct CObjString* cobjstring_malloc();

/*!
 *  @abstract It allocates space in the heap for a <code>CObjString</code>, bump the retain count to one, and duplicates the <code>chars</code> buffer passed as a pointer.
 * 
 *  @param length The length of characters on <code>chars</code> without the Null character (<code>'\0'</code>)
 *  @param chars  Pointer to buffer to be copied by this function.
 */
struct CObjString* cobjstring_create(size_t length, char const* chars);

/*!
 *  @abstract It allocates space in the heap for a <code>CObjString</code>, bump the retain count to one, and duplicates the <code>chars</code> buffer passed within the <code>str</code> parameter.
 * 
 *  @param str <code>CObjString</code> pointer where we must copied/duplicate the <code>CString</code> values.
 */
struct CObjString* cobjstring_createWithValuesOf(struct CString const* str);

/*!
 *  @abstract It adds one to the retain count.
 *
 *  @param objStringPtr <code>CObjString</code> structure to be retained.
 */
#define cobjstring_retain(objStringPtr)    ccore_retain(objStringPtr->core)

/*!
 *  @abstract It releases and, if retained count is zero, deallocates a <code>CObjString</code>.
 *  @discussion If the argument is <code>NULL</code>, no further actions are performed within the function.
 *
 *  @param objStringPtr <code>CObjString</code> structure to be released.
 */
void cobjstring_release(struct CObjString* objStringPtr);
