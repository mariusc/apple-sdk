@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLATestsConstants.h"   // Tests

/*!
 *  @abstract Test the high-level methods of <code>RelayrTransmitter</code> objects.
 *
 *  @see RelayrTransmitter
 */
@interface RelayrTransmitterTest : XCTestCase
@property (readonly,nonatomic) RelayrApp* app;
@property (readonly,nonatomic) RelayrUser* user;
@end

@implementation RelayrTransmitterTest

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
    [RelayrApp removeAppFromFileSystem:_app];
    [_app signOutUser:_user];
    _user = nil;
    _app = nil;
    [super tearDown];
}

#pragma mark - Unit tests

- (void)testTransmitterInstance
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    __weak RelayrUser* user = _user;
    [_user queryCloudForIoTs:^(NSError* error) {
        XCTAssertNil(error);
        
        NSSet* transmitters = user.transmitters;
        XCTAssertGreaterThan(transmitters.count, 0);
        
        RelayrTransmitter* trans = transmitters.anyObject;
        XCTAssertGreaterThan(trans.uid.length, 1);
        XCTAssertGreaterThan(trans.name.length, 1);
        XCTAssertGreaterThan(trans.owner.length, 1);
        XCTAssertGreaterThan(trans.secret.length, 1);
        XCTAssertGreaterThanOrEqual(trans.devices.count, 6);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testSetName
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    __weak RelayrUser* user = _user;
    [_user queryCloudForIoTs:^(NSError* error) {
        XCTAssertNil(error);
        
        RelayrTransmitter* transmitter = user.transmitters.anyObject;
        XCTAssertNotNil(transmitter);
        
        NSString* pastName = transmitter.name;
        XCTAssertNotNil(pastName);
        
        __weak RelayrTransmitter* weakTransmitter = transmitter;
        [transmitter setNameWith:kTestsTransmitterName completion:^(NSError* error, NSString* previousName) {
            XCTAssertNil(error);
            XCTAssertNotNil(previousName);
            XCTAssertTrue([previousName isEqualToString:pastName]);
            XCTAssertTrue([weakTransmitter.name isEqualToString:kTestsTransmitterName]);
            
            [weakTransmitter setNameWith:pastName completion:^(NSError* error, NSString* previousName) {
                XCTAssertNil(error);
                [expectation fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testConvenienceRetrievalMethods
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    __weak RelayrUser* user = _user;
    [_user queryCloudForIoTs:^(NSError* error) {
        XCTAssertNil(error);
        XCTAssertGreaterThanOrEqual(_user.transmitters.count, 1);
        XCTAssertGreaterThanOrEqual(_user.devices.count, 1);
        
        RelayrTransmitter* transmitter = user.transmitters.anyObject;
        XCTAssertNotNil(transmitter);
        
        NSSet* devices = [transmitter devicesWithReadingMeanings:@[kTestsMeaningsAcceleration]];
        XCTAssertEqual(devices.count, 1);
        
        devices = [transmitter devicesWithReadingMeanings:@[kTestsMeaningsAcceleration,kTestsMeaningsColor,kTestsMeaningsAngularSpeed,kTestsMeaningsNoiseLevel]];
        XCTAssertEqual(devices.count, 3);
        
        NSSet* readings = [transmitter readingsWithMeanings:@[kTestsMeaningsAcceleration]];
        XCTAssertEqual(readings.count, 1);
        
        readings = [transmitter readingsWithMeanings:@[kTestsMeaningsAcceleration,kTestsMeaningsColor,kTestsMeaningsAngularSpeed,kTestsMeaningsNoiseLevel]];
        XCTAssertEqual(readings.count, 4);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

@end
