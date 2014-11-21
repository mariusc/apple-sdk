@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLAMQTTService.h"      // Relayr.framework (Service/MQTT)
#import "RLATestsConstants.h"   // Tests
#import "RelayrApp_TSetup.h"    // Tests

#import "RLAServiceSelector.h"  // FIXME: Delete

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
    XCTestExpectation* expectation = [self expectationWithDescription:nil];

    [_user queryCloudForUserInfo:^(NSError* error, NSString* previousName, NSString* previousEmail) {
        XCTAssertNil(error);
        [_user queryCloudForIoTs:^(NSError* error) {
            XCTAssertNil(error);
            
            __block unsigned int inputsReceived = 20;

            for (RelayrDevice* device in _user.devices)
            {
                [device subscribeToAllInputsWithBlock:^(RelayrDevice *device, RelayrInput *input, BOOL *unsubscribe) {
                    printf("Input received: %s\n", [((NSObject*)(input.value)).description cStringUsingEncoding:NSUTF8StringEncoding]);
                    if (--inputsReceived == 0) { [expectation fulfill]; }
                } error:^(NSError *error) {
                    XCTFail(@"%@", error);
                }];
            }
        }];
    }];

    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
