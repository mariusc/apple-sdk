#include "CString.h"
#include "CMacros.h"
#include "CDebug.h"

#include <stdlib.h>
#include <string.h>

#pragma mark - Protoype definitions

//static CString _new_(CString const* const restrict str) __attribute__((pure));
//static CString _new_chars_(char const* const restrict chars);
//static CString _new_aliasing_(CString const* const restrict str);
//static CString _new_aliasing_chars_(char const* const restrict chars);

//static inline CObjString* _alloc_(void);
//static void _dealloc_(CObjString* const restrict str);  // This function is not exposed.
//static CString* _init_(CString* const restrict str);
//
//static CObjString* _create_(void);
//static CObjString* _create_with_(char const* const restrict string);
//static CObjString* _create_with_chars_and_length_(char const* const restrict string, size_t const max_length);
//static CObjString* _retain_(CObjString* const restrict str);
//static CObjString* _release_(CObjString* restrict str);
//static CObjString* _clone_(CString const* const restrict str);
//
//static CObjString* _append_(CString const* const restrict base, CString const* const restrict to_add);
//static CObjString* _append_chars_(CString const* const restrict base, char const* const restrict string, size_t const max_length);
//static CObjString* _append_path_(CString const* const restrict base, CString const* const restrict to_add, CString const* const restrict delimiter);
//
//static CObjString* _prepend_(CString const* const restrict base, CString const* const restrict to_add);
//static CObjString* _prepend_chars_(CString const* const restrict base, char const* const restrict string, size_t const max_length);
//static CObjString* _prepend_path_(CString const* const restrict base, CString const* const restrict to_prepend, CString const* const restrict delimiter);
//
//static bool _compare_(CString const* const restrict str_a, CString const* const restrict str_b);

#pragma mark - Class object declaration

struct CStringFunctionality const cstring = {
    .nullchar = '\0',
    .nullCString = (CString){ .chars=NULL, .length=0, .allocatedLength=0 },
//    
//    .newWithCString = _new_,
//    .newWithChars = _new_chars_,
//    .new_aliasing = _new_aliasing_,
//    .new_aliasing_chars = _new_aliasing_chars_
    
    
//    .alloc = _alloc_,
//    .init = _init_,
//
//    .create = _create_,
//    .create_with = _create_with_,
//    .create_with_chars_length = _create_with_chars_and_length_,
//    .retain = _retain_,
//    .release = _release_,
//    .clone = _clone_,
//    
//    .append = _append_,
//    .prepend = _prepend_,
//    .append_chars = _append_chars_,
//    .prepend_chars = _prepend_chars_,
//    .append_path = _append_path_,
//    .prepend_path = _prepend_path_,
//    
//    .compare = _compare_
};

#pragma mark - Implementation

//static CString _new_(CString const* const restrict str)
//{
//    if ( str!=NULL && str->length>0 && str->chars!=NULL )
//    {
//        char* const restrict copy = malloc(str->length);
//        memverify(copy, end);
//        
//        strcpy(copy, str->chars);
//        return (CString){ .length=0, .chars=copy };
//    }
//    
//end:
//    return cstring.nullCString;
//}
//
//static CString _new_chars_(char const* const restrict chars)
//{
//    if ( chars!= NULL )
//    {
//        size_t const length = strlen(chars);
//        if (length == 0) goto end;
//        
//        char* const restrict copy = malloc(length);
//        memverify(copy, end);
//        
//        strcpy(copy, chars);
//        return (CString){ .length=0, .chars=copy };
//    }
//    
//end:
//    return (CString){ .length=0, .chars=NULL };
//}
//
//static CString _new_aliasing_(CString const* const restrict str)
//{
//    if ( str!=NULL && str->length>0 && str->chars!=NULL )
//        return (CString) { .length=str->length, .chars=str->chars };
//    else
//        return (CString){ .length=0, .chars=NULL };
//}
//
//static CString _new_aliasing_chars_(char const* const restrict chars)
//{
//    if (chars != NULL)
//        return (CString){ .length=strlen(chars), .chars=(char*)chars };
//    else
//        return (CString){ .length=0, .chars=NULL };
//}

//static inline CObjString* _alloc_(void)
//{
//    return malloc( sizeof(CObjString) );
//}
//
//static void _dealloc_(CObjString* const restrict str)
//{
//    if (likely(str != NULL))
//    {
//        free(str->string.chars);
//        free(str);
//    }
//}
//
//static CString* _init_(CString* const restrict str)
//{
//    if (str != NULL)
//    {
//        str->length = 0;
//        str->chars = NULL;
//    }
//    
//    return str;
//}
//
//static CObjString* _create_(void)
//{
//    CObjString* obj = cstring.alloc();
//    if (likely(obj != NULL))
//    {
//        ccore.initWithType(&obj->core, COBJ_TYPE_STRING);
//        cstring.init(&obj->string);
//    }
//    return obj;
//}
//
//static CObjString* _create_with_(char const* const restrict string)
//{
//    CObjString* restrict result = NULL;
//    if (string==NULL || string[0]==cstring.nullchar) goto end;
//    
//    size_t const strlength = strlen(string);
//    if (strlength == 0) goto end;
//    
//    result = cstring.create();
//    memverify(result, end);
//    
//end:
//    return result;
//}
//
//static CObjString* _create_with_chars_and_length_(char const* const restrict string, size_t const max_length)
//{
//    CObjString* restrict result = NULL;
//    if (string==NULL || max_length==0 || string[0]==cstring.nullchar) goto end;
//    
//    size_t const strlen = strnlen(string, max_length);
//    if (strlen == 0) goto end;
//    
//    result = cstring.create();
//    memverify(result, end);
//    
//    size_t const total_length = (string[strlen-1] == cstring.nullchar) ? strlen : strlen+1;
//    char* const restrict chars = malloc(total_length);
//    if (unlikely(chars==NULL)) return cstring.release(result);
//    
//    memcpy(chars, string, strlen);
//    *(chars + total_length - 1) = cstring.nullchar;
//    
//    result->string.length = total_length;
//    result->string.chars = chars;
//end:
//    return result;
//}
//
//static CObjString* _retain_(CObjString* const restrict str)
//{
//    cobjcore.retain(&str->core);
//    return str;
//}
//
//static CObjString* _release_(CObjString* restrict str)
//{
//    if (str != NULL)
//    {
//        CObjCore* const restrict core = cobjcore.release(&str->core);
//        if ((core->actives==0) && (core->type==COBJ_TYPE_STRING) && cobjcore.isFlagSet(core, COBJCORE_FLAG_ISINHEAP_POS))
//        {
//            _dealloc_(str);
//            str = NULL;
//        }
//    }
//    
//    return str;
//}
//
//static CObjString* _clone_(CString const* const restrict str)
//{
//    return (str != NULL) ? cstring.create_with_chars(str->chars, str->length) : NULL;
//}
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
