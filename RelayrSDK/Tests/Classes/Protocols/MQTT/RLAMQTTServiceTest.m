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
            
            RelayrDevice* gyroscope;
            for (RelayrDevice* device in _user.devices) { if ([device.modelID isEqualToString:@"173c44b5-334e-493f-8eb8-82c8cc65d29f"]) { gyroscope = device; break; } }
            
            if (!gyroscope) { return; }
            NSLog(@"%@", gyroscope);
            
            [RLAServiceSelector selectServiceForDevice:gyroscope completion:^(NSError* error, id<RLAService> service) {
                XCTAssertNil(error);
                XCTAssertNotNil(service);
                
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

@end
