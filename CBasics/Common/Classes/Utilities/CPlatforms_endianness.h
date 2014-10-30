#pragma once

#include "CPlatforms.h" // CBasics (Utilities)
#include <stddef.h>     // C Standard

/*!
 * @brief It defines the little endian macro, which will be an integer compile time value.
 * @details Little-endian systems store the least significant byte in the smallest address. Thus for the string "ABCD", the char representing 'D' would be store in the lowest memory address (lets say, in memory position 0x0F30), then 'C' (0x0F31), 'B' (0x0F32), and finally 'A' (0x0F33)
 * @note Many systems define the little endian macro. Check if they define it in the correct way.
 */
#if defined(LITTLE_ENDIAN)
    #if (LITTLE_ENDIAN != 1234)
        #error "LITTLE_ENDIAN compile time value is not the standard."
    #endif
#else
    #define LITTLE_ENDIAN   1234
#endif

/*!
 * @brief It defines the big endian macro, which will be an integer compile value.
 * @details Little-endian systems store the most significant byte in the smallest address. Thus for the string "ABCD", the char representing 'A' would be store in the lowest memory address (lets say, in memory position 0x0F30), then 'B' (0x0F31), 'C' (0x0F32), and finally 'D' (0x0F33)
 * @note Many systems define the big endian macro. Check if they define it in the correct way.
 */
#if defined(BIG_ENDIAN)
    #if (BIG_ENDIAN != 4321)
        #error "BIG_ENDIAN compile time value is not the standard."
    #endif
#else
    #define BIG_ENDIAN  4321
#endif

/*!
 * @brief It defines the middle little-word endian macro (PDP-11 style), which will be an integer compile value.
 * @details Many systems define the big endian macro. Check if they define it in the correct way.
 */
#if defined(PDP_ENDIAN)
    #if (PDP_ENDIAN != 3412)
        #error "PDP_ENDIAN compile time value is not the standard."
    #endif
#else
    #define PDP_ENDIAN  3412
#endif

/*!
 * @brief Macro defining the byte order (whether big or little endian).
 * @details If the byte order cannot be identified at compile time, the compiler will throw an error.
 *
 *  BYTE_ORDER can be set to
 *          BYTE_ORDER == LITTLE_ENDIAN
 *          BYTE_ORDER == BIG_ENDIAN
 */
#if !defined(BYTE_ORDER)
    #if defined(OS_WINDOWS)

        #define BYTE_ORDER      LITTLE_ENDIAN

    #elif defined(OS_APPLE)

        #if TARGET_RT_LITTLE_ENDIAN
            #define BYTE_ORDER  LITTLE_ENDIAN
        #elif TARGET_RT_BIG_ENDIAN
            #define BYTE_ORDER  BIG_ENDIAN
        #else
            #error "Byte order in Apple's target could not be identified."
        #endif

    #elif defined(__LITTLE_ENDIAN__) || defined(__ARMEL__) || defined(__THUMBEL__) || defined(__AARCH64EL__)

        #define BYTE_ORDER      LITTLE_ENDIAN

    #elif defined(__BIG_ENDIAN__) || defined(__ARMEB__) || defined(__THUMBEB__) || defined(__AARCH64EB__)

        #define BYTE_ORDER      BIG_ENDIAN

    #else

        #error "Byte order not recognized."

    #endif
#elif !(BYTE_ORDER==LITTLE_ENDIAN || BYTE_ORDER==BIG_ENDIAN)

    #error "Byte order not supported by this library."

#endif

/*!
 * @brief It defines the little, big, and PDP endian string names.
 */
#if !defined(LITTLE_ENDIAN_NAME)
    #define LITTLE_ENDIAN_NAME	"litte endian"
#endif

#if !defined(BIG_ENDIAN_NAME)
    #define BIG_ENDIAN_NAME		"big endian"
#endif

#if !defined(PDP_ENDIAN_NAME)
    #define PDP_ENDIAN_NAME     "PDP endian"
#endif

