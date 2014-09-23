@import Cocoa;              // Apple
@import XCTest;             // Apple
#import <Relayr/Relayr.h>   // Relayr.framework

/*!
 *  @abstract Test the high level methods of <code>RelayrCloud</code> static class.
 *
 *  @see RelayrCloud
 */
@interface TRelayrCloud : XCTestCase
@property (readonly,nonatomic) NSTimeInterval networkTimeout;
@property (readonly,nonatomic) NSString* userEmail;
@end

@implementation TRelayrCloud

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    _networkTimeout = 10;
    _userEmail = @"roberto@relayr.de";
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
    
    [self waitForExpectationsWithTimeout:self.networkTimeout handler:nil];
}

- (void)test_isUserWithEmailRegistered
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [RelayrCloud isUserWithEmail:self.userEmail registered:^(NSError* error, NSNumber* isUserRegistered) {
        XCTAssertNil(error);
        XCTAssertNotNil(isUserRegistered);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.networkTimeout handler:nil];
}

@end
