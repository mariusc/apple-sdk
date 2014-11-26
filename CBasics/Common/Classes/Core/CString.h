#pragma once

#include "CCore.h"      // CBasics (Core)
#include <string.h>     // C Standard
#include <stdbool.h>    // C Standard

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
    size_t allocated;
    char* chars;
};

/*!
 *  @abstract This macro is replaced with a structure initialiser with the passed arguments.
 *
 *  @param count The number of <code>char</code> in the string not including the Null character (<code>'\0'</code>).
 *  @param sizeAllocated Size allocated (with dynamic memory allocation) for the buffer. It contains the Null character.
 *  @param characters <code>char</code> buffer.
 */
#define cstring_init(count, sizeAllocated, characters)  { .length=count, .allocated=sizeAllocated, .chars=characters }

/*!
 *  @abstract It replaces this macro call with a <code>struct CString</code> initialiser with the passed arguments.
 *  @discussion The string length will be <code>count</code> and the allocated buffer space will be <code>count</code> plus one.
 *
 *  @param count The number of <code>char</code> in the string not including the Null character (<code>'\0'</code>).
 *  @param characters <code>char</code> buffer.
 */
#define cstring_initWith(count, characters)         { .length=count, .allocated=(count+1), .chars=characters }

/*!
 *  @abstract It replaces this call with a <code>struct CString</code> initialiser containing the compile-time string and its compile-time size calculation. The allocated buffer size will be zero.
 *  @discussion This macro expects <code>characters</code> to be a compile-time string. It expects the compiler to compile away the <code>strlen()</code> function call to its proper value.
 *
 *  @param characters The global string to alias.
 */
#define cstring_initWithGlobal(characters)          { .length=strlen(characters), .allocated=0, .chars=characters }

/*!
 *  @abstract This macro is replaced with a <code>struct CString</code> compound literal with the specific length, allocated buffer size, and pointer to <code>char</code> buffer.
 *
 *  @param count The number of <code>char</code> in the string not including the Null character (<code>'\0'</code>).
 *  @param sizeAllocated Size allocated (with dynamic memory allocation) for the buffer. It contains the Null character.
 *  @param characters <code>char</code> buffer.
 */
#define cstring(count, sizeAllocated, characters)   ( (struct CString)cstring_init(count, sizeAllocated, characters) )

/*!
 *  @abstract It replaces this macro call with a <code>struct CString</code> compound literal with the passed arguments.
 *  @discussion The string length will be <code>count</code> and the allocated buffer space will be <code>count</code> plus one.
 *
 *  @param count The number of <code>char</code> in the string not including the Null character (<code>'\0'</code>).
 *  @param characters <code>char</code> buffer.
 */
#define cstring_with(count, characters)             ( (struct CString)cstring_initWith(count, characters) )

/*!
 *  @abstract It replaces this call with a <code>struct CString</code> compound literal containing the compile-time string and its compile-time size calculation. The allocated buffer size will be zero.
 *  @discussion This macro expects <code>characters</code> to be a compile-time string. It expects the compiler to compile away the <code>strlen()</code> function call to its proper value.
 *
 *  @param characters The global string to alias.
 */
#define cstring_withGlobal(characters)              ( (struct CString)cstring_initWithGlobal(characters) )

/*!
 *  @abstract It sets the <code>target</code> <code>CString</code> structure members with the arguments passed to the macro.
 *  @discussion If the the structure already contained allocated space, this is <i>freed</i> before settin up the members.
 *
 *  @param length The number of <code>char</code> in the string not including the Null character (<code>'\0'</code>).
 *  @param allocatedSpace Size allocated (with dynamic memory allocation) for the buffer. It contains the Null character.
 *  @param chars <code>char</code> buffer.
 *  @return It returns the <code>target</code> argument.
 */
struct CString* cstring_set(struct CString* target, size_t length, size_t allocatedSpace, char const* chars);

/*!
 *  @abstract It sets the <code>target</code> <code>CString</code> structure members with the arguments passed to the macro.
 *  @discussion The string length will be <code>count</code> and the allocated buffer space will be <code>count + 1</code>.
 *      If the the structure already contained allocated space, this is <i>freed</i> before settin up the members.
 *
 *  @param length The number of <code>char</code> in the string not including the Null character (<code>'\0'</code>).
 *  @param chars <code>char</code> buffer.
 *  @return It returns the <code>target</code> argument.
 */
