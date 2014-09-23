#import "WunderbarOnboarding.h"     // Header
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)
#import "CPlatforms.h"              // Relayr.framework (Utilities)
#import "Wunderbar.h"               // Relayr.framework (Wunderbar)
#import "WunderbarConstants.h"      // Relayr.framework (Wunderbar)

#if defined(OS_APPLE_IOS) || defined(OS_APPLE_IOS_SIMULATOR)
@import CoreBluetooth;              // Apple
#elif defined (OS_APPLE_OSX)
@import IOBluetooth;                // Apple
#endif

NSString* const kWunderbarOnboardingOptionsWifiSSID     = @"wifiSSID";
NSString* const kWunderbarOnboardingOptionsWifiPassword = @"wifiPass";

@interface WunderbarOnboarding () <CBPeripheralManagerDelegate,CBCentralManagerDelegate>
@property (strong,nonatomic) void (^completion)(NSError* error);
@property (strong,nonatomic) NSDictionary* options;
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

+ (void)launchOnboardingProcessForTransmitter:(RelayrTransmitter*)transmitter timeout:(NSNumber*)timeout options:(NSDictionary*)options completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? Wunderbar_transmitter_setupTimeout : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForTransmitter:transmitter withOptions:options completion:completion];
    if (!onboarding) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    // You must send this message from the thread on which the timer was installed
    onboarding.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:[NSBlockOperation blockOperationWithBlock:^{
        [WunderbarOnboarding stopOnboarding:onboarding withError:RelayrErrorTimeoutExpired];
    }] selector:@selector(main) userInfo:onboarding repeats:NO];
}

+ (void)launchOnboardingProcessForDevice:(RelayrDevice*)device timeout:(NSNumber*)timeout options:(NSDictionary*)options completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? Wunderbar_device_setupTimeout : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForDevice:device withOptions:options completion:completion];
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
    if (error) { return [WunderbarOnboarding stopOnboarding:self withError:error]; }
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
        [onboardingProcess.peripheralManager removeAllServices];
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

/*******************************************************************************
 * It creates an onboarding process for a wunderbar transmitter.
 ******************************************************************************/
- (instancetype)initForTransmitter:(RelayrTransmitter*)transmitter withOptions:(NSDictionary*)options completion:(void (^)(NSError* error))completion
{
    if (!transmitter.uid.length || !options.count || ![Wunderbar isWunderbar:transmitter] || !_options[kWunderbarOnboardingOptionsWifiSSID] || !_options[kWunderbarOnboardingOptionsWifiPassword]) { return nil; }
    
    self = [super init];
    if (self)
    {   // { CBPeripheralManagerOptionRestoreIdentifierKey : <#Identifier#> }
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBPeripheralManagerOptionShowPowerAlertKey : @YES }];
        _transmitter = transmitter;
        _completion = completion;
        _options = options;
    }
    return self;
}

/*******************************************************************************
 * It creates an onboarding process for a wunderbar device (sensor).
 ******************************************************************************/
