#import "WunderbarOnboarding.h"     // Header
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)
#import "CPlatforms.h"              // Relayr.framework (Utilities)
#import "Wunderbar.h"               // Relayr.framework (Wunderbar)
#import "WunderbarErrors.h"         // Relayr.framework (Wunderbar)
#import "WunderbarConstants.h"      // Relayr.framework (Wunderbar)

#if defined(OS_APPLE_IOS) || defined(OS_APPLE_IOS_SIMULATOR)
@import CoreBluetooth;              // Apple
#elif defined (OS_APPLE_OSX)
@import IOBluetooth;                // Apple
#endif

NSString* const kWunderbarOnboardingOptionsTransmitterWifiSSID       = @"wifiSSID";
NSString* const kWunderbarOnboardingOptionsTransmitterWifiPassword   = @"wifiPass";

NSString* const kWunderbarOnboardingOptionsDeviceConnectionType      = @"devConn";
NSString* const kWunderbarOnboardingOptionsDeviceConnectionTypeBLE   = @"BLE";
NSString* const kWunderbarOnboardingOptionsDeviceConnectionTypeCloud = @"Cloud";
NSString* const kWunderbarOnboardingOptionsDeviceLocalName           = @"localName";

@interface WunderbarOnboarding () <CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>
@property (strong,nonatomic) void (^completion)(NSError* error);
@property (strong,nonatomic) NSDictionary* options;
@property (strong,nonatomic) NSTimer* timer;

@property (strong,nonatomic) RelayrTransmitter* transmitter;
@property (strong,nonatomic) CBPeripheralManager* peripheralManager;
@property (strong,nonatomic) CBService* peripheralManagerService;
@property (strong,nonatomic) NSMutableSet* peripheralManagerCharacteristicsRead;

@property (strong,nonatomic) RelayrDevice* device;
@property (strong,nonatomic) CBCentralManager* centralManager;
@property (strong,nonatomic) CBPeripheral* peripheralSelected;
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
    if (timeInterval <= 0.1) { if (completion) { completion(WunderbarErrorTimeoutTooLow); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForTransmitter:transmitter withOptions:options completion:completion];
    if (!onboarding) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    // You must send this message from the thread on which the timer was installed
    onboarding.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:[NSBlockOperation blockOperationWithBlock:^{
        [WunderbarOnboarding stopOnboarding:onboarding withError:RelayrErrorTimeoutExpired];
    }] selector:@selector(main) userInfo:onboarding repeats:NO];
}

+ (void)launchOnboardingProcessForDevice:(RelayrDevice*)device timeout:(NSNumber*)timeout options:(NSDictionary*)options completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const onboardingTimeout = (!timeout) ? Wunderbar_device_setupTimeout : timeout.doubleValue;
    NSTimeInterval const timeScanning = Wunderbar_device_setupTimeoutForScanningProportion * onboardingTimeout;
    if (timeScanning <= 0.1) { if (completion) { completion(WunderbarErrorTimeoutTooLow); } return; }
    
    WunderbarOnboarding* onboarding = [[WunderbarOnboarding alloc] initForDevice:device withOptions:options completion:completion];
    if (!onboarding) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSTimer* scanningTimer = [NSTimer scheduledTimerWithTimeInterval:timeScanning target:onboarding selector:@selector(scanningTimeOver:) userInfo:[NSMutableDictionary dictionary] repeats:NO];
    
    // You must send this message from the thread on which the timer was installed
    onboarding.timer = [NSTimer scheduledTimerWithTimeInterval:onboardingTimeout target:[NSBlockOperation blockOperationWithBlock:^{
        [WunderbarOnboarding stopOnboarding:onboarding withError:RelayrErrorTimeoutExpired];
    }] selector:@selector(main) userInfo:scanningTimer repeats:NO];
}

#pragma mark CBPeripheralManagerDelegate

