@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLATestsConstants.h"   // Tests
#import "RelayrApp_TSetup.h"    // Tests

/*!
 *  @abstract Test the high-level methods of <code>RelayrTransmitter</code> objects.
 *
 *  @see RelayrTransmitter
 */
@interface RelayrDeviceTest : XCTestCase
@property (readonly,nonatomic) RelayrApp* app;
@property (readonly,nonatomic) RelayrUser* user;
@end

@implementation RelayrDeviceTest

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

- (void)testSetName
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    __weak RelayrUser* user = _user;
    [_user queryCloudForIoTs:^(NSError* error) {
        XCTAssertNil(error);
        
        RelayrTransmitter* transmitter = user.transmitters.anyObject;
        XCTAssertNotNil(transmitter);
        
        RelayrDevice* device = transmitter.devices.anyObject;
        XCTAssertNotNil(device);
        
        NSString* pastName = device.name;
        XCTAssertNotNil(pastName);
        
        __weak RelayrDevice* weakDevice = device;
        [device setNameWith:kTestsDeviceName completion:^(NSError* error, NSString* previousName) {
            XCTAssertNil(error);
            XCTAssertNotNil(previousName);
            XCTAssertTrue([previousName isEqualToString:pastName]);
            XCTAssertTrue([weakDevice.name isEqualToString:kTestsDeviceName]);
            
            [weakDevice setNameWith:pastName completion:^(NSError* error, NSString* previousName) {
                XCTAssertNil(error);
                [expectation fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

@end
