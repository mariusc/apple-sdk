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

#define WunderbarOnboarding_transmitter_timeout         10
#define WunderbarOnboarding_transmitter_service         @"2000"
#define WunderbarOnboarding_transmitter_characteristic_htuGyroLightPasskey  @"2010"
#define WunderbarOnboarding_transmitter_characteristic_micBridIRPasskey     @"2011"
#define WunderbarOnboarding_transmitter_characteristic_wifiSSID             @"2012"
#define WunderbarOnboarding_transmitter_characteristic_wifiPasskey          @"2013"
#define WunderbarOnboarding_transmitter_characteristic_wunderbarID          @"2014"
#define WunderbarOnboarding_transmitter_characteristic_wunderbarSecurity    @"2015"
#define WunderbarOnboarding_transmitter_characteristic_wunderbarURL         @"2016"

#define WunderbarOnboarding_device_timeout              10

@interface WunderbarOnboarding () <CBPeripheralManagerDelegate,CBCentralManagerDelegate>
@property (strong,nonatomic) void (^completion)(NSError* error);
@property (strong,nonatomic) NSTimer* timer;

@property (strong,nonatomic) CBPeripheralManager* peripheralManager;
@property (strong,nonatomic) RelayrTransmitter* transmitter;

@property (strong,nonatomic) CBCentralManager* centralManager;
@property (strong,nonatomic) RelayrDevice* device;
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
    NSTimeInterval const timeInterval = (!timeout) ? WunderbarOnboarding_transmitter_timeout : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForTransmitter:transmitter withCompletion:completion];
    if (!onboarding) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    // You must send this message from the thread on which the timer was installed
    onboarding.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:[NSBlockOperation blockOperationWithBlock:^{
        [WunderbarOnboarding stopOnboarding:onboarding withError:RelayrErrorTimeoutExpired];
    }] selector:@selector(main) userInfo:onboarding repeats:NO];
}

+ (void)launchOnboardingProcessForDevice:(RelayrDevice*)device timeout:(NSNumber*)timeout completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? WunderbarOnboarding_transmitter_timeout : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForDevice:device withCompletion:completion];
    if (!onboarding) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    // You must send this message from the thread on which the timer was installed
    onboarding.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:[NSBlockOperation blockOperationWithBlock:^{
        [WunderbarOnboarding stopOnboarding:onboarding withError:RelayrErrorTimeoutExpired];
    }] selector:@selector(main) userInfo:onboarding repeats:NO];
}

#pragma mark CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager*)peripheral willRestoreState:(NSDictionary*)dict
{
//    dict[CBPeripheralManagerRestoredStateAdvertisementDataKey];
//    dict[CBPeripheralManagerRestoredStateServicesKey];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheralManager
{
    switch (peripheralManager.state)
    {
        case CBPeripheralManagerStatePoweredOn:
            if (![peripheralManager isAdvertising]) { [self startAdvertisingToSetupTransmitterWith:peripheralManager]; }
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
            [WunderbarOnboarding stopOnboarding:self withError:RelayrErrorBLEUnsupported];
            break;
        case CBPeripheralManagerStateUnknown:
            [WunderbarOnboarding stopOnboarding:self withError:RelayrErrorBLEProblemUnknown];
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager*)peripheralManager didAddService:(CBService*)service error:(NSError*)error
{
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager*)peripheralManager error:(NSError*)error
{
    if (error) { return [WunderbarOnboarding stopOnboarding:self withError:error]; }
    [RLALog debug:@"Wunderbar onboarding process for transmitter has started advertising..."];
}

- (void)peripheralManager:(CBPeripheralManager*)peripheralManager didReceiveReadRequest:(CBATTRequest*)request
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

/*******************************************************************************
 * It creates an onboarding process for a wunderbar transmitter.
 ******************************************************************************/
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

/*******************************************************************************
 * It creates an onboarding process for a wunderbar device (sensor).
 ******************************************************************************/
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

/*******************************************************************************
 * It stop the onboarding process passed and execute the completion block with the passed error.
 * If <code>error</code> is <code>nil</code>, the completion block will be executed as if it were successful.
 ******************************************************************************/
+ (void)stopOnboarding:(WunderbarOnboarding*)onboardingProcess withError:(NSError*)error
{
    if (!onboardingProcess) { return; }
    
    if (onboardingProcess.timer)
    {
        if ([onboardingProcess.timer isValid]) { [onboardingProcess.timer invalidate]; }
        onboardingProcess.timer = nil;
    }
    
    if (onboardingProcess.peripheralManager)
    {
        [onboardingProcess.peripheralManager stopAdvertising];
        onboardingProcess.peripheralManager = nil;
    }
    
    if (onboardingProcess.centralManager)
    {
        [onboardingProcess.centralManager stopScan];
        onboardingProcess.centralManager = nil;
    }
    
    onboardingProcess.transmitter = nil;
    onboardingProcess.device = nil;
    
    if (onboardingProcess.completion)
    {
        onboardingProcess.completion(error);
        onboardingProcess.completion = nil;
    }
}

- (void)startAdvertisingToSetupTransmitterWith:(CBPeripheralManager*)peripheralManager
{
//    CBMutableService* service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:WunderbarOnboarding_transmitter_service] primary:YES];
//    service.characteristics = @[
//        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WunderbarOnboarding_transmitter_characteristic_htuGyroLightPasskey] properties:CBCharacteristicPropertyRead value:<#(NSData *)#> permissions:CBAttributePermissionsReadable],
//        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WunderbarOnboarding_transmitter_characteristic_micBridIRPasskey] properties:CBCharacteristicPropertyRead value:<#(NSData *)#> permissions:CBAttributePermissionsReadable],
//        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WunderbarOnboarding_transmitter_characteristic_wifiSSID] properties:CBCharacteristicPropertyRead value:<#(NSData *)#> permissions:CBAttributePermissionsReadable],
//        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WunderbarOnboarding_transmitter_characteristic_wifiPasskey] properties:CBCharacteristicPropertyRead value:<#(NSData *)#> permissions:CBAttributePermissionsReadable],
//        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WunderbarOnboarding_transmitter_characteristic_wunderbarID] properties:CBCharacteristicPropertyRead value:<#(NSData *)#> permissions:CBAttributePermissionsReadable],
//        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WunderbarOnboarding_transmitter_characteristic_wunderbarSecurity] properties:CBCharacteristicPropertyRead value:<#(NSData *)#> permissions:CBAttributePermissionsReadable],
//        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WunderbarOnboarding_transmitter_characteristic_wunderbarURL] properties:CBCharacteristicPropertyRead value:<#(NSData *)#> permissions:CBAttributePermissionsReadable]
//    ];
//    
//    [peripheralManager addService:service];
//#warning There are many "CBAdvertisementData". Explore them!
//    [peripheralManager startAdvertising:@{
//        CBAdvertisementDataLocalNameKey     : @"<#name#>",
//        CBAdvertisementDataServiceUUIDsKey  : @[service.UUID]
//    }];
}

@end