// TODO: Restore state for the peripheral manager
//- (void)peripheralManager:(CBPeripheralManager*)peripheral willRestoreState:(NSDictionary*)dict
//{
//    dict[CBPeripheralManagerRestoredStateAdvertisementDataKey];
//    dict[CBPeripheralManagerRestoredStateServicesKey];
//}

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
    
    _peripheralManagerService = service;
    _peripheralManagerCharacteristicsRead = [NSMutableSet setWithCapacity:Wunderbar_transmitter_setupServiceCharacteristics];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager*)peripheralManager error:(NSError*)error
{
    if (error) { return [WunderbarOnboarding stopOnboarding:self withError:error]; }
    [RLALog debug:@"Wunderbar onboarding process for transmitter has started advertising..."];
}

- (void)peripheralManager:(CBPeripheralManager*)peripheralManager didReceiveReadRequest:(CBATTRequest*)request
{
    [RLALog debug:@"Receive read request..."];
    
    CBCharacteristic* characteristicTargetted = request.characteristic;
    CBUUID* serviceTargettedUUID = characteristicTargetted.service.UUID;
    if ( ![_peripheralManagerService.UUID isEqual:serviceTargettedUUID] ) { return; }
    
    NSData* dataToSend;
    CBUUID* characteristicTargettedUUID = characteristicTargetted.UUID;
    if ([characteristicTargettedUUID isEqual:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey]])
    {
        // Size: 19 bytes (6 + 6 + 6 + 1 byte of flag).
        // Description: Contains the passkeys for the HTU, GYRO, and LIGHT sensors, in ASCII format, and an update mask. The update mask is a bit mask of three update flags: one for each passkey. The lowest three bits of the value determine which passkey should be updated.
        char htuGyroLightPasskey[Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey_length];
        [[Wunderbar humidityTemperatureDeviceFromWunderbar:_transmitter].secret getCString:htuGyroLightPasskey maxLength:7 encoding:NSASCIIStringEncoding];
        [[Wunderbar gyroscopeDeviceFromWunderbar:_transmitter].secret getCString:(htuGyroLightPasskey + 6) maxLength:7 encoding:NSASCIIStringEncoding];
        [[Wunderbar lighProximityDeviceFromWunderbar:_transmitter].secret getCString:(htuGyroLightPasskey + 12) maxLength:7 encoding:NSASCIIStringEncoding];
        htuGyroLightPasskey[Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey_length - 1] = INT8_C(0x07);
        dataToSend = [NSData dataWithBytes:htuGyroLightPasskey length:Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey_length];
    }
    else if ([characteristicTargettedUUID isEqual:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey]])
    {
        // Size: 19 bytes  (6 + 6 + 6 + 1 byte of flag).
        // Description: Contains the passkeys for the MICROPHONE, BRIDGE, and IR sensors, in ASCII format, and an update mask. Like the HTU_GYRO_LIGHT passkey the update mask is a bit mask of three update flags.
        char micBridIRPasskey[Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey_length];
        [[Wunderbar microphoneDeviceFromWunderbar:_transmitter].secret getCString:micBridIRPasskey maxLength:7 encoding:NSASCIIStringEncoding];
        [[Wunderbar bridgeDeviceFromWunderbar:_transmitter].secret getCString:(micBridIRPasskey + 6) maxLength:7 encoding:NSASCIIStringEncoding];
        [[Wunderbar infraredDeviceFromWunderbar:_transmitter].secret getCString:(micBridIRPasskey + 12) maxLength:7 encoding:NSASCIIStringEncoding];
        micBridIRPasskey[Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey_length - 1] = INT8_C(0x07);
        dataToSend = [NSData dataWithBytes:micBridIRPasskey length:Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey_length];
    }
    else if ([characteristicTargettedUUID isEqual:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wifiSSID]])
    {
        // Size: 20 bytes (max character: 19 including NULL character + 1 byte of flag).
        // Description: Contains the Wifi SSID in ASCII format and an update flag. The value must be 20 characters long and finish with the update flag, therefore it is padded with zeros until it is the appropriate length.
        char wifiSSID[Wunderbar_transmitter_setupCharacteristic_wifiSSID_length];
        [((NSString*)_options[kWunderbarOnboardingOptionsTransmitterWifiSSID]) getCString:wifiSSID maxLength:(Wunderbar_transmitter_setupCharacteristic_wifiSSID_length-1) encoding:NSASCIIStringEncoding];
        wifiSSID[Wunderbar_transmitter_setupCharacteristic_wifiSSID_length - 1] = INT8_C(0x01);
        dataToSend = [NSData dataWithBytes:wifiSSID length:Wunderbar_transmitter_setupCharacteristic_wifiSSID_length];
    }
    else if ([characteristicTargettedUUID isEqual:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wifiPasskey]])
    {
        // Size: 20 bytes (max character: 19 + 1 byte of flag).
        // Description: Contains the Wifi password in ASCII format and an update flag. The value must be 20 bytes long and finish with the update flag, therefore it is also padded like the SSID.
        char wifiPassword[Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length];
        [((NSString*)_options[kWunderbarOnboardingOptionsTransmitterWifiPassword]) getCString:wifiPassword maxLength:(Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length-1) encoding:NSASCIIStringEncoding];
        wifiPassword[Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length - 1] = INT8_C(0x01);
        dataToSend = [NSData dataWithBytes:wifiPassword length:Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length];
    }
    else if ([characteristicTargettedUUID isEqual:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarID]])
    {
        // Size: 17 bytes (16 without NULL character + 1 byte of flag).
        // Description: Contains the (short) UUID of the WunderBar and an update flag.
        NSMutableData* wunderbarID = [NSMutableData dataWithData:[WunderbarOnboarding transformRelayrID:_transmitter.uid toBinaryWithMaximumLength:Wunderbar_transmitter_setupCharacteristic_wunderbarID_length]];
        int8_t flag[1] = { INT8_C(0x01) };
        [wunderbarID appendBytes:flag length:1];
        dataToSend = [NSData dataWithData:wunderbarID];
    }
    else if ([characteristicTargettedUUID isEqual:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity]])
    {
        // Size: 13 bytes (12 without NULL character + 1 byte of flag).
        // Description: Contains the secret to connect a particular Wunderbar to MQTT.
        char wunderbarSecurity[Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity_length];
        [_transmitter.secret getCString:wunderbarSecurity maxLength:Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity_length encoding:NSASCIIStringEncoding];
        wunderbarSecurity[Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity_length - 1] = INT8_C(0x01);
        dataToSend = [NSData dataWithBytes:wunderbarSecurity length:Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity_length];
    }
    else if ([characteristicTargettedUUID isEqual:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarURL]])
    {
        // Size: 20 bytes (max characters: 19 including NULL character + 1 byte of flag).
        // Description: Contains the url of the MQTT server.
        char wunderbarURL[Wunderbar_transmitter_setupCharacteristic_wunderbarURL_length];
        [Wunderbar_appleAdvertisement_MQTTServer getCString:wunderbarURL maxLength:Wunderbar_transmitter_setupCharacteristic_wunderbarURL_length encoding:NSASCIIStringEncoding];
        wunderbarURL[Wunderbar_transmitter_setupCharacteristic_wunderbarURL_length - 1] = INT8_C(0x01);
        dataToSend = [NSData dataWithBytes:wunderbarURL length:Wunderbar_transmitter_setupCharacteristic_wunderbarURL_length];
    }
    
    if (!dataToSend) { return [peripheralManager respondToRequest:request withResult:CBATTErrorRequestNotSupported]; }
    
    if (request.offset > dataToSend.length) { return [peripheralManager respondToRequest:request withResult:CBATTErrorInvalidOffset]; }
    request.value = [dataToSend subdataWithRange:NSMakeRange(request.offset, dataToSend.length - request.offset)];
    [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    
    // Mark characteristic as read
    [_peripheralManagerCharacteristicsRead addObject:characteristicTargetted];
    if (_peripheralManagerCharacteristicsRead.count >= Wunderbar_transmitter_setupServiceCharacteristics && _timer)
    {
        __strong WunderbarOnboarding* strongSelf = self;
        if ([_timer isValid]) { [_timer invalidate]; }
        _timer = nil;
        
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Wunderbar_transmitter_setupServiceCharacteristicsReadTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [WunderbarOnboarding stopOnboarding:strongSelf withError:nil];
        });
    }
}

