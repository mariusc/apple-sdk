@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLAMQTTService.h"      // Relayr.framework (Protocols/MQTT)
#import "RLATestsConstants.h"   // Tests
#import "RelayrApp_TSetup.h"    // Tests

/*!
 *  @abstract Test the MQTT Service.
 */
@interface RLAMQTTServiceTest : XCTestCase
@property (readonly,nonatomic) RelayrApp* app;
@property (readonly,nonatomic) RelayrUser* user;
@end

@implementation RLAMQTTServiceTest

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    
    _app = [[RelayrApp alloc] initWithID:kTestsAppID OAuthClientSecret:kTestsAppSecret redirectURI:kTestsAppRedirect];
    _user = [[RelayrUser alloc] initWithToken:kTestsUserToken];
    _user.uid = kTestsUserID;
    _user.name = kTestsUserName;
    _user.email = kTestsUserEmail;
    _user.app = _app;
    [_app.users addObject:_user];
}

- (void)tearDown
{
    [RelayrApp removeAppFromKeyChain:_app];
    [_app signOutUser:_user];
    _user = nil;
    _app = nil;
    [super tearDown];
}

#pragma mark - Unit tests

- (void)testMQTTServiceInitialisationAndConnection
{
//    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    XCTAssertNil(_user.mqttService);
    _user.mqttService = [[RLAMQTTService alloc] initWithUser:_user];
    XCTAssertNotNil(_user.mqttService);
    
//    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

@end
