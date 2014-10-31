#pragma once

#if __STDC_VERSION__ != 201112L
    #error "C11 is necessary for this library"
#endif

#ifdef __STDC_NO_VLA__
    #pragma message "No Variable Length Arrays supported."
#endif

#ifdef __STDC_NO_THREADS__
    #pragma message "No C11 threading."
#endif

#ifdef __STDC_NO_ATOMICS__
    #pragma message "No C11 atomics."
#endif
