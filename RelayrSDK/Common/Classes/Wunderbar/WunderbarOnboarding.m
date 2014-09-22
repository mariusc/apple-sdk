#import "WunderbarOnboarding.h"     // Header
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)
#import "CPlatforms.h"              // Relayr.framework (Utilities)

#if defined(OS_APPLE_IOS) || defined(OS_APPLE_IOS_SIMULATOR)
@import CoreBluetooth;              // Apple
#elif defined (OS_APPLE_OSX)
@import IOBluetooth;                // Apple
#endif

#define WunderbarOnboarding_timeout_transmitter 10
#define WunderbarOnboarding_timeout_device      10

@interface WunderbarOnboarding () <CBPeripheralManagerDelegate,CBCentralManagerDelegate>
@property (readonly,nonatomic) void (^completion)(NSError* error);

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
    if (!timeInterval <= 0.0) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForTransmitter:transmitter withCompletion:completion];
    if (!onboarding) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:[NSBlockOperation blockOperationWithBlock:^{
//        [WunderbarOnboarding stopOnboarding:onboarding withError:<#(NSError *)#>];
    }] selector:@selector(main) userInfo:nil repeats:NO];
}

+ (void)launchOnboardingProcessForDevice:(RelayrDevice*)device timeout:(NSNumber*)timeout completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? WunderbarOnboarding_timeout_transmitter : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForDevice:device withCompletion:completion];
    if (!onboarding) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:[NSBlockOperation blockOperationWithBlock:^{
//        [WunderbarOnboarding stopOnboarding:onboarding withError:<#(NSError *)#>];
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
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
//            <#statements#>
            break;
        case CBPeripheralManagerStatePoweredOff:
            [RLALog debug:RelayrErrorBLEModulePowerOff.localizedDescription];
            break;
        case CBPeripheralManagerStateUnauthorized:
            [RLALog debug:RelayrErrorBLEModuleUnauthorized.localizedDescription];
            break;
        case CBPeripheralManagerStateResetting:
            [RLALog debug:RelayrErrorBLEModuleResetting.localizedDescription];
            break;
        case CBPeripheralManagerStateUnsupported:
//            [WunderbarOnboarding stopOnboarding:self callbackError:<#^(NSError *error)callback#>]
            break;
        case CBPeripheralManagerStateUnknown:
//            <#statements#>
            break;
        default:
            break;
    }
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

#pragma mark CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager*)central willRestoreState:(NSDictionary*)dict
{
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
    
}

#pragma mark - Private methods

- (instancetype)initForTransmitter:(RelayrTransmitter*)transmitter withCompletion:(void (^)(NSError* error))completion
{
    if (!transmitter.uid.length) { return nil; }
    
    self = [super init];
    if (self)
    {   // { CBPeripheralManagerOptionRestoreIdentifierKey : <#Identifier#> }
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBPeripheralManagerOptionShowPowerAlertKey : @YES }];
        _transmitter = transmitter;
        _completion = completion;
    }
    return self;
}

- (instancetype)initForDevice:(RelayrDevice*)device withCompletion:(void (^)(NSError* error))completion
{
    if (!device.uid.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{}];
        _device = device;
        _completion = completion;
    }
    return self;
}

+ (void)stopOnboarding:(WunderbarOnboarding*)onboardingProcess withError:(NSError*)error
{
    
}

@end
