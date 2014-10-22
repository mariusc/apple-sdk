#include "CString.h"    // Header

#define STRINGIFY(x)    #x
#define TOSTRING(x)     STRINGIFY(x)

// View http://clang.llvm.org/docs/LanguageExtensions.html

#if defined(__STDC_VERSION__)
#pragma message("C Standard version: " TOSTRING(__STDC_VERSION__))
#endif

#if !__has_feature(c_alignas)
    #error C11 align function not available
#endif

#if __has_feature(c_atomic)
    #if !__has_include(<stdatomic.h>)
        #warning C11 <stdatomic.h> not included with the library
    #endif
#else
    #error C11 atomics not available
#endif

#if !__has_feature(c_generic_selections)
    #error C11 generic selections not available
#endif

#if !__has_feature(c_static_assert)
    #error C11 static assert not available
#endif

#if !__has_feature(c_thread_local)
    #error C11 thread locals not available
#endif
