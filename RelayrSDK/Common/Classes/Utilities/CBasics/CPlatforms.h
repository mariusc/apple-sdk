#pragma once
// For more information on pre-defined header go to: http://sourceforge.net/p/predef/wiki/Home/

/*!
 * @brief Macros defining in which operating system the generated code will run.
 * @details If the platform is not identified, the file won't compile (throwing a compile error).
 *
 *  One (and only one) of these must be defined, the rest are not defined:
 *          OS_WINDOWS              - Generated code will run under a Windows OS
 *          OS_WINDOWSCE            - Generated code will run under a Windows CE OS
 *          OS_LINUX                - Generated code will run under a Linux OS
 *          OS_APPLE                - Generated code will run under an Apple OS (Darwin)
 *
 *  If OS_LINUX is defined, any (or many) of the following can be defined:
 *          OS_LINUX_ANDROID        - Generated code will run under a Linux Android device
 *          OS_LINUX_GNU            -
 *          OS_LINUX_CNK            -
 *
 *  If OS_APPLE is defined, one (and only one) of these must be defined, the rest are not defined:
 *          OS_APPLE_IOS            - Generated code will run on an iOS device
 *          OS_APPLE_OSX            - Generated code will run on a mac
 *          OS_APPLE_IOS_SIMULATOR  - Generated code will run on the iOS simulator
 */
#if defined(__APPLE__)

    #define OS_APPLE

    #include "TargetConditionals.h"
    #if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
        #define OS_APPLE_IOS
    #elif TARGET_OS_IPHONE && TARGET_IPHONE_SIMULATOR
        #define OS_APPLE_IOS_SIMULATOR
    #elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        #define OS_APPLE_OSX
    #else
        #error "Unsupported Apple platform"
    #endif

#elif defined(_WIN32_WCE) || defined(WIN32_PLATFORM_HPC2000) || defined(WIN32_PLATFORM_HPCPRO) || defined(WIN32_PLATFORM_PSPC) || defined(WIN32_PLATFORM_WFSP)

    #define OS_WINDOWSCE

#elif defined(_WIN32) || defined(__WIN32__) || defined(__WINDOWS__)

    #define OS_WINDOWS

#elif defined(__linux__) || defined(__linux) || defined(linux)

    #define OS_LINUX

    #if defined(__ANDROID__) || defined(ANDROID)
        #define OS_LINUX_ANDROID
    #endif
    #if defined(__gnu_linux__)
        #define OS_LINUX_GNU
    #endif
    #if defined(__bg__)
        #define OS_LINUX_CNK
    #endif

#else
    #error "Unsupported major platform."
#endif

/*!
 * @brief Macros defining which object format the file will compile into.
 * @details If the object format is not identified, the file won't compile (throwing a compile error).
 *  The file format tells the structure of executables, object code, shared libraries, dynamically-loaded code, and core dumps.
 *
 *  One (and only one) of these must be defined, the rest are not defined:
 *          OBJ_FORMAT_COFF         - The "Common Object File Format" is being used for the generated code (old)
 *          OBJ_FORMAT_ELF          - The "Extensible Linking Format" is being used for the generated code (new)
 *          OBJ_FORMAT_MACH         - The "Mach Object File Format" is being used for the generated code (Apple)
 */
#if defined(_WIN32)
    #define OBJ_FORMAT_COFF
#elif defined(__ELF__)
    #define OBJ_FORMAT_ELF
#elif defined(__MACH__)
    #define OBJ_FORMAT_MACH
#else
    #error "Object format not recognized."
#endif

/*!
 * @brief Macros defining what compiler is being used.
 * @details If the compiler is not identified, the file won't compile (throwing a compile error).
 *
 *  One (and only one) of these must be defined, the rest are not defined:
 *          COMPILER_MICROSOFT      - Code generated through Visual Studio's compiler
 *          COMPILER_GNU            - Code generated through GCC compiler
 *          COMPILER_CLANG          - Code generated through Clang compiler
 */
#if defined(_MSC_VER) && !defined(__INTEL_COMPILER)

    #define COMPILER_MICROSOFT

#elif defined(__clang__)

    #define COMPILER_CLANG

#elif defined(__GNUC__) && !defined(__clang__) && !defined(__INTEL_COMPILER) && !defined(__CUDA_ARCH__)

    #define COMPILER_GNU

#else
    #error "Compiler not recognized."
#endif

/*!
 * @brief Macros defining the compatibility of the compiler used to generate code.
 * @details The compiler doesn't have to be compatible with the options here. Thus, not always this flags will be set.
 *
 *  Compatibility of the compiler used. Any or all of the followings can be defined:
 *          COMPILER_COMPATIBLE_WITH_MSVC   - The compiler is compatible with Microsoft Visual Studio's compiler
 *          COMPILER_COMPATIBLE_WITH_GCC    - The compiler is compatible with GNU GCC compiler
 */
