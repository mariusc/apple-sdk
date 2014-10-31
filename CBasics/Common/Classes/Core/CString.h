#pragma once

#include <stddef.h> // C Standard

#pragma mark - Structures definition

/*!
 * @abstract CString inner structure.
 * @details "length" represents the number of characters in the "char" array (includes the NULL character). The "allocated_length" represents the space allocated in memory. It can be 0 for strings compiled in the program or for strings in the stack.
 */
typedef struct CString
{
    char* chars;
    size_t length;
    size_t allocatedLength;
}
CString;

#pragma mark - Functions definition

/*!
 * @abstract All possible functions that can be performed on a CString are listed here.
 * @details You access the functions through the constant global object "cstring".
 */
struct CStringFunctionality
{
    /*!
     * @abstract C's null-character ('\0').
     */
    char const nullchar;
    
    /*!
     * @abstract CString 0-length/allocated_length.
     * @details All the members of CStrings are initialised to 0.
     */
    CString const nullCString;
    
    /*!
     * @abstract It initialises a new CString with the values of another CString.
     * @details The char array is copied (so like strdup()).
     */
//    CString (* const newWithCString)(CString const* const restrict str);
    
    /*!
     * @abstract <#brief#>
     * @details <#details#>
     */
//    CString (* const newWithChars)(char const* const restrict chars);
    
    /*!
     * @abstract <#brief#>
     * @details <#details#>
     */
//    CString (* const newAliasing)(CString const* const restrict str);
    
    /*!
     * @abstract <#brief#>
     * @details <#details#>
     */
//    CString (* const new_aliasing_chars)(char const* const restrict chars);

//    /*!
//     * @abstract It allocates space for the CString object in the heap.
//     */
//    CObjString* (* const alloc)(void);
//    
//    /*!
//     * @abstract It initializes a CString with the by-default parameters: core.actives=1, core.type=COBJ_TYPE_STRING, length=0, chars=NULL.
//     */
//    CString* (* const init)(CString* const restrict str);
//    
//    /*!
//     * @abstract It creates a CObjString, allocating space in the heap and initializing the object with the default values.
//     * @details Check the init() function for the default values.
//     */
//    CObjString* (* const create)(void);
//    
//    /*!
//     * @abstract It creates a CObjString, allocating space in the heap and initialization the object to point to the passed string (char array).
//     */
//    CObjString* (* const create_with)(char const* const restrict string);
//    
//    /*!
//     * @abstract It creates a CObjString, allocating space in the heap and initializing the object with the lenght and characters given.
//     * @param string It copies the chars (including the null char) into a heap buffer. If NULL or string[0]=='\0', the function will not perform any work, and NULL is returned.
//     * @param If 0, NULL is returned.
//     */
//    CObjString* (* const create_with_chars_length)(char const* const restrict string, size_t const max_length);
//    /*!
//     * @abstract It adds one to the reference counting number (only for heap objects).
//     * @param str CObjString in the heap to add 1 into its reference counter. If NULL, NULL is returned.
//     */
//    CObjString* (* const retain)(CObjString* const restrict str);
//    /*!
//     * @abstract It substracts one to the reference counting number (only for heap objects).
//     * @details If the reference counting number reaches 0, it will deallocate itself.
//     */
//    CObjString* (* const release)(CObjString* restrict str);
//    /*!
//     * @abstract It creates a new CObjString with the exact content of a CString.
//     * @param str If NULL, NULL is returned.
//     */
//    CObjString* (* const clone)(CString const* const restrict str);
//    /*!
//     * @abstract It creates a new CObjString with the content of the merged content of the first and second CStrings.
//     * @details The null character of "to_prepend" is removed, so the two strings can be merged.
//     * @param base If NULL, a CString object is created with the value of to_add (if it is alson wrong, NULL is returned).
//     * @param to_add If NULL, a clone of "base" is returned.
//     */
//    CObjString* (* const append)(CString const* const restrict base, CString const* const restrict to_add);
//    /*!
//     * @abstract It creates a new CObjString with the content of the "to_prepend" and "base" (in that order).
//     * @details The null character of "to_prepend" is removed, so the two strings can be merged.
//     * @param base If "NULL", a CString object is created with the value of "to_prepend" (if it is also NULL or empty, NULL is returned).
//     * @param to_prepend If NULL, a clone of "base" is returned.
//     */
//    CObjString* (* const prepend)(CString const* const restrict base, CString const* const restrict to_prepend);
//    /*!
//     * @abstract It appends the number of chars specified by max_length in the string array passed as parameter into the base CString.
//     * @details The "base" is stripped from the null character, and the "string" is appended to it. If there isn't a null character, one is added to it.
//     * @param base If NULL, a CString object is created with the value of string and max_length (if they are also wrong, NULL is returned).
//     * @param string If NULL, a clone of "base" is returned.
//     * @param max_length If 0, a clone of "base" is returned.
//     */
//    CObjString* (* const append_chars)(CString const* const restrict base, char const* const restrict string, size_t const max_length);
//    /*!
//     * @abstract It preprends the number of chars specified by max_length to base into a newly created CString object.
//     * @param base If NULL, a CString object is created with the value of string and max_length (if they are also worong, NULL is returned).
//     * @param string If NULL, a clone of "base" is returned.
//     * @param max_length If 0, a clone of "base" is returned.
//     */
//    CObjString* (* const prepend_chars)(CString const* const restrict base, char const* const restrict string, size_t const max_length);
//    /*!
//     * @abstract It appends the content of the second CString to the base CString, with the delimiter specified as an argument between them. Escaping characters is NOT allowed.
//     * @details If the delimiter is already specified in the base or in the second CString, it is not added.
//     * @param base If NULL, it returns NULL.
//     * @param to_add If NULL, it returns NULL.
//     * @param delimiter If NULL or length == 0 or 1, it returns NULL.
//     */
//    CObjString* (* const append_path)(CString const* const restrict base, CString const* const restrict to_add, CString const* const restrict delimiter);
//    /*!
//     * @abstract It prepends the content of the second CString to the base CString, with the delimiter specified as an argument between them. Escaping characters is NOT allowed.
//     * @details If the delimiter is already specified in the base or in the second CString, it is not added.
//     * @param base If NULL, it returns NULL.
//     * @param to_add If NULL, it returns NULL.
//     * @param delimiter If NULL or lenght == 0 or 1, it returns NULL.
//     */
//    CObjString* (* const prepend_path)(CString const* const restrict base, CString const* const restrict to_prepend, CString const* const restrict delimiter);
//    /*!
//     * @abstract It compares the content of "str_a" with the content of "str_b". If they are exactly the same chars, "true" is returned. Also, if both of the arguments are NULL, "true" is returned.
//     * @details The strings are suppose to be the same; thus the length is first checked. If they are indeed the same, every single char is compared (including the null char at the end). Of some chars are different, or one has a null char and the other doesn't: "false" is returned.
//     */
//    bool (* const compare)(CString const* const restrict str_a, CString const* const restrict str_b);
};

/*!
 * @abstract Global object enumerating all possible functions that can be performed on a CString object.
 * @details The compiler will compile away the access of the global object, since it is a constant.
 */
extern struct CStringFunctionality const cstring;
