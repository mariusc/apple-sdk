@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLAMQTTService.h"      // Relayr.framework (Service/MQTT)
#import "RelayrUser+Wunderbar.h"// Relayr.framework (Wunderbar)
#import "RLATestsConstants.h"   // Tests

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
    [RelayrApp removeAppFromFileSystem:_app];
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
            
            __block unsigned int inputsReceived = 30;

            for (RelayrDevice* device in _user.devices)
            {
                [device subscribeToAllReadingsWithBlock:^(RelayrDevice *device, RelayrReading *input, BOOL *unsubscribe) {
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

- (void)testMQTTDifferentTransmitterDevices
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_user queryCloudForUserInfo:^(NSError* error, NSString* previousName, NSString* previousEmail) {
        XCTAssertNil(error);
        
        [_user queryCloudForIoTs:^(NSError* error) {
            XCTAssertNil(error);
            
            [_user registerWunderbarWithName:@"Fake test Wunderbar" completion:^(NSError* error, RelayrTransmitter* transmitter) {
                XCTAssertNil(error);
                
                for (RelayrTransmitter* transmitter in _user.transmitters)
                {
                    for (RelayrDevice* device in transmitter.devices)
                    {
                        // TODO: Try also targets.
                        [device subscribeToAllReadingsWithBlock:^(RelayrDevice *device, RelayrReading *input, BOOL* unsubscribe) {
                            printf("Input received: %s\n", [((NSObject*)(input.value)).description cStringUsingEncoding:NSUTF8StringEncoding]);
                            [expectation fulfill];
                        } error:^(NSError* error) {
                            printf("Subscription error: %s\n", [error.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding]);
                        }];
                    }
                }
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testDeleteFakeTransmitter
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_user queryCloudForUserInfo:^(NSError* error, NSString* previousName, NSString* previousEmail) {
        XCTAssertNil(error);
        
        [_user queryCloudForIoTs:^(NSError* error) {
            XCTAssertNil(error);
            
            for (RelayrTransmitter* transmitter in _user.transmitters)
            {
                if ([transmitter.name isEqualToString:@"Fake test Wunderbar"])
                {
                    [_user deleteWunderbar:transmitter completion:nil];
                    [expectation fulfill];
                    break;
                }
            }
        }];
    }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
