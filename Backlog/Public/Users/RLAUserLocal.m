#import "RLAUserLocal.h"                // Header
#import "RLABluetoothService.h"         // Relayr.framework (service)
#import "RLASensorAccelerometer.h"      // Relayr.framework (sensor)
#import "RLASensorColor.h"              // Relayr.framework (sensor)
#import "RLASensorGyroscope.h"          // Relayr.framework (sensor)
#import "RLASensorHumidity.h"           // Relayr.framework (sensor)
#import "RLASensorNoise.h"              // Relayr.framework (sensor)
#import "RLASensorProximity.h"          // Relayr.framework (sensor)
#import "RLASensorTemperature.h"        // Relayr.framework (sensor)
#import "RLAOutputGrove.h"              // Relayr.framework (output)
#import "RLAOutputInfrared.h"           // Relayr.framework (output)

@implementation RLAUserLocal
{
    RLABluetoothService* _bleService;
}

#pragma mark - Public API

+ (instancetype)user
{
    static dispatch_once_t pred;
    static RLAUserLocal* sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RLAUserLocal alloc] initPrivately];
    });
    return sharedInstance;
}

// Only the implementation should initialise a local object
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark RLAUserDevicesAPI

- (void)devicesWithCompletionHandler:(void(^)(NSArray* devices, NSError* error))completion
{
    if (!completion) { return; }
    
    // Scan only for Wunderbar sensors
    NSArray* classes = @[
            [RLASensorAccelerometer class],
            [RLASensorColor class],
            [RLASensorGyroscope class],
            [RLASensorHumidity class],
            [RLASensorNoise class],
            [RLASensorProximity class],
            [RLASensorTemperature class],
            [RLAOutputGrove class],
            [RLAOutputInfrared class]
    ];
    
    [_bleService devicesWithSensorsAndOutputsOfClasses:classes timeout:1 completion:^(NSArray* devices, NSError* error) {
        (devices.count) ? completion(devices, nil) : completion(nil, error);
    }];
}

- (void)devicesWithSensorsAndOutputsOfClasses:(NSArray*)classes completion:(void (^)(NSArray*, NSError*))completion
{
    if (!completion) { return; }
    if (!classes) { completion(nil, [RLAError errorWithCode:RLAErrorCodeMissingArgument info:nil]); }
    [_bleService devicesWithSensorsAndOutputsOfClasses:classes timeout:10 completion:completion];
}

#pragma mark - Private methods

- (instancetype)initPrivately
{
    self = [super init];
    if (self) {
        _bleService = [[RLABluetoothService alloc] init];
        RLAErrorAssertTrueAndReturnNil(_bleService, RLAErrorCodeMissingExpectedValue);
    }
    return self;
}

- (RLABluetoothService*)bleService
{
    return _bleService;
}

@end