- (instancetype)initForDevice:(RelayrDevice*)device withOptions:(NSDictionary*)options completion:(void (^)(NSError* error))completion
{
    if (!device.uid.length || ![Wunderbar isDeviceSupportedByWunderbar:device]) { return nil; }
    
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
 * This method creates all the services and characteristics needed for a correct <code>RelayrTransmitter</code> setup.
 * Once the services and characteristics are created, the peripheral manager will start advertising.
 ******************************************************************************/
- (void)startAdvertisingToSetupTransmitterWith:(CBPeripheralManager*)peripheralManager
{
    CBMutableService* service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupService] primary:YES];
    
    char htuGyroLightPasskey[Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey_length];
    [[Wunderbar humidityTemperatureDeviceFromWunderbar:_transmitter].secret getCString:htuGyroLightPasskey maxLength:7 encoding:NSASCIIStringEncoding];
    [[Wunderbar gyroscopeDeviceFromWunderbar:_transmitter].secret getCString:(htuGyroLightPasskey + 6) maxLength:7 encoding:NSASCIIStringEncoding];
    [[Wunderbar lighProximityDeviceFromWunderbar:_transmitter].secret getCString:(htuGyroLightPasskey + 12) maxLength:7 encoding:NSASCIIStringEncoding];
    htuGyroLightPasskey[Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey_length - 1] = 0x07;
    
    char micBridIRPasskey[Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey_length];
    [[Wunderbar microphoneDeviceFromWunderbar:_transmitter].secret getCString:micBridIRPasskey maxLength:7 encoding:NSASCIIStringEncoding];
    [[Wunderbar bridgeDeviceFromWunderbar:_transmitter].secret getCString:(micBridIRPasskey + 6) maxLength:7 encoding:NSASCIIStringEncoding];
    [[Wunderbar infraredDeviceFromWunderbar:_transmitter].secret getCString:(micBridIRPasskey + 12) maxLength:7 encoding:NSASCIIStringEncoding];
    htuGyroLightPasskey[Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey_length - 1] = 0x07;
    
    char wifiSSID[Wunderbar_transmitter_setupCharacteristic_wifiSSID_length];
    [((NSString*)_options[kWunderbarOnboardingOptionsWifiSSID]) getCString:wifiSSID maxLength:(Wunderbar_transmitter_setupCharacteristic_wifiSSID_length-1) encoding:NSASCIIStringEncoding];
    wifiSSID[Wunderbar_transmitter_setupCharacteristic_wifiSSID_length - 1] = 0x01;
    
    char wifiPassword[Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length];
    [((NSString*)_options[kWunderbarOnboardingOptionsWifiPassword]) getCString:wifiPassword maxLength:(Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length-1) encoding:NSASCIIStringEncoding];
    wifiPassword[Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length - 1] = 0x01;
    
    char wunderbarID[Wunderbar_transmitter_setupCharacteristic_wunderbarID_length];
    #warning Make the weird transformation to bytes
    
    char wunderbarSecurity[Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity_length];
    
    
    char wunderbarURL[Wunderbar_transmitter_setupCharacteristic_wunderbarURL_length];
    
    service.characteristics = @[
        // Size: 19 bytes (6 + 6 + 6 + 1 byte of flag).
        // Description: Contains the passkeys for the HTU, GYRO, and LIGHT sensors, in ASCII format, and an update mask. The update mask is a bit mask of three update flags: one for each passkey. The lowest three bits of the value determine which passkey should be updated.
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey] properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:htuGyroLightPasskey length:Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey_length] permissions:CBAttributePermissionsReadable],
        // Size: 19 bytes  (6 + 6 + 6 + 1 byte of flag).
        // Description: Contains the passkeys for the MICROPHONE, BRIDGE, and IR sensors, in ASCII format, and an update mask. Like the HTU_GYRO_LIGHT passkey the update mask is a bit mask of three update flags.
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey] properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:micBridIRPasskey length:Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey_length] permissions:CBAttributePermissionsReadable],
        // Size: 20 bytes (max character: 19 + 1 byte of flag).
        // Description: Contains the Wifi SSID in ASCII format and an update flag. The value must be 20 characters long and finish with the update flag, therefore it is padded with zeros until it is the appropriate length.
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wifiSSID] properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:wifiSSID length:Wunderbar_transmitter_setupCharacteristic_wifiSSID_length] permissions:CBAttributePermissionsReadable],
        // Size: 20 bytes (max character: 19 + 1 byte of flag).
        // Description: Contains the Wifi password in ASCII format and an update flag. The value must be 20 bytes long and finish with the update flag, therefore it is also padded like the SSID.
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wifiPasskey] properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:wifiPassword length:Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length] permissions:CBAttributePermissionsReadable],
        // Size: 17 bytes (16 without NULL character + 1 byte of flag).
        // Description: Contains the (short) UUID of the WunderBar and an update flag.
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarID] properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:wunderbarID length:Wunderbar_transmitter_setupCharacteristic_wunderbarID_length] permissions:CBAttributePermissionsReadable],
        // Size: 13 bytes (12 + 1 byte of flag).
        // Description: Contains the secret to conncet a particular Wunderbar to MQTT.
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity] properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:wunderbarSecurity length:Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity_length] permissions:CBAttributePermissionsReadable],
        // Size: 20 bytes (terminating character and update_flag included).
        // Description: Contains the url of the MQTT server.
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarURL] properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:wunderbarURL length:Wunderbar_transmitter_setupCharacteristic_wunderbarURL_length] permissions:CBAttributePermissionsReadable]
    ];
    
    [peripheralManager addService:service];
    #warning There are many "CBAdvertisementData". Explore them!
    [peripheralManager startAdvertising:@{
        CBAdvertisementDataLocalNameKey     : @"<#name#>",
        CBAdvertisementDataServiceUUIDsKey  : @[service.UUID]
    }];
}

@end