- (void)peripheralManager:(CBPeripheralManager*)peripheralManager didReceiveWriteRequests:(NSArray*)requests
{
    for (CBATTRequest* request in requests) { [peripheralManager respondToRequest:request withResult:CBATTErrorRequestNotSupported]; }
}

#pragma mark CBCentralManagerDelegate

//- (void)centralManager:(CBCentralManager*)central willRestoreState:(NSDictionary*)dict
//{
//}

- (void)centralManagerDidUpdateState:(CBCentralManager*)centralManager
{
    switch (centralManager.state) {
        case CBCentralManagerStatePoweredOn:
        {
            [centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO, }];
            break;
        }
        case CBCentralManagerStatePoweredOff:
            [RLALog debug:RelayrErrorBLEModulePowerOff.localizedDescription];
            break;
        case CBCentralManagerStateUnauthorized:
            [RLALog debug:RelayrErrorBLEModuleUnauthorized.localizedDescription];
            break;
        case CBCentralManagerStateResetting:
            [RLALog debug:RelayrErrorBLEModuleResetting.localizedDescription];
            break;
        case CBCentralManagerStateUnsupported:
            [WunderbarOnboarding stopOnboarding:self withError:RelayrErrorBLEUnsupported];
            break;
        case CBCentralManagerStateUnknown:
            [WunderbarOnboarding stopOnboarding:self withError:RelayrErrorBLEProblemUnknown];
            break;
    }
}

