#import "WunderbarOnboarding.h"     // Header
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RLAError.h"                // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)
@import CoreBluetooth;              // Apple

#define WunderbarOnboarding_timeout_transmitter 10
#define WunderbarOnboarding_timeout_device      10

@interface WunderbarOnboarding () <CBPeripheralManagerDelegate>
@property (readonly,nonatomic) CBPeripheralManager* peripheralManager;
@property (readonly,nonatomic) RelayrTransmitter* transmitter;

@property (readonly,nonatomic) CBCentralManager* centralManager;
@property (readonly,nonatomic) RelayrDevice* device;
@end

@implementation WunderbarOnboarding

#pragma mark - Public API

+ (void)launchOnboardingProcessForTransmitter:(RelayrTransmitter*)transmitter timeout:(NSNumber*)timeout completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? WunderbarOnboarding_timeout_transmitter : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RLAErrorMissingExpectedValue); } return; }
    
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForTransmitter:transmitter];
    if (!onboarding) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    [WunderbarOnboarding addOnboardProcess:onboarding];
    
//    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:<#(NSTimeInterval)#> target:<#(id)#> selector:<#(SEL)#> userInfo:<#(id)#> repeats:<#(BOOL)#>];
}

+ (void)launchOnboardingProcessForDevice:(RelayrDevice*)device timeout:(NSNumber*)timeout completion:(void (^)(NSError* error))completion
{
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForDevice:device];
    if (!onboarding) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    [WunderbarOnboarding addOnboardProcess:onboarding];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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

@end