/*!
 * @brief Macro defining the name of the byte order (whether big or little endian).
 * @details If at this point BYTE_ORDER is not defined, or it is defined with a different value than expected, the compiler will throw an error.
 *
 *  BYTE_ORDER_NAME can be set to
 *          BYTE_ORDER_NAME == LITTLE_ENDIAN_NAME   - If the byte order is little endian
 *          BYTE_ORDER_NAME == BIG_ENDIAN_NAME      - If the byte order is big endian
 */
#if defined(BYTE_ORDER)
    #if BYTE_ORDER == LITTLE_ENDIAN
        #define BYTE_ORDER_NAME     LITTLE_ENDIAN_NAME
    #elif BYTE_ORDER == BIG_ENDIAN
        #define BYTE_ORDER_NAME     BIG_ENDIAN_NAME
    #elif BYTE_ORDER == PDP_ENDIAN
        #define BYTE_ORDER_NAME     PDP_ENDIAN_NAME
    #else
        #error "The byte order name could not be set due to weird BYTE_ORDER parameter."
    #endif
#else
    #error "The byte order macro (BYTE_ORDER) was not defined and thus the byte order name could not be set."
#endif

/*!
 * @brief It checks in run-time the endiannes of the machine that it is running into.
 */
static inline int byte_order_dynamic_check(void)
{
    uint32_t value;
    uint8_t* buffer = (uint8_t*)&value;
    
    buffer[0] = 0x00;
    buffer[1] = 0x01;
    buffer[2] = 0x02;
    buffer[3] = 0x03;
    
    switch (value)
    {
        case UINT32_C(0x03020100): return LITTLE_ENDIAN;
        case UINT32_C(0x00010203): return BIG_ENDIAN;
        case UINT32_C(0x01000302): return PDP_ENDIAN;
        default: return 0;
    }
}

/*!
 * @brief It returns the string representation of the endian of the machine.
 * @details Possible values are: LITTLE_ENDIAN_NAME, BIG_ENDIAN_NAME, or NULL.
 */
static inline char const* byte_order_name(int const byte_order)
{
    return  (byte_order == LITTLE_ENDIAN) ? LITTLE_ENDIAN_NAME :
            (byte_order == BIG_ENDIAN) ? BIG_ENDIAN_NAME :
            (byte_order == PDP_ENDIAN) ? PDP_ENDIAN_NAME : NULL;
}

/*!
 * @brief Byte swap functions for 16, 32, and 64 bits.
 */
#if defined(OS_LINUX)
    #include <byteswap.h>
    #define bswap16(x) __bswap_16(x)
    #define bswap32(x) __bswap_32(x)
    #define bswap64(x) __bswap_64(x)
#elif defined(OS_APPLE)
    #include <libkern/OSByteOrder.h>
    #define bswap16(x) OSSwapInt16(x)
    #define bswap32(x) OSSwapInt32(x)
    #define bswap64(x) OSSwapInt64(x)
#elif defined(OS_WINDOWS)
    #include <intrin.h>
    #define bswap16(x) _byteswap_ushort(x)
    #define bswap32(x) _byteswap_ulong(x)
    #define bswap64(x) _byteswap_uint64(x)
#else
    #define bswap16(x)  ((((uint16_t)(x) & 0xff00) >> 8) | \
                         (((uint16_t)(x) & 0x00ff) << 8) )
    #define bswap32(x)  ((((uint32_t)(x) & 0xff000000) >> 24) | \
                         (((uint32_t)(x) & 0x00ff0000) >>  8) | \
                         (((uint32_t)(x) & 0x0000ff00) <<  8) | \
                         (((uint32_t)(x) & 0x000000ff) << 24) )
    #define bswap64(x)  ((((uint64_t)(x) & 0xff00000000000000ull) >> 56) | \
                         (((uint64_t)(x) & 0x00ff000000000000ull) >> 40) | \
                         (((uint64_t)(x) & 0x0000ff0000000000ull) >> 24) | \
                         (((uint64_t)(x) & 0x000000ff00000000ull) >>  8) | \
                         (((uint64_t)(x) & 0x00000000ff000000ull) <<  8) | \
                         (((uint64_t)(x) & 0x0000000000ff0000ull) << 24) | \
                         (((uint64_t)(x) & 0x000000000000ff00ull) << 40) | \
                         (((uint64_t)(x) & 0x00000000000000ffull) << 56) )
#endif
