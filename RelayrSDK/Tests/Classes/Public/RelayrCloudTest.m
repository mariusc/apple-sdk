@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RLATestsConstants.h"   // Tests
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RelayrApp_TSetup.h"    // Tests

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

- (void)testLogMessage
{
    RelayrApp* app = [[RelayrApp alloc] initWithID:kTestsAppID OAuthClientSecret:kTestsAppSecret redirectURI:kTestsAppRedirect];
    RelayrUser* user = [[RelayrUser alloc] initWithToken:kTestsUserToken];
    user.uid = kTestsUserID;
    user.name = kTestsUserName;
    user.email = kTestsUserEmail;
    user.app = app;
    [app.users addObject:user];
    
    BOOL messageAccepted = [RelayrCloud logMessage:@"SDK Tests: log message" onBehalfOfUser:user];
    XCTAssertTrue(messageAccepted);
}

@end
