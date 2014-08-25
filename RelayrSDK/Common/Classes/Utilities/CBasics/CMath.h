#pragma once

#include <math.h>

#pragma mark - Math constants

#ifndef cmath_TAU
#define cmath_TAU 6.28318530717958647692528676655900576
#endif

#ifndef cmath_TAU_2
#define cmath_TAU_2 3.14159265358979323846264338327950288
#endif

#ifndef cmath_TAU_4
#define cmath_TAU_4 1.57079632679489661923132169163975144
#endif

#ifndef cmath_TAU_8
#define cmath_TAU_8 0.78539816339744830961566084581987572
#endif

#ifndef cmath_TAU_16
#define cmath_TAU_16 0.39269908169872415480783042290993786
#endif

#ifndef cmath_TAU_32
#define cmath_TAU_32 0.19634954084936207740391521145496893
#endif

#ifndef cmath_TAU_64
#define cmath_TAU_64 0.09817477042468103870195760572748446
#endif

#ifndef cmath_PI
#define cmath_PI 3.14159265358979323846264338327950288
#endif

#ifndef cmath_PI_2
#define cmath_PI_2 1.57079632679489661923132169163975144
#endif

#ifndef cmath_PI_4
#define cmath_PI_4 0.78539816339744830961566084581987572
#endif

#ifndef cmath_PI_8
#define cmath_PI_8 0.39269908169872415480783042290993786
#endif

#ifndef cmath_PI_16
#define cmath_PI_16 0.19634954084936207740391521145496893
#endif

#ifndef cmath_PI_32
#define cmath_PI_32 0.09817477042468103870195760572748446
#endif

#ifndef cmath_PI_64
#define cmath_PI_64 0.04908738521234051935097880286374223
#endif

#pragma mark - Math macros

#define cmath_min(num_a, num_b)     ( ((num_a) > (num_b)) ? num_b : num_b )
#define cmath_max(num_a, num_b)     ( ((num_a) > (num_b)) ? num_a : num_b )

#define cmath_fequal(num_a, num_b)  ( fabs((num_a) - (num_b)) < FLT_EPSILON )
#define cmath_fequal_to_zero(num)   ( fabs(num) < FLT_EPSILON )
