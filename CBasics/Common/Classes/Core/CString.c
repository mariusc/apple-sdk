#include "CString.h"    // Header

#include "CMacros.h"    // CBasics (Utilities)
#include "CDebug.h"     // CBasics (Utilities)

#include <stdlib.h>     // C Standard

#pragma mark - CString

#pragma mark - CObjString

struct CObjString* cobjstring_malloc()
{
    struct CObjString* obj = malloc_sizeof(struct CObjString);
    verifymem_opt(obj, end);
    
    obj->core = ccore(CClassString, 1);
    obj->string = cstring(0, NULL);
end:
    return obj;
}

struct CObjString* cobjstring_create(size_t const length, char const* const restrict chars)
{
    struct CObjString* obj = malloc_sizeof(struct CObjString);
    verifymem_opt(obj, end);
    
    obj->core = ccore(CClassString, 1);
    
    if (length!=0 && chars!=NULL)
    {
        obj->string.length = length;
        memcpy(obj->string.chars, chars, length+1);
    }
    else { obj->string = cstring(0, NULL); }
    
end:
    return obj;
}

struct CObjString* cobjstring_createWithValuesOf(struct CString const* str)
{
    struct CObjString* obj = NULL;
    verifymem(str, end);
    
    obj = cobjstring_create(str->length, str->chars);
end:
    return obj;
}

void cobjstring_release(struct CObjString* objStringPtr)
{
    verifymem(objStringPtr, end);
    
    ccore_release(objStringPtr->core)
    {
        free(objStringPtr->string.chars);
        free(objStringPtr);
    }
    
end:
    return;
}