struct CString* cstring_setWith(struct CString* target, size_t length, char const* chars);

/*!
 *  @abstract It sets the <code>target</code> <code>CStringe</code> structure members with the arguments passed to the macro.
 *  @discussion This function expects <code>characters</code> to be a compile-time string. It expects the compiler to compile away the <code>strlen()</code> function call to its proper value.
 *
 *  @param chars The global string to alias.
 *  @return It returns the <code>target</code> argument.
 */
struct CString* cstring_setWithGlobal(struct CString* target, char const* const chars);

/*!
 *  @abstract It copies the second arguments members into the first argument <code>CString</code> structure.
 *  @discussion A full copy is done for the characters buffer.
 *
 *  @param target The <code>CString</code> structure that will contain the copy.
 *  @param toCopy The <code>CString</code> structure from where the buffer will be copied.
 *  @return It returns the <code>target</code> argument.
 */
struct CString* cstring_copy(struct CString* restrict target, struct CString const* restrict toCopy);

/*!
 *  @abstract It copies a <code>length + 1</code> number of characters from <code>chars, to <code>target</code>.
 *  @discussion A full copy is done for the characters buffer.
 *
 *  @param target The <code>CString</code> structure that will contain the copy.
 *  @param length The number of <code>char</code> in the string not including the Null character (<code>'\0'</code>).
 *  @param chars <code>char</code> buffer.
 *  @return It returns the <code>target</code> argument.
 */
struct CString* cstring_copyWith(struct CString* target, size_t length, char const* chars);

/*!
 *  @abstract It copies a compile-time string (set in .DATA section) into the heap.
 *  @discussion A full copy is done for the characters buffer.
 *
 *  @param target The <code>CString</code> structure that will contain the copy.
 *  @param chars <code>char</code> buffer.
 *  @return It returns the <code>target</code> argument.
 */
struct CString* cstring_copyWithGlobal(struct CString* target, char const* const chars);

struct CString* cstring_free(struct CString* target);

struct CString* cstring_append(struct CString const* target, struct CString const* toAppend);

struct CString* cstring_appendIn(struct CString* restrict target, struct CString const* restrict toAppend);

struct CString* cstring_preppend(struct CString const* target, struct CString const* toPreppend);

struct CString* cstring_preppendIn(struct CString* restrict target, struct CString* restrict toPreppend);

struct CString* cstring_tokenizerStep(struct CString const* target, size_t* fromChar);

struct CArray* cstring_tokenizer(struct CString const* target);

bool cstring_compare(struct CString const* strA, struct CString const* strB, ssize_t* charactersLengthDifference);

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
//struct CObjString* cobjstring_malloc();

/*!
 *  @abstract It allocates space in the heap for a <code>CObjString</code>, bump the retain count to one, and duplicates the <code>chars</code> buffer passed as a pointer.
 * 
 *  @param length The length of characters on <code>chars</code> without the Null character (<code>'\0'</code>)
 *  @param chars  Pointer to buffer to be copied by this function.
 */
//struct CObjString* cobjstring_create(size_t length, char const* chars);

/*!
 *  @abstract It allocates space in the heap for a <code>CObjString</code>, bump the retain count to one, and duplicates the <code>chars</code> buffer passed within the <code>str</code> parameter.
 * 
 *  @param str <code>CObjString</code> pointer where we must copied/duplicate the <code>CString</code> values.
 */
//struct CObjString* cobjstring_createWithValuesOf(struct CString const* str);

/*!
 *  @abstract It adds one to the retain count.
 *
 *  @param objStringPtr <code>CObjString</code> structure to be retained.
 */
//#define cobjstring_retain(objStringPtr)    ccore_retain(objStringPtr->core)

/*!
 *  @abstract It releases and, if retained count is zero, deallocates a <code>CObjString</code>.
 *  @discussion If the argument is <code>NULL</code>, no further actions are performed within the function.
 *
 *  @param objStringPtr <code>CObjString</code> structure to be released.
 */
//void cobjstring_release(struct CObjString* objStringPtr);
