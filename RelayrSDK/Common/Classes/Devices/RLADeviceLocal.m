@import CoreBluetooth;              // Apple

#import "RLADeviceLocal.h"          // Header
#import "RLADevice_Setup.h"         // Extension
#import "RLADeviceLocal_Setup.h"    // Extension

#import "RLASensor_Setup.h"         // Relayr.framework
#import "RLAOutput.h"               // Relayr.framework

#import "RLABluetoothManager.h"     // Relayr.framework
#import "RLAHandlerInfo.h"          // Relayr.framework

@implementation RLADeviceLocal
{
    RLABluetoothManager* _manager;
    NSMutableSet* _storedCharacteristics;
    NSMutableArray* _readHandlers;
    void (^_writeHandler)(CBPeripheral* ,CBCharacteristic*, NSError*);
    void (^_startHandler)(NSError*);
    void (^_stopHandler)(NSError*);
}

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber *)RSSI
{
    return _peripheral.RSSI;
}

- (void)setData:(NSData *)data forServiceWithUUID:(NSString *)serviceUUID forCharacteristicWithUUID:(NSString *)characteristicUUID completion:(void(^)(CBPeripheral*, CBCharacteristic*, NSError*))completion;
{
    RLAErrorAssertTrueAndReturn(serviceUUID, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(characteristicUUID, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
    
    // Callback with error if the device is not connected
    if ( !self.isConnected )
    {
        NSError *error = [RLAError errorWithCode:RLAErrorCodeConnectionError localizedDescription:@"Could not write data" failureReason:@"Device is not connected"];
        completion(nil, nil, error);
    }
    
    // Callback with error if a write operation is already in progress
    if (_writeHandler)
    {
        NSError *error = [RLAError errorWithCode:RLAErrorCodeAPIMisuse localizedDescription:@"Could not write data" failureReason:@"A write operation is already in progres and only one write operations is allowed at a time"];
        completion(nil, nil, error);
    }
    
    // Store completion handler
    _writeHandler = completion;
    
    // Find characteristic with matching UUID on peripheral ans set value
    for (CBService* service in _peripheral.services)
    {
        if ( ![[service.UUID UUIDString] isEqualToString:serviceUUID] ) { continue; }
        
        for (CBCharacteristic* characteristic in service.characteristics)
        {
            if ( ![[characteristic.UUID UUIDString] isEqualToString:characteristicUUID] ) { continue; }
            [_peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            break;
        }
        
        break;
    }
}

#pragma mark Base class

- (BOOL)isConnected
{
    return (_peripheral.state == CBPeripheralStateConnected);
}

- (void)connectWithSuccessHandler:(void(^)(NSError*))handler
{
    RLAErrorAssertTrueAndReturn(handler, RLAErrorCodeMissingArgument);
    NSAssert( !(_peripheral.state == CBPeripheralStateConnected), @"Device is already connected." );
    
    // Subscribe for updates on each characteristic
    _startHandler = handler;
    if (!self.isConnected) { [self connect]; }
}

- (void)disconnectWithSuccessHandler:(void(^)(NSError*))handler
{
    // Handlers are also used as state indicators in order to check if connection was lost or terminated on purpose. Therefore NULL value handlers are not allowed
    if (!handler) { handler = ^(NSError* e){}; }
    
    // Unsubscribe from updates on each characteristic
    _stopHandler = handler;
    for (CBService* service in _peripheral.services)
    {
        for (CBCharacteristic* characteristic in service.characteristics)
        {
            [_peripheral setNotifyValue:NO forCharacteristic:characteristic];
        }
    }
    
    [_manager.centralManager cancelPeripheralConnection:_peripheral];
}


- (void)setOutputs:(NSArray *)outputs
{
    super.outputs = outputs;
    
    // Monitor changes of all outputs "data" properties in order to propagate the data to the device
    for (RLAOutput* output in self.outputs)
    {
        [output addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

#pragma mark - Extensions

#pragma mark RLADeviceLocal_Setup

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral andListenerManager:(RLABluetoothManager *)manager
{
    RLAErrorAssertTrueAndReturnNil(peripheral, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(manager, RLAErrorCodeMissingArgument);

    self = [super init];
    if (self)
    {
        _peripheral = peripheral;
        self.name = _peripheral.name;
        self.manufacturer = @"undefined";
        self.uid = [_peripheral.identifier UUIDString];

        // Register for service notifications
        _manager = manager;
        [_manager addListener:self forPeripheral:peripheral];

        // Setup storage arrays
        _storedCharacteristics = [NSMutableSet set];
        _readHandlers = [NSMutableArray array];
        
        // Scan peripheral
        _peripheral.delegate = _manager;
    }
    return self;
}

- (void)setRelayrPairing:(RLADeviceLocalPairing)pairing completion:(void(^)(NSError*))completion
{
    RLAErrorAssertTrueAndReturn( pairing!=RLADeviceLocalPairingUnknown, RLAErrorCodeAPIMisuse );
    
    // Setup flag
    uint8_t const d[1] = { (pairing==RLADeviceLocalPairingAny) ? 0 : 1 };
    NSData* flag = [NSData dataWithBytes:(void const*)d length:sizeof(unsigned char)];
    
    // Write data
    [self setData:flag forServiceWithUUID:@"2001" forCharacteristicWithUUID:@"2019" completion: ^(CBPeripheral *p, CBCharacteristic *c, NSError *error) {
        completion(error);
    }];
}

#pragma mark - Protocols

#pragma mark RLABluetoothListenerDelegate

- (void)manager:(RLABluetoothManager*)manager didConnectPeripheral:(CBPeripheral *)peripheral
{
    _peripheral = peripheral;           // Store updated peripheral instance
    [peripheral discoverServices:nil];  // Discover all available services
}

- (void)manager:(RLABluetoothManager*)manager didDisconnectPeripheral:(CBPeripheral *)peripheral
{
    [self updateRelayrStateAndPairing]; // Update device state
    _peripheral = peripheral;               // Store updated peripheral instance
    
    if (_stopHandler)
    {
        // Invoke callback block if connection was stopped intentionally
        _stopHandler(nil);
        _stopHandler = nil;
    }
    else
    {
        // Invoke error callback if connection was lost
        NSError *error = [RLAError errorWithCode:RLAErrorCodeUnknownConnectionError localizedDescription:@"Connection lost" failureReason:@"Unknow reason"];
        if (self.errorHandler) { self.errorHandler(error); }
    }
}

- (void)manager:(RLABluetoothManager*)manager peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self updateRelayrStateAndPairing]; // Update device state
    
    // Invoke callback handler
    if (_startHandler)
    {
        _startHandler(nil);
        _startHandler = nil;
    }
    
    // Subscription to actual values stored in the characteristics only happens after an observer was added, see <RLASensorDelegate>. Subscribing to updates right here reliably disrupts the bluetooth stack when connections to lots of devices are scheduled. Therefore subscription to the characteristics is beeing delayed until they are really needed (== observed)
    // Sensor observation was stopped before but observers are still subscribed. Kick off monitoring characteristics again
    BOOL anySensorObserving = NO;
    for (RLASensor* sensor in self.sensors)
    {
        if ([sensor observationInfo])
        {
            anySensorObserving = YES;
            continue;
        }
    }
    if (anySensorObserving)
    {
        for (CBService *service in _peripheral.services)
        {
            for (CBCharacteristic* characteristic in service.characteristics)
            {
                [_peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

- (void)manager:(RLABluetoothManager*)manager peripheral:(CBPeripheral *)peripheral didUpdateData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Invoke and remove callback handler in case one was stored for this characteristic
    for (RLAHandlerInfo* info in _readHandlers)
    {
        if ( ![info.serviceUUID isEqualToString:[characteristic.service.UUID UUIDString]] ||
             ![info.characteristicUUID isEqualToString:[characteristic.UUID UUIDString]] ) { continue; }
        
        info.handler(data, error);
        [_readHandlers removeObject:info];
        return;
    }
}

- (void)manager:(RLABluetoothManager*)manager peripheral:(CBPeripheral *)peripheral didUpdateValue:(NSDictionary *)value withSensorClass:(Class)class forCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Populate matching sensor with value
    RLASensor* sensor = [self sensorOfClass:class];
    RLAErrorAssertTrueAndReturn(sensor, RLAErrorCodeMissingExpectedValue);
    
    Class sensorValueClass = sensor.sensorValueClass;
    RLAErrorAssertTrueAndReturn(sensorValueClass, RLAErrorCodeMissingExpectedValue);
    
    sensor.value = [[sensorValueClass alloc] initWithDictionary:value];
    
    // Store characteristic in order to prevent premature deallocation
    [_storedCharacteristics addObject:characteristic];
    
    // Invoke callback block
    if (_startHandler)
    {
        _startHandler(error);
        _startHandler = nil;
    }
    
    [RLALog debug:@"didUpdateValue: %@", value];
}

- (void)manager:(RLABluetoothManager*)manager peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    RLAErrorAssertTrueAndReturn(_writeHandler, RLAErrorCodeMissingExpectedValue);

    [self updateRelayrStateAndPairing]; // Update device state
    
    void (^writeHandler)(CBPeripheral* ,CBCharacteristic*, NSError*) = _writeHandler;
    _writeHandler = nil;
    writeHandler(peripheral, characteristic, error);
}

#pragma mark RLASensorDelegate

- (void)sensorDidAddObserver:(RLASensor *)sensor
{
    // Subscribe for updates on each characteristic
    if ( ![sensor observationInfo] )
    {
        for (CBService* service in _peripheral.services)
        {
            for (CBCharacteristic* characteristic in service.characteristics)
            {
                [_peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

- (void)sensorDidRemoveObserver:(RLASensor *)sensor
{
    // Stop notifications when no object is listening any more
    if ( ![sensor observationInfo] )
    {
        for (CBService *service in _peripheral.services)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                [_peripheral setNotifyValue:NO forCharacteristic:characteristic];
            }
        }
    }
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Output changed
    if ( [object isKindOfClass:[RLAOutput class]] )
    {
        // Write data to matching characteristic
        RLAOutput* output = (RLAOutput*)object;
        for (CBService *service in _peripheral.services)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                if ( [[characteristic.UUID UUIDString] isEqualToString:[output uid]] )
                {
                    [_peripheral writeValue:output.data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    return;
                }
            }
        }
        
        // Data could not be sent. Callback with error
        NSString *failureReason = [NSString stringWithFormat:@"No characteristic matching uid: %@", output.uid];
        NSError *error = [RLAError errorWithCode:RLAErrorCodeMissingExpectedValue localizedDescription:@"Writing data to output failed" failureReason:failureReason];
        if (self.errorHandler) { self.errorHandler(error); }
    }
}

#pragma mark - Private methods

- (void)dataForServiceWithUUID:(NSString*)serviceUUID forCharacteristicWithUUID:(NSString*)characteristicUUID completion:(void(^)(NSData*, NSError*))completion
{
    RLAErrorAssertTrueAndReturn(serviceUUID, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(characteristicUUID, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
    
    // Callback with error error if the device is not connected
    //  if (!self.isConnected) {
    //    NSError *error =
    //    [RLAError errorWithCode:RLAErrorCodeConnectionError
    //       localizedDescription:@"Could not write data"
    //              failureReason:@"Device is not connected"];
    //    completion(nil, error);
    //  }
    
    // Store completion handler
    RLAHandlerInfo* info = [[RLAHandlerInfo alloc] initWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID handler:completion];
    RLAErrorAssertTrueAndReturn(info, RLAErrorCodeMissingExpectedValue);
    [_readHandlers addObject:info];
    
    // Find characteristic with matching UUID on peripheral ans read value
    for (CBService* service in _peripheral.services)
    {
        if ( ![[service.UUID UUIDString] isEqualToString:serviceUUID] ) { continue; }
        
        for (CBCharacteristic* characteristic in service.characteristics)
        {
            if ( ![[characteristic.UUID UUIDString] isEqualToString:characteristicUUID] ) { continue; }
            
            [_peripheral readValueForCharacteristic:characteristic];
            return;
        }
    }
}

- (void)connect
{
    if ( _peripheral.services )
    {
        for (CBService* service in _peripheral.services)
        {
            for (CBCharacteristic* characteristic in service.characteristics)
            {
                [_peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
    else { [_manager.centralManager connectPeripheral:_peripheral options:nil]; }
}

- (void)updateRelayrStateAndPairing
{
    // Derive device state from available services
    RLADeviceLocalState state = RLADeviceLocalStateUnknown;
    RLADeviceLocalPairing pairing = RLADeviceLocalPairingUnknown;
    
    for (CBService *service in _peripheral.services)
    {
        NSString* serviceUUID = [service.UUID UUIDString];
        if ([serviceUUID isEqualToString:@"2000"])
        {
            // Only connections to master module allowed
            state = RLADeviceLocalStateBroadcasting;
            pairing = RLADeviceLocalPairingNone;
        }
        else if ([serviceUUID isEqualToString:@"2001"])
        {
            // Onboarding mode (device can be configured via characteristics)
            state = RLADeviceLocalStateOnboarding;
            pairing = RLADeviceLocalPairingUnknown;
        }
        else if ([serviceUUID isEqualToString:@"2002"])
        {
            // Connections from every client allowed
            state = RLADeviceLocalStateBroadcasting;
            pairing = RLADeviceLocalPairingAny;
        }
    }
    
    if (_relayrState != state) { _relayrState = state; }
    if (_relayrPairing != pairing) { _relayrPairing = pairing; }
    
    // Update pairing state in case the required characteristic is available
    __weak RLADeviceLocal* weakSelf = self;
    [self dataForServiceWithUUID:@"2001" forCharacteristicWithUUID:@"2019" completion:^(NSData *data, NSError *error) {
        __strong RLADeviceLocal* strongSelf = weakSelf;
        uint8_t const* p = data.bytes;
        NSUInteger pp = *p;
        if (pp == 0) {
            strongSelf.relayrPairing = RLADeviceLocalPairingAny;
        } else if (pp == 1) {
            strongSelf.relayrPairing = RLADeviceLocalPairingNone;
        } else {
            strongSelf.relayrPairing = RLADeviceLocalPairingUnknown;
        }
    }];
}
@end