- (void)centralManager:(CBCentralManager*)centralManager didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    NSString* advertisementName = advertisementData[CBAdvertisementDataLocalNameKey];
    if (!advertisementName || !RSSI || ![advertisementName isEqualToString:_options[kWunderbarOnboardingOptionsDeviceLocalName]]) { return; }
    
    CBUUID* searchedServiceUUID = [CBUUID UUIDWithString:Wunderbar_device_setupService];
    for (CBUUID* serviceUUID in advertisementData[CBAdvertisementDataServiceUUIDsKey])
    {
        if ([serviceUUID isEqual:searchedServiceUUID])
        {
            NSMutableDictionary* peripheralsDetected = ((NSTimer*)_timer.userInfo).userInfo;
            peripheralsDetected[RSSI] = peripheral;
            return;
        }
    }
}

- (void)centralManager:(CBCentralManager*)centralManager didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
    [WunderbarOnboarding stopOnboarding:self withError:error];
}

- (void)centralManager:(CBCentralManager*)centralManager didConnectPeripheral:(CBPeripheral*)peripheral
{
    _peripheralSelected.delegate = self;
    [_peripheralSelected discoverServices:nil];
}

- (void)centralManager:(CBCentralManager*)centralManager didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
    [WunderbarOnboarding stopOnboarding:self withError:error];
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
    if (error) { [WunderbarOnboarding stopOnboarding:self withError:error]; }
    
    CBService* searchedService;
    CBUUID* searchedServiceUUID = [CBUUID UUIDWithString:Wunderbar_device_setupService];
    for (CBService* service in _peripheralSelected.services)
    {
        if ([service.UUID isEqual:searchedServiceUUID])
        {
            searchedService = service;
            break;
        }
    }
    
    if (!searchedService) { [WunderbarOnboarding stopOnboarding:self withError:WunderbarErrorNoSetupServiceDetected]; }
    [_peripheralSelected discoverCharacteristics:nil forService:searchedService];
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
    if (error) { [WunderbarOnboarding stopOnboarding:self withError:error]; }
    
    CBUUID* deviceIDCharacteristic = [CBUUID UUIDWithString:Wunderbar_device_setupCharacteristic_sensorID];
    CBUUID* passkeyCharacteristic = [CBUUID UUIDWithString:Wunderbar_device_setupCharacteristic_passKey];
    CBUUID* mimflagCharacteristic = [CBUUID UUIDWithString:Wunderbar_device_setupCharacteristic_mimFlag];
    BOOL isCharacteristicForDeviceID = NO, isCharacteristicForPasskey = NO, isCharacteristicForMiMFlag = NO;
    
    for (CBCharacteristic* characteristic in service.characteristics)
    {
        if ([characteristic.UUID isEqual:deviceIDCharacteristic]) { isCharacteristicForDeviceID = YES; }
        else if ([characteristic.UUID isEqual:passkeyCharacteristic]) { isCharacteristicForPasskey = YES; }
        else if ([characteristic.UUID isEqual:mimflagCharacteristic]) { isCharacteristicForMiMFlag = YES; }
    }
    
    if (!isCharacteristicForDeviceID || !isCharacteristicForPasskey || !isCharacteristicForMiMFlag) { [WunderbarOnboarding stopOnboarding:self withError:WunderbarErrorNoSetupCharacteristicDetected]; }
    
    [self setupWunderbarDeviceWithPreviouslySetupCharacteristicUUID:nil];
}

- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    if (error) { [WunderbarOnboarding stopOnboarding:self withError:error]; }
    
    [NSTimer scheduledTimerWithTimeInterval:Wunderbar_device_setupTimeoutForDisconnectingDevice target:[NSBlockOperation blockOperationWithBlock:^{
        [self setupWunderbarDeviceWithPreviouslySetupCharacteristicUUID:characteristic.UUID];
    }] selector:@selector(main) userInfo:nil repeats:NO];
}

#pragma mark - Private methods

/*******************************************************************************
 * It creates an onboarding process for a wunderbar transmitter.
 ******************************************************************************/
- (instancetype)initForTransmitter:(RelayrTransmitter*)transmitter withOptions:(NSDictionary*)options completion:(void (^)(NSError* error))completion
{
    if (!transmitter.uid.length || !options.count || ![Wunderbar isWunderbar:transmitter] || !options[kWunderbarOnboardingOptionsTransmitterWifiSSID] || !options[kWunderbarOnboardingOptionsTransmitterWifiPassword]) { return nil; }
    
    self = [super init];
    if (self)
    {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBPeripheralManagerOptionShowPowerAlertKey : @YES/*, CBPeripheralManagerOptionRestoreIdentifierKey : <#Identifier#>*/ }];
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
    NSString* localName = [Wunderbar advertisementLocalNameForWunderbarDevice:device];
    if (!device.uid.length || !localName) { return nil; }
    
    self = [super init];
    if (self)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey: @YES, /*CBCentralManagerOptionRestoreIdentifierKey : @"<#identifier#>"*/ }];
        _device = device;
        _completion = completion;
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:options];
        dict[kWunderbarOnboardingOptionsDeviceLocalName] = localName;
        _options = [[NSDictionary alloc] initWithDictionary:dict];
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
    service.characteristics = @[
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable],
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable],
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wifiSSID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable],
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wifiPasskey] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable],
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable],
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable],
        [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:Wunderbar_transmitter_setupCharacteristic_wunderbarURL] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable]
    ];
    
    [peripheralManager addService:service];

    if (self.peripheralManager)
    {
        [peripheralManager startAdvertising:@{
                CBAdvertisementDataLocalNameKey     : Wunderbar_appleAdvertisement_localName,
                CBAdvertisementDataServiceUUIDsKey  : @[service.UUID],
                CBAdvertisementDataIsConnectable    : @YES
        }];
    }
}

/*******************************************************************************
 * This method is called once the scanning period has expired.
 * The method will look at the
 ******************************************************************************/
