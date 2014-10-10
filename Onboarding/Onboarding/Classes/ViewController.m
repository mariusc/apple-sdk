#import "ViewController.h"
#import <Relayr/Relayr.h>
#import <Relayr/WunderbarOnboarding.h>
#import <Relayr/WunderbarConstants.h>
#import <Relayr/RelayrUser+Wunderbar.h>

@interface ViewController ()
@property (strong,nonatomic) RelayrApp* app;
@property (strong,nonatomic) RelayrUser* user;
@end

#define numMaxParallelOnboardingProcesses   2
#define parallelProcessesStartingTimeDelayr 0.2

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [RelayrApp appWithID:@"e411147f-4098-4a8e-a976-b6fe32d52f81" OAuthClientSecret:@"PuuF8IBldAHM4LxRdP95HyWUIGNBYD5O" redirectURI:@"https://relayr.io" completion:^(NSError* error, RelayrApp* app) {
        if (error) { printf("%s", [error.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding]); return; }
        _app = app;
        
        [app signInUser:^(NSError* error, RelayrUser* user) {
            if (error) { printf("%s", [error.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding]); return; }
            _user = user;
            
            [_user registerWunderbarWithName:@"RegisterTestWunderbar" completion:^(NSError *error, RelayrTransmitter *transmitter) {
                if (error) { printf("%s", [error.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding]); return; }
                
                NSDictionary* onboardTransmitterOptions = @{
                    kWunderbarOnboardingOptionsTransmitterWifiSSID     : @"relayr",
                    kWunderbarOnboardingOptionsTransmitterWifiPassword : @"wearsimaspants"
                };
                
                [self onboardWunderbar:transmitter withOptions:onboardTransmitterOptions numParallelDeviceOnboardingProcesses:numMaxParallelOnboardingProcesses startingTimeDelay:parallelProcessesStartingTimeDelayr];
            }];
        }];
    }];
}

/*******************************************************************************
 * It onboards a wunderbar (transmitter + 6 devices) with the standard timeout (<code>nil</code>). This process must be run in the main queue (within the method you can change the queue where the process run).
 * The onboarding process can be done in parallel (give a number of parallell processes to run) and the parallel processes can be launched at the same time (startingDelayInSeconds=0) or every specific number of seconds (startingDelayInSeconds=n).
 ******************************************************************************/
- (void)onboardWunderbar:(RelayrTransmitter*)transmitter withOptions:(NSDictionary*)options numParallelDeviceOnboardingProcesses:(NSUInteger)numParallelProcesses startingTimeDelay:(NSTimeInterval)startingDelayInSeconds
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
        printf("\tTransmitter successfully onboarded!\n\n\tStart onboarding Devices...\n");
        
        NSUInteger counter = 0;
        for (RelayrDevice* device in devicesBeingOnboarded)
        {
            if (counter == 0)
            {
                [self onboardDevice:device fromDevicesBeingOnboarded:devicesBeingOnboarded devicesToOnboard:devicesToOnboard];
                ++counter;
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(startingDelayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self onboardDevice:device fromDevicesBeingOnboarded:devicesBeingOnboarded devicesToOnboard:devicesToOnboard];
                });
            }
        }
    }];
}

/*******************************************************************************
 * It onboards a single device/sensor in a transmitter/wunderbar with the standard timeout <code>nil</code>.
 ******************************************************************************/
- (void)onboardDevice:(RelayrDevice*)device fromDevicesBeingOnboarded:(NSMutableSet*)devicesBeingOnboarded devicesToOnboard:(NSMutableSet*)devicesToOnboard
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
            if (!devicesBeingOnboarded.count && !devicesToOnboard.count) { printf("\tOnboarding process finished!!!\n\n"); }
            return;
        }
        
        [devicesToOnboard removeObject:dev];
        [devicesBeingOnboarded addObject:dev];
        
        [self onboardDevice:dev fromDevicesBeingOnboarded:devicesBeingOnboarded devicesToOnboard:devicesToOnboard];
    }];
}

@end