#if defined(COMPILER_MICROSOFT) || defined(COMPILER_INTEL_FOR_WINDOWS)

    #define COMPILER_COMPATIBLE_WITH_MSVC

#endif

#if defined(COMPILER_GNU) || defined(COMPILER_CLANG) || defined(COMPILER_INTEL_FOR_UNIX)

    #define COMPILER_COMPATIBLE_WITH_GCC

#endif

/*!
 * @brief Macros defining the architecture and the ABI of the system.
 * @details If the architecture and ABI is not identified, the file won't compile (throwing a compile error).
 *
 *  One (and only one) of these must be defined, the rest are not defined:
 *          CPU_X86                 - Generated code for x86 architecture
 *          CPU_IA64                - Generated code for Intel Itanium CPU architecture
 *          CPU_ARM                 - Generated code for ARM CPU architecture
 *          CPU_POWERPC             - Generated code for PowerPC CPU architecture
 *          CPU_OPENCL              - Generated code for OpenCL CPU architecture
 *          GPU_OPENCL              - Generated code for OpenCL GPU architecture
 *
 *  If CPU_OPENCL or GPU_OPENCL are defined, then DEVICE_OPENCL is also defined.
 *
 *  At most one of these is true, the rest are false. The Application Binary Interface (ABI) determines how functions are called and in which binary format information should be passed from one program component to the next, or the operating system in the case of a system call.
 *          ABI_X86                 -
 *          ABI_X64                 -
 *          ABI_IA64                -
 *          ABI_ARM_AARCH32         -
 *          ABI_ARM_AARCH64         -
 *          ABI_POWERPC             -
 *          ABI_POWERPC64           -
 */
#if defined(OS_APPLE)

    #if TARGET_CPU_X86
        #define CPU_X86
        #define ABI_X86
    #elif TARGET_CPU_X86_64
        #define CPU_X86
        #define ABI_X64
    #elif TARGET_CPU_ARM
        #define CPU_ARM
        #define ABI_ARM_AARCH32
    #elif TARGET_CPU_ARM64
        #define CPU_ARM
        #define ABI_ARM_AARCH64
    #elif TARGET_CPU_PPC
        #define CPU_POWERPC
        #define ABI_POWERPC
    #elif TARGET_CPU_PPC64
        #define CPU_POWERPC
        #define ABI_POWERPC64
    #else
        #error "Apple platform CPU architecture not supported."
    #endif

#elif defined(COMPILER_COMPATIBLE_WITH_GCC)

    #if defined(__aarch64__)
        #define CPU_ARM
        #define ABI_ARM_AARCH64
    #elif defined(__arm__) && (defined(__ARM_ARCH_7__) || defined(__ARM_ARCH_7A__))
        #define CPU_ARM
        #define ABI_ARM_AARCH32
    #elif defined(i386) || defined(__i386) || defined(__i386__)
        #define CPU_X86
        #define ABI_X86
    #elif defined(__amd64__) || defined(__amd64) || defined(__x86_64__) || defined(__x86_64)
        #define CPU_X86
        #define ABI_X64
    #elif defined(__ia64__) || defined(_IA64) || defined(__IA64__)
        #define CPU_IA64
        #define ABI_IA64
    #elif defined(__ppc64__) || defined(__powerpc64__)
        #define CPU_POWERPC
        #define ABI_POWERPC64
    #elif defined(__powerpc) || defined(__powerpc__) || defined(__ppc__) || defined(__POWERPC__)
        #define CPU_POWERPC
        #define ABI_POWERPC
    #elif defined(__OPENCL_VERSION__)
        #define DEVICE_OPENCL
        #if defined(__CPU__)
            #define CPU_OPENCL
        #elif defined(__GPU__)
            #define GPU_OPENCL
        #endif
    #else
        #error "CPU architecture and ABI could not be defined for a compiler compatible with GCC."
    #endif

#elif defined(COMPILER_COMPATIBLE_WITH_MSVC)

    #if defined(_M_IX86) || defined() || defined() || defined() || defined()
        #define CPU_X86
        #define ABI_X86
    #elif defined(_M_X64) || defined(_M_AMD64)
        #define CPU_X86
        #define ABI_X64
    #elif defined(_M_IA64)
        #define CPU_IA64
        #define ABI_IA64
    #else
        #error "CPU architecture and ABI could not be defined for a compiler compatible with Microsoft Visual Studio."
    #endif

#else
    #error "CPU architecture not supported."
#endif
