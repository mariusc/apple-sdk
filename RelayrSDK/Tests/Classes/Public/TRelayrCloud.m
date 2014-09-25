@import Cocoa;              // Apple
@import XCTest;             // Apple
#import <Relayr/Relayr.h>   // Relayr.framework
#import "TestConstants.h"   // Tests

/*!
 *  @abstract Test the high level methods of <code>RelayrCloud</code> static class.
 *
 *  @see RelayrCloud
 */
@interface TRelayrCloud : XCTestCase
@end

@implementation TRelayrCloud

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
}

#pragma mark - Unit tests

- (void)test_isReachable
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [RelayrCloud isReachable:^(NSError* error, NSNumber* isReachable) {
        XCTAssertNil(error);
        XCTAssertNotNil(isReachable);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)test_isUserWithEmailRegistered
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
