@import Cocoa;                      // Apple
@import XCTest;                     // Apple
#import <Relayr/Relayr.h>           // Relayr
#import "RelayrApp_Setup.h"         // Relayr (Private)
#import "RelayrUser_Setup.h"        // Relayr (Private)
#import "Wunderbar.h"               // Relayr (Wunderbar)
#import "WunderbarConstants.h"      // Relayr (Wunderbar)
#import "WunderbarOnboarding.h"     // Relayr (Wunderbar)
#import "RelayrUser+Wunderbar.h"    // Relayr (Wunderbar)
#import "WunderbarFirmwareUpdate.h" // Relayr (Wunderbar)
#import "RLATestsConstants.h"       // Tests

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

- (void)tearDown
{
    [RelayrApp removeAppFromFileSystem:_app];
    [_app signOutUser:_user];
    _user = nil;
    _app = nil;
    [super tearDown];
}

#pragma mark - Unit tests

#define kWunderbarTest_numParallelOnboardingProcesses   2
#define kWunderbarTest_startingTimeDelayr               (0.2)  // Wunderbar_device_setupTimeoutForScanningProportion * Wunderbar_device_setupTimeout

- (void)testRegistrationAndOnboardingWunderbar
{
    XCTestExpectation* onboardExpectation = [self expectationWithDescription:nil];
    
    [_user registerWunderbarWithName:@"RegisterTestWunderbar" completion:^(NSError *error, RelayrTransmitter *transmitter) {
        XCTAssertNil(error);
        XCTAssertNotNil(transmitter.uid);
        
        NSSet* devices = transmitter.devices;
        XCTAssertGreaterThanOrEqual(devices.count, 6);
        
        NSDictionary* onboardTransmitterOptions = @{
            kWunderbarOnboardingOptionsTransmitterWifiSSID     : kTestsWunderbarOnboardingOptionsWifiSSID,
            kWunderbarOnboardingOptionsTransmitterWifiPassword : kTestsWunderbarOnboardingOptionsWifiPassword
        };
        
        [self onboardWunderbar:transmitter withOptions:onboardTransmitterOptions numParallelDeviceOnboardingProcesses:kWunderbarTest_numParallelOnboardingProcesses startingTimeDelay:kWunderbarTest_startingTimeDelayr expectation:onboardExpectation];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsWunderbarOnboardingTimeout handler:nil];
}

#pragma mark - Private methods

/*******************************************************************************
 * It onboards a wunderbar (transmitter + 6 devices) with the standard timeout (<code>nil</code>). This process must be run in the main queue (within the method you can change the queue where the process run).
 * The onboarding process can be done in parallel (give a number of parallell processes to run) and the parallel processes can be launched at the same time (startingDelayInSeconds=0) or every specific number of seconds (startingDelayInSeconds=n).
 ******************************************************************************/
- (void)onboardWunderbar:(RelayrTransmitter*)transmitter withOptions:(NSDictionary*)options numParallelDeviceOnboardingProcesses:(NSUInteger)numParallelProcesses startingTimeDelay:(NSTimeInterval)startingDelayInSeconds expectation:(XCTestExpectation*)expectation
{
    NSMutableSet* devicesToOnboard = [NSMutableSet setWithSet:transmitter.devices];
    NSMutableSet* devicesBeingOnboarded = [[NSMutableSet alloc] init];
    
    numParallelProcesses = (numParallelProcesses < 2) ? 1 :
                           (numParallelProcesses > 6) ? 6 : numParallelProcesses;
    
    startingDelayInSeconds = (startingDelayInSeconds <= 0) ? 0 : startingDelayInSeconds;
    
    for (NSUInteger i=0; i<numParallelProcesses; ++i)
    {
        RelayrDevice* device = devicesToOnboard.anyObject;
        [devicesBeingOnboarded addObject:device];
        [devicesToOnboard removeObject:device];
    }
    
    printf("\n\tStart onboarding transmitter...\n");
    [transmitter onboardWithClass:[WunderbarOnboarding class] timeout:nil options:options completion:^(NSError* error) {
        XCTAssertNil(error);
        printf("\tTransmitter successfully onboarded!\n\n\tStart onboarding Devices...\n");
        
        NSUInteger counter = 0;
        for (RelayrDevice* device in devicesBeingOnboarded)
        {
            if (counter == 0)
            {
                [self onboardDevice:device fromDevicesBeingOnboarded:devicesBeingOnboarded devicesToOnboard:devicesToOnboard expectation:expectation];
                ++counter;
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(startingDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self onboardDevice:device fromDevicesBeingOnboarded:devicesBeingOnboarded devicesToOnboard:devicesToOnboard expectation:expectation];
                });
            }
        }
    }];
}

/*******************************************************************************
 * It onboards a single device/sensor in a transmitter/wunderbar with the standard timeout <code>nil</code>.
 ******************************************************************************/
- (void)onboardDevice:(RelayrDevice*)device fromDevicesBeingOnboarded:(NSMutableSet*)devicesBeingOnboarded devicesToOnboard:(NSMutableSet*)devicesToOnboard expectation:(XCTestExpectation*)expectation
{
    if (!device) { return; }
    
    [device onboardWithClass:[WunderbarOnboarding class] timeout:nil options:nil completion:^(NSError* error) {
        [devicesBeingOnboarded removeObject:device];
        if (error)
        {
            printf("\tProblem onboarding device. Retrying...\t\tError: %s\n", [error.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding]);
            [devicesToOnboard addObject:device];
        }
        else { printf("\tDevice onboarded! %lu devices to go.\n", (unsigned long)devicesToOnboard.count + (unsigned long)devicesBeingOnboarded.count); }
        
        RelayrDevice* dev = devicesToOnboard.anyObject;
        if (!dev)
        {
            if (!devicesBeingOnboarded.count && !devicesToOnboard.count)
            {
                printf("\tOnboarding process finished!!!\n\n");
                [expectation fulfill];
            }
            return;
        }
        
        [devicesToOnboard removeObject:dev];
        [devicesBeingOnboarded addObject:dev];
        
        [self onboardDevice:dev fromDevicesBeingOnboarded:devicesBeingOnboarded devicesToOnboard:devicesToOnboard expectation:expectation];
    }];
}

@end