- (void)scanningTimeOver:(NSTimer*)scanningTimer
{
    [_centralManager stopScan];
    
    NSMutableDictionary* peripheralsDetected = scanningTimer.userInfo;
    if (!peripheralsDetected.count) { return [WunderbarOnboarding stopOnboarding:self withError:WunderbarErrorNoDevicesDetected]; }
    
    __block NSNumber* rssi;
    [peripheralsDetected enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!rssi)
        {
            rssi = key;
            _peripheralSelected = obj;
        }
        else if ([rssi compare:key] == NSOrderedAscending)
        {
            rssi = key;
            _peripheralSelected = obj;
        }
    }];
    
    if (!_peripheralSelected) { return [WunderbarOnboarding stopOnboarding:self withError:WunderbarErrorNoDevicesDetected]; }
    [_centralManager connectPeripheral:_peripheralSelected options:nil];
}

/*******************************************************************************
 * This methods writes gets and writes the setup values for the specific Wunderbar device/sensor.
 ******************************************************************************/
- (void)setupWunderbarDeviceWithPreviouslySetupCharacteristicUUID:(CBUUID*)previousCharacteristicUUID
{   // The timer delay is performed by the didWriteValueForCharacteristic:
    CBCharacteristic* selectedCharacteristic;
    NSData* dataToSend;
    
    CBUUID* serviceUUID = [CBUUID UUIDWithString:Wunderbar_device_setupService];
    CBUUID* deviceIDCharacteristicUUID = [CBUUID UUIDWithString:Wunderbar_device_setupCharacteristic_sensorID];
    CBUUID* devicePassCharacteristicUUID = [CBUUID UUIDWithString:Wunderbar_device_setupCharacteristic_passKey];
    CBUUID* deviceFlagCharacteristicUUID = [CBUUID UUIDWithString:Wunderbar_device_setupCharacteristic_mimFlag];
    
    if (!previousCharacteristicUUID)
    {   // Write first the sensor ID
        dataToSend = [WunderbarOnboarding transformRelayrID:_device.uid toBinaryWithMaximumLength:Wunderbar_device_setupCharacteristic_wunderbarID_length];
        selectedCharacteristic = [self selectCharacteristicWithUUID:deviceIDCharacteristicUUID ofServiceUUID:serviceUUID inPeripheral:_peripheralSelected];
    }
    else if ([previousCharacteristicUUID isEqual:deviceIDCharacteristicUUID])
    {   // Write then, the passkey
        dataToSend = [_device.secret dataUsingEncoding:NSASCIIStringEncoding];
        selectedCharacteristic = [self selectCharacteristicWithUUID:devicePassCharacteristicUUID ofServiceUUID:serviceUUID inPeripheral:_peripheralSelected];
    }
    else if ([previousCharacteristicUUID isEqual:devicePassCharacteristicUUID])
    {   // Write then the "Man in the middle flag"
        uint8_t const flag[Wunderbar_device_setupCharacteristic_MiMFlag_length] = { UINT8_C(1) };
        dataToSend = [NSData dataWithBytes:&flag length:Wunderbar_device_setupCharacteristic_MiMFlag_length];
        selectedCharacteristic = [self selectCharacteristicWithUUID:deviceFlagCharacteristicUUID ofServiceUUID:serviceUUID inPeripheral:_peripheralSelected];
    }
    else if ([previousCharacteristicUUID isEqual:deviceFlagCharacteristicUUID])
    {   // When everything is writen, call the "stopOnboarding.." methods (it will close the connection).
        printf("\n\nDevice with local name: %s has been sucessfully onboarded\n\n", [(_options[kWunderbarOnboardingOptionsDeviceLocalName]) cStringUsingEncoding:NSUTF8StringEncoding]);
        return [WunderbarOnboarding stopOnboarding:self withError:nil];
    }
    
    if (!selectedCharacteristic || !dataToSend) { return [WunderbarOnboarding stopOnboarding:self withError:RelayrErrorBLEProblemUnknown]; }
    [_peripheralSelected writeValue:dataToSend forCharacteristic:selectedCharacteristic type:CBCharacteristicWriteWithResponse];
}

