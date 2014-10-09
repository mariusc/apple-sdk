#import "ViewController.h"
#import <Relayr/Relayr.h>
#import <Relayr/WunderbarOnboarding.h>
#import <Relayr/RelayrUser+Wunderbar.h>

@interface ViewController ()
@property (strong,nonatomic) RelayrApp* app;
@property (strong,nonatomic) RelayrUser* user;
@end

#define numMaxParallelOnboardingProcesses   2

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
            
            [_user registerWunderbarWithName:@"registerIOSWunderbar" completion:^(NSError* error, RelayrTransmitter* transmitter) {
                if (error) { printf("%s", [error.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding]); return; }
                
                [self testOnboardingOniOS];
            }];
        }];
    }];
}

- (void)testOnboardingOniOS
{
    RelayrTransmitter* transmitter = _user.transmitters.anyObject;
    NSMutableSet* devicesToOnboard = [NSMutableSet setWithSet:transmitter.devices];
    NSMutableSet* devicesBeingOnboarded = [[NSMutableSet alloc] init];
    
    for (NSUInteger i=0; i<numMaxParallelOnboardingProcesses; ++i)
    {
        RelayrDevice* device = devicesToOnboard.anyObject;
        [devicesBeingOnboarded addObject:device];
        [devicesToOnboard removeObject:device];
    }
    
    [transmitter onboardWithClass:[WunderbarOnboarding class] timeout:@60.0 options:@{ @"wifiSSID" : @"relayr", @"wifiPass" : @"wearsimaspants" } completion:^(NSError* error) {
        printf("\nStart onboarding Devices:\n");
        
        for (RelayrDevice* device in devicesBeingOnboarded)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self onboardDevice:device fromDevicesBeingOnboarded:devicesBeingOnboarded devicesToOnboard:devicesToOnboard];
            });
        }
    }];
}

- (void)onboardDevice:(RelayrDevice*)device fromDevicesBeingOnboarded:(NSMutableSet*)devicesBeingOnboarded devicesToOnboard:(NSMutableSet*)devicesToOnboard
{
    if (!device) { return; }
    
    [device onboardWithClass:[WunderbarOnboarding class] timeout:@8.0 options:nil completion:^(NSError* error) {
        [devicesBeingOnboarded removeObject:device];
        if (error)
        {
            printf("Problem onboarding device. Retrying...\n");
            [devicesToOnboard addObject:device];
        }
        else { printf("Device onboarded. %lu devices to go.\n", (unsigned long)devicesToOnboard.count + (unsigned long)devicesBeingOnboarded.count); }
        
        RelayrDevice* dev = devicesToOnboard.anyObject;
        if (!dev)
        {
            if (!devicesBeingOnboarded.count && !devicesToOnboard.count) { printf("\nOnboarding process finished!!!\n"); }
            return;
        }
        
        [devicesToOnboard removeObject:dev];
        [devicesBeingOnboarded addObject:dev];

        [self onboardDevice:dev fromDevicesBeingOnboarded:devicesBeingOnboarded devicesToOnboard:devicesToOnboard];
    }];
}

@end
