#import "WunderbarOnboarding.h"     // Header
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RLAError.h"                // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)
#import "CPlatforms.h"              // Relayr.framework (Utilities)

#if defined(OS_APPLE_IOS) || defined(OS_APPLE_IOS_SIMULATOR)
@import CoreBluetooth;              // Apple
#elif defined (OS_APPLE_OSX)
@import IOBluetooth;
#endif

#define WunderbarOnboarding_timeout_transmitter 10
#define WunderbarOnboarding_timeout_device      10

@interface WunderbarOnboarding () <CBPeripheralManagerDelegate,CBCentralManagerDelegate>
@property (readonly,nonatomic) CBPeripheralManager* peripheralManager;
@property (readonly,nonatomic) RelayrTransmitter* transmitter;

@property (readonly,nonatomic) CBCentralManager* centralManager;
@property (readonly,nonatomic) RelayrDevice* device;
@end

@implementation WunderbarOnboarding

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (void)launchOnboardingProcessForTransmitter:(RelayrTransmitter*)transmitter timeout:(NSNumber*)timeout completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? WunderbarOnboarding_timeout_transmitter : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RLAErrorMissingExpectedValue); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForTransmitter:transmitter];
    if (!onboarding) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:[NSBlockOperation blockOperationWithBlock:^{
        [WunderbarOnboarding stopOnboarding:onboarding andCallbackWithError:completion];
    }] selector:@selector(main) userInfo:nil repeats:NO];
}

+ (void)launchOnboardingProcessForDevice:(RelayrDevice*)device timeout:(NSNumber*)timeout completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? WunderbarOnboarding_timeout_transmitter : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RLAErrorMissingExpectedValue); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForDevice:device];
    if (!onboarding) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:[NSBlockOperation blockOperationWithBlock:^{
        [WunderbarOnboarding stopOnboarding:onboarding andCallbackWithError:completion];
    }] selector:@selector(main) userInfo:nil repeats:NO];
}

#pragma mark CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager*)peripheral willRestoreState:(NSDictionary*)dict
{
//    dict[CBPeripheralManagerRestoredStateAdvertisementDataKey];
//    dict[CBPeripheralManagerRestoredStateServicesKey];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
//    switch (peripheral.state) {
//        case CBPeripheralManagerStatePoweredOn:
//            <#statements#>
//            break;
//        case CBPeripheralManagerStatePoweredOff:
//            [RLALog debug:<#(NSString *), ...#>];
//            break;
//        case CBPeripheralManagerStateUnauthorized:
//            [RLALog debug:<#(NSString *), ...#>];
//            break;
//        case CBPeripheralManagerStateResetting:
//            [RLALog debug:<#(NSString *), ...#>];
//            break;
//        case CBPeripheralManagerStateUnsupported:
//            <#statements#>
//            break;
//        case CBPeripheralManagerStateUnknown:
//            <#statements#>
//            break;
//        default:
//            break;
//    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager*)peripheral error:(NSError*)error
{
    
}

- (void)peripheralManager:(CBPeripheralManager*)peripheral didReceiveReadRequest:(CBATTRequest*)request
{
    
}

#pragma mark - Private methods

- (instancetype)initForTransmitter:(RelayrTransmitter*)transmitter
{
    if (!transmitter.uid.length) { return nil; }
    
    self = [super init];
    if (self)
    {
//        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBPeripheralManagerOptionShowPowerAlertKey : @YES, CBPeripheralManagerOptionRestoreIdentifierKey : <#Identifier#> }];
        _transmitter = transmitter;
    }
    return self;
}

- (instancetype)initForDevice:(RelayrDevice*)device
{
    if (!device.uid.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{}];
        _device = device;
    }
    return self;
}

+ (void)stopOnboarding:(WunderbarOnboarding*)onboardingProcess andCallbackWithError:(void (^)(NSError* error))callback
{
    
}

@end
