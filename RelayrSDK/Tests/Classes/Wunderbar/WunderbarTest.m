@import Cocoa;                      // Apple
@import XCTest;                     // Apple
#import <Relayr/Relayr.h>           // Relayr.framework
#import "RelayrApp_Setup.h"         // Relayr.framework (Private)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "Wunderbar.h"               // Relayr.framework (Wunderbar)
#import "WunderbarConstants.h"      // Relayr.framework (Wunderbar)
#import "WunderbarOnboarding.h"     // Relayr.framework (Wunderbar)
#import "WunderbarFirmwareUpdate.h" // Relayr.framework (Wunderbar)
#import "RLATestsConstants.h"       // Tests
#import "RelayrApp_TSetup.h"        // Tests

/*!
 *  @abstract Test the high-level methods that handle Wunderbar specific code.
 *
 *  @see Wunderbar
 *  @see RelayrOnboarding
 *  @see RelayrFirmwareUpdate
 */
@interface WunderbarTest : XCTestCase
@property (readonly,nonatomic) RelayrApp* app;
@property (readonly,nonatomic) RelayrUser* user;
@end

@implementation WunderbarTest

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

- (void)tearDown {
    [RelayrApp removeAppFromKeyChain:_app];
    [_app signOutUser:_user];
    _user = nil;
    _app = nil;
    [super tearDown];
}

#pragma mark - Unit tests

- (void)testOnboardWunderbar
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    __weak RelayrUser* user = _user;
    [_user queryCloudForIoTs:^(NSError* error) {
        XCTAssertNil(error);
        
        RelayrTransmitter* transmitter = user.transmitters.anyObject;
        XCTAssertNotNil(transmitter.uid);
        NSSet* devices = transmitter.devices;
        XCTAssertGreaterThanOrEqual(devices.count, 6);
        
        NSDictionary* onboardTransmitterOptions = @{
            kWunderbarOnboardingOptionsWifiSSID     : kTestsWunderbarOnboardingOptionsWifiSSID,
            kWunderbarOnboardingOptionsWifiPassword : kTestsWunderbarOnboardingOptionsWifiPassword
        };
        
        [transmitter onboardWithClass:[WunderbarOnboarding class] timeout:@(kTestsWunderbarOnboardingTransmitterTimeout) options:onboardTransmitterOptions completion:^(NSError* error) {
            XCTAssertNil(error);
            
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsWunderbarOnboardingTimeout handler:nil];
}

- (void)testUpdateFirmwareWunderbar
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    __weak RelayrUser* user = _user;
    [_user queryCloudForIoTs:^(NSError* error) {
        XCTAssertNil(error);
        
        RelayrTransmitter* transmitter = user.transmitters.anyObject;
        XCTAssertNotNil(transmitter.uid);
        NSSet* devices = transmitter.devices;
        XCTAssertGreaterThanOrEqual(devices.count, 6);
        
        NSDictionary* firmwareUpdateOptions = @{};
        
        [transmitter onboardWithClass:[WunderbarFirmwareUpdate class] timeout:@(kTestsWunderbarFirmwareUpdateTransmitterTimeout) options:firmwareUpdateOptions completion:^(NSError* error) {
            XCTAssertNil(error);
            
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsWunderbarFirmwareUpdateTimeout handler:nil];
}

@end
