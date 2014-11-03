@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLATestsConstants.h"   // Tests
#import "RelayrApp_TSetup.h"    // Tests

/*!
 *  @abstract Test the high-level methods of <code>RelayrUser</code> objects.
 *
 *  @see RelayrApp
 */
@interface RelayrUserTest : XCTestCase
@property (readonly,nonatomic) RelayrApp* app;
@property (readonly,nonatomic) RelayrUser* user;
@end

@implementation RelayrUserTest

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

- (void)testQueryCloudForUserInfo
{
    _user.uid = nil;
    _user.name = nil;
    _user.email = nil;
    
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_user queryCloudForUserInfo:^(NSError* error, NSString* previousName, NSString* previousEmail) {
        XCTAssertNotNil(_user.uid);
        XCTAssertNotNil(_user.name);
        XCTAssertNotNil(_user.email);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testQueryCloudForPublishersAndAuthorisedApps
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_user queryCloudForPublishersAndAuthorisedApps:^(NSError* error) {
        XCTAssertNil(error);
        XCTAssertGreaterThanOrEqual(_user.publishers.count, 1);
        XCTAssertGreaterThanOrEqual(_user.authorisedApps.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testQueryCloudForIoTs
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_user queryCloudForIoTs:^(NSError* error) {
        XCTAssertNil(error);
        XCTAssertGreaterThanOrEqual(_user.transmitters.count, 1);
        XCTAssertGreaterThanOrEqual(_user.devices.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testRegisterTransmitter_deleteTransmitter
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_user registerTransmitterWithModelID:kTestsTransmitterModel firmwareVerion:kTestsTransmitterFirmVr name:kTestsTransmitterName completion:^(NSError* error, RelayrTransmitter* transmitter) {
        XCTAssertNil(error);
        XCTAssertNotNil(transmitter);
        XCTAssertGreaterThan(transmitter.uid.length, 0);
        
        BOOL transmitterMatched = NO;
        for (RelayrTransmitter* tmpTransmitter in _user.transmitters)
        {
            if ([tmpTransmitter.uid isEqualToString:transmitter.uid]) { transmitterMatched = YES; break; }
        }
        XCTAssertTrue(transmitterMatched);
        
        [_user deleteTransmitter:transmitter completion:^(NSError* error) {
            XCTAssertNil(error);
            BOOL anotherTransmitterMatched = NO;
            for (RelayrTransmitter* tmpTransmitter in _user.transmitters)
            {
                if ([tmpTransmitter.uid isEqualToString:transmitter.uid]) { anotherTransmitterMatched = YES; break; }
            }
            XCTAssertFalse(anotherTransmitterMatched);
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testRegisterDevice_deleteDevice
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_user registerDeviceWithModelID:kTestsDeviceModel firmwareVerion:kTestsDeviceFirmwVr name:kTestsDeviceName completion:^(NSError* error, RelayrDevice* device) {
        XCTAssertNil(error);
        XCTAssertNotNil(device);
        XCTAssertGreaterThan(device.uid.length, 0);
        
        BOOL deviceMatched = NO;
        for (RelayrDevice* tmpDevice in _user.devices)
        {
            if ([tmpDevice.uid isEqualToString:device.uid]) { deviceMatched = YES; break; }
        }
        XCTAssertTrue(deviceMatched);
        
        [_user deleteDevice:device completion:^(NSError* error) {
            XCTAssertNil(error);
            BOOL anotherTransmitterMatched = NO;
            for (RelayrTransmitter* tmpDevice in _user.devices)
            {
                if ([tmpDevice.uid isEqualToString:device.uid]) { anotherTransmitterMatched = YES; break; }
            }
            XCTAssertFalse(anotherTransmitterMatched);
            for (RelayrTransmitter* tmpDevice in _user.devices)
            {
                if ([tmpDevice.uid isEqualToString:device.uid]) { anotherTransmitterMatched = YES; break; }
            }
            XCTAssertFalse(anotherTransmitterMatched);
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

@end
