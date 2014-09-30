@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RLATestsConstants.h"   // Tests

/*!
 *  @abstract Test the high level methods of <code>RelayrCloud</code> static class.
 *
 *  @see RelayrCloud
 */
@interface RelayrCloudTest : XCTestCase
@end

@implementation RelayrCloudTest

#pragma mark - Unit tests

- (void)testIsReachable
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [RelayrCloud isReachable:^(NSError* error, NSNumber* isReachable) {
        XCTAssertNil(error);
        XCTAssertNotNil(isReachable);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testIsUserWithEmailRegistered
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [RelayrCloud isUserWithEmail:kTestsUserEmail registered:^(NSError* error, NSNumber* isUserRegistered) {
        XCTAssertNil(error);
        XCTAssertNotNil(isUserRegistered);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

@end
