#import "RLALocalUser.h"                // Header
#import "RLABluetoothService.h"         // Relayr.framework (service)

//#import "RLATemperatureSensor.h"        // Relayr.framework (sensor)
//#import "RLAHumiditySensor.h"           // Relayr.framework (sensor)
//#import "RLAColorSensor.h"              // Relayr.framework (sensor)
//#import "RLAProximitySensor.h"          // Relayr.framework (sensor)
//#import "RLAGyroscopeSensor.h"          // Relayr.framework (sensor)
//#import "RLAAccelerometerSensor.h"      // Relayr.framework (sensor)
//#import "RLANoiseSensor.h"              // Relayr.framework (sensor)
//#import "RLAWunderbarGroveOutput.h"     // Relayr.framework (output)
//#import "RLAWunderbarInfraredOutput.h"  // Relayr.framework (output)

@implementation RLALocalUser
{
    RLABluetoothService* _bleService;
}

#pragma mark - Public API

#pragma mark Class methods

+ (instancetype)user
{
    static dispatch_once_t pred;
    static RLALocalUser* sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RLALocalUser alloc] initPrivately];
    });
    return sharedInstance;
}

#pragma mark Initialisers

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil; // Only the implementation should initialise a local object
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

#pragma mark - <RLAUserDevicesAPI>

// TODO: Fill up method
- (void)devicesWithCompletionHandler:(void(^)(NSArray* devices, NSError* error))completion
{
    if (!completion) { return; }
//  
//    // Scan only for Wunderbar sensors
//    NSArray *classes = @[[RLATemperatureSensor class],
//                         [RLAHumiditySensor class],
//                         [RLAProximitySensor class],
//                         [RLAColorSensor class],
//                         [RLAGyroscopeSensor class],
//                         [RLAAccelerometerSensor class],
//                         [RLANoiseSensor class],
//                         [RLAWunderbarGroveOutput class],
//                         [RLAWunderbarInfraredOutput class]];
//  
//    [_bleService devicesWithSensorsAndOutputsOfClasses:classes timeout:1 completion:^(NSArray* devices, NSError* error) {
//        // Ignore error and return found devices
//        if ([devices count]) {
//            completion(devices, nil);
//        } else {
//            completion(nil, error);
//        }
//    }];
}

- (void)devicesWithSensorsAndOutputsOfClasses:(NSArray*)classes completion:(void (^)(NSArray*, NSError*))completion
{
    if (!completion) { return; }
    if (!classes) { completion(nil, [RLAError errorWithCode:RLAErrorCodeMissingArgument info:nil]); }
    [_bleService devicesWithSensorsAndOutputsOfClasses:classes timeout:10 completion:completion];
}

@end