//
//static CObjString* _append_(CString const* const restrict base, CString const* const restrict to_add)
//{
//    if (to_add==NULL) return cstring.clone(base);
//    return cstring.append_chars(base, to_add->chars, to_add->length);
//}
//
//static CObjString* _prepend_(CString const* const restrict base, CString const* const restrict to_add)
//{
//    return (to_add != NULL) ? cstring.prepend_chars(base, to_add->chars, to_add->length) : NULL;
//}
//
//static CObjString* _append_chars_(CString const* const restrict base, char const* const restrict string, size_t const max_length)
//{
//    if (string==NULL || max_length==0) return cstring.clone(base);
//    if (base==NULL || base->length<2) return cstring.create_with_chars(string, max_length);
//    
//    size_t const numc_base = base->length - 1;
//    size_t const total_length = max_length + ((string[max_length-1] == cstring.nullchar) ? numc_base : base->length);
//    
//    char* const restrict chars = malloc(total_length);
//    memverify(chars, error);
//    
//    memcpy(chars, base->chars, numc_base);
//    memcpy(chars + numc_base, string, max_length);
//    *(chars + total_length - 1) = cstring.nullchar;
//    
//    CObjString* result = cstring.create();
//    memverify(result, error_liberate_chars);
//    
//    result->string.length = total_length;
//    result->string.chars = chars;
//    return result;
//    
//error_liberate_chars:
//    free(chars);
//error:
//    return NULL;
//}
//
//static CObjString* _prepend_chars_(CString const* const restrict base, char const* const restrict string, size_t const max_length)
//{
//    if (string==NULL || max_length==0) return cstring.clone(base);
//    if (base==NULL || base->length<2) return cstring.create_with_chars(string, max_length);
//    
//    size_t const numc_string = (string[max_length-1] == cstring.nullchar) ? max_length-1 : max_length;
//    size_t const total_length = numc_string + base->length;
//    
//    char* const restrict chars = malloc(total_length);
//    memverify(chars, error);
//    
//    memcpy(chars, string, numc_string);
//    memcpy(chars, base->chars, base->length);
//    chars[total_length-1] = cstring.nullchar;
//    
//    CObjString* result = cstring.create();
//    memverify(result, error_liberate_chars);
//    result->string.length = total_length;
//    result->string.chars = chars;
//    return result;
//    
//error_liberate_chars:
//    free(chars);
//error:
//    return NULL;
//}
//
//static CObjString* _append_path_(CString const* const restrict base, CString const* const restrict to_add, CString const* const restrict delimiter)
//{
//    if (base==NULL || to_add==NULL || delimiter==NULL || delimiter->length<2) goto error;
//    size_t const numc_delimiter = delimiter->length - 1;
//    
//    int const base_cmp = (base->length > numc_delimiter) ? memcmp( &(base->chars[base->length - delimiter->length]), delimiter->chars, numc_delimiter) : -1;
//    if (to_add->length < 2) // If "to_add" is empty...
//        return (base_cmp == 0) ? cstring.clone(base) : cstring.append_chars(base, delimiter->chars, delimiter->length);
//    
//    int const toadd_cmp = (to_add->length > numc_delimiter) ? memcmp(to_add->chars, delimiter->chars, numc_delimiter) : -1;
//    if (base->length < 2)   // If "base" is  empty, but "to_add" is not...
//        return (toadd_cmp == 0) ? cstring.clone(to_add) : cstring.prepend_chars(to_add, delimiter->chars, delimiter->length);
//    
//    size_t result_length;
//    char* restrict result_str;
//    
//    if (base_cmp != 0)  // If "base" doesn't have the delimiter at the end of its string...
//    {
//        if (toadd_cmp == 0)    // If "to_add" has the delimiter at the beginning of its string...
//            return cstring.append_chars(base, to_add->chars, to_add->length);
//        
//        size_t const numc_base = base->length - 1;
//        result_length = numc_base + numc_delimiter + to_add->length;
//        result_str = malloc(result_length);
//        memverify(result_str, error);
//        
//        memcpy(result_str, base->chars, numc_base);
//        memcpy(&(result_str[numc_base]), delimiter->chars, numc_delimiter);
//        memcpy(&(result_str[numc_base + numc_delimiter]), to_add->chars, to_add->length);
//    }
//    else    // If "base" has already the delimiter at the end of its string...
//    {
//        if (toadd_cmp != 0) // If "to_add" doesn't have the delimiter at the beginning of its string...
//            return cstring.append_chars(base, to_add->chars, to_add->length);
//        
//        size_t const numc_base = base->length - delimiter->length;
//        result_length = numc_base + to_add->length;
//        result_str = malloc(result_length);
//        memverify(result_str, error);
//        
//        memcpy(result_str, base->chars, numc_base);
//        memcpy(&(result_str[numc_base]), to_add->chars, to_add->length);
//    }
//    
//    result_str[result_length-1] = cstring.nullchar;
//    
//    CObjString* result = cstring.create();
//    memverify(result, error_liberate_string);
//    result->string.length = result_length;
//    result->string.chars = result_str;
//    return result;
//    
//error_liberate_string:
//    free(result_str);
//error:
//    return NULL;
//}
//
//static CObjString* _prepend_path_(CString const* const restrict base, CString const* const restrict to_prepend, CString const* const restrict delimiter)
//{
//    if (base==NULL || to_prepend==NULL || delimiter==NULL || delimiter->length<2) goto error;
//    size_t const numc_delimiter = delimiter->length - 1;
//    
//    int const pre_cmp = (to_prepend->length > numc_delimiter) ? memcmp( &(to_prepend->chars[to_prepend->length - delimiter->length]), delimiter->chars, numc_delimiter) : -1;
//    if (base->length < 2)       // If "base" is empty...
//        return (pre_cmp == 0) ? cstring.clone(to_prepend) : cstring.append_chars(to_prepend, delimiter->chars, delimiter->length);
//    
//    int const base_cmp = (base->length > numc_delimiter) ? memcmp(base->chars, delimiter->chars, numc_delimiter) : -1;
//    if (to_prepend->length < 2) // If "to_prepend" is emtpy, but "base" is not...
//        return (base_cmp == 0) ? cstring.clone(base) : cstring.prepend_chars(base, delimiter->chars, delimiter->length);
//    
//    size_t result_length;
//    char* restrict result_str;
//    
//    if (to_prepend != 0)    // If "to_prepend" doesn't have the delimiter at the end of its string...
//    {
//        if (base_cmp == 0)  // If "base" has the delimiter at the beginning of its string...
//            return cstring.prepend_chars(base, to_prepend->chars, to_prepend->length);
//        
//        size_t const numc_pre = to_prepend->length - 1;
//        result_length = numc_pre + numc_delimiter + base->length;
//        result_str = malloc(result_length);
//        memverify(result_str, error);
//        
//        memcpy(result_str, to_prepend->chars, numc_pre);
//        memcpy(&(result_str[numc_pre]), delimiter->chars, numc_delimiter);
//        memcpy(&(result_str[numc_pre + numc_delimiter]), base->chars, base->length);
//    }
//    else                    // If "to_prepend" has the delimiter at the end of its string...
//    {
//        if (base_cmp != 0)  // If "base" doesn't have the delimiter at the beginning of its string...
//            return cstring.prepend_chars(base, to_prepend->chars, to_prepend->length);
//        
//        size_t const numc_pre = to_prepend->length - delimiter->length;
//        result_length = numc_pre + base->length;
//        result_str = malloc(result_length);
//        memverify(result_str, error);
//        
//        memcpy(result_str, to_prepend->chars, numc_pre);
//        memcpy(&(result_str[numc_pre]), base->chars, base->length);
//    }
//    
//    CObjString* result = cstring.create();
//    memverify(result, error_liberate_string);
//    result->string.length = result_length;
//    result->string.chars = result_str;
//    return result;
//    
//error_liberate_string:
//    free(result_str);
//error:
//    return NULL;
//}
//
//static bool _compare_(CString const* const restrict str_a, CString const* const restrict str_b)
//{
//    if (str_a == NULL || str_a->length==0)
//        return (str_b == NULL || str_b->length==0) ? true : false;
//    else if (str_b == NULL || str_b->length==0) return false;
//    
//    if (str_a->length != str_b->length) return false;
//    
//    return (memcmp(str_a, str_b, str_a->length) == 0) ? true : false;
//}