/*******************************************************************************
 * It selects a BLE characteristics of a specific service from a specific device.
 ******************************************************************************/
- (CBCharacteristic*)selectCharacteristicWithUUID:(CBUUID*)characteristicUUI ofServiceUUID:(CBUUID*)serviceUUID inPeripheral:(CBPeripheral*)peripheral
{
    if (!peripheral || !serviceUUID || !characteristicUUI) { return nil; }
    
    CBService* selectedService;
    for (CBService* service in peripheral.services)
    {
        if ([service.UUID isEqual:serviceUUID]) { selectedService = service; break; }
    }
    
    if (!selectedService) { return nil; }
    
    CBCharacteristic* selectedCharacteristic;
    for (CBCharacteristic* characteristic in selectedService.characteristics)
    {
        if ([characteristic.UUID isEqual:characteristicUUI]) { selectedCharacteristic = characteristic; break; }
    }
    
    return selectedCharacteristic;
}

/*******************************************************************************
 * It transforms the Relayr ID of a transmitter/device from a String to a binary version.
 * The Relayr ID of a server entity has a specific hexadecimal form, where groups are separated by dashes. To obtain the binary form, you need to remove the dashes and transform each par of character into a byte.
 ******************************************************************************/
+ (NSData*)transformRelayrID:(NSString*)relayrID toBinaryWithMaximumLength:(size_t const)maximumLength
{
    char const* buffer = [[relayrID stringByReplacingOccurrencesOfString:@"-" withString:@""] cStringUsingEncoding:NSASCIIStringEncoding];
    
    size_t const length = strlen(buffer);   // The NULL character is not included in the count.
    if (length%2 == 1) { return nil; }
    
    size_t const result_length = length/(size_t)2;
    if (maximumLength < result_length) { return nil; }
    unsigned char result[result_length];
    
    for (size_t i=0, j=0; i<length; i+=2, j+=1)
    {
        char const tmpString[] = { buffer[i], buffer[i+1], '\0' };
        result[j] = (unsigned char)strtol(tmpString, NULL, 16);
    }
    
    return [NSData dataWithBytes:result length:result_length];
}

/*******************************************************************************
 * It stop the onboarding process passed and execute the completion block with the passed error.
 * If <code>error</code> is <code>nil</code>, the completion block will be executed as if it were successful.
 ******************************************************************************/
+ (void)stopOnboarding:(WunderbarOnboarding*)onboardingProcess withError:(NSError*)error
{
    if (!onboardingProcess) { return; }
    
    void (^completion)(NSError* error) = onboardingProcess.completion;
    onboardingProcess.completion = nil;
    onboardingProcess.options = nil;
    if (onboardingProcess.timer)
    {
        id userInfo = onboardingProcess.timer.userInfo;
        if ([userInfo isKindOfClass:[NSTimer class]] && [(NSTimer*)userInfo isValid]) { [(NSTimer*)userInfo invalidate]; }
        
        if ([onboardingProcess.timer isValid]) { [onboardingProcess.timer invalidate]; }
        onboardingProcess.timer = nil;
    }
    
    onboardingProcess.transmitter = nil;
    if (onboardingProcess.peripheralManager)
    {
        if ([onboardingProcess.peripheralManager isAdvertising]) { [onboardingProcess.peripheralManager stopAdvertising]; }
        [onboardingProcess.peripheralManager removeAllServices];
        onboardingProcess.peripheralManager = nil;
    }
    onboardingProcess.peripheralManagerService = nil;
    onboardingProcess.peripheralManagerCharacteristicsRead = nil;
    
    onboardingProcess.device = nil;
    if (onboardingProcess.centralManager)
    {
        [onboardingProcess.centralManager stopScan];
        if (onboardingProcess.peripheralSelected)
        {
            [onboardingProcess.centralManager cancelPeripheralConnection:onboardingProcess.peripheralSelected];
            onboardingProcess.peripheralSelected = nil;
        }
        onboardingProcess.centralManager = nil;
    }
    
    if (completion) { completion(error); }
}

@end
