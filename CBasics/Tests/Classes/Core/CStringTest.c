#include "CoreTests.h"          // Header
#include <CBasics/CString.h>    // CBasics (Core)

#pragma mark - Private prototypes

bool cstring_structures(void);

#pragma mark - Public API

bool test_cstring(void)
{
    TEST_INITIALIZE();
    
    TEST_RUN(cstring_structures);
    
    TEST_FINALIZE();
}

#pragma mark - Private functionality

bool cstring_structures(void)
{
    return true;
}
