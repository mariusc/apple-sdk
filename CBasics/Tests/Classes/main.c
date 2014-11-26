#include <CBasics/CTests.h>     // CBasics (Utilities)
#include "CoreTests.h"          // Tests (Core)

#pragma mark - Private prototypes

static bool test_main(void);

#pragma mark - Public API

TEST_MAIN(test_main);

#pragma mark - Private functionality

static bool test_main()
{
    TEST_INITIALIZE();
    
    TEST_RUN(test_ccore);
    TEST_RUN(test_cstring);
    
    TEST_FINALIZE();
}
