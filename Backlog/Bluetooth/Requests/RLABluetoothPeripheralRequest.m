#import "RLABluetoothPeripheralRequest.h" // Header

@implementation RLABluetoothPeripheralRequest
{
    NSString* _name;
    NSArray* _services;
    NSArray* _uuids;
    BOOL _shouldAdvertisePeripheral;
}

#pragma mark - Public API

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        RLAErrorAssertTrueAndReturnNil(_manager, RLAErrorCodeMissingExpectedValue);
    }
    return self;
}

#warning The content of the dealloc never seems to be called
- (void)dealloc
{
    [_manager stopAdvertising];
}

- (NSString *)name
{
    return _name;
}

- (NSArray *)services
{
    return _services;
}

- (void)executeWithCompletionHandler:(void(^)(NSError*))completion
{
    // Store completion block
    _completion = completion;
    
    // Advertise
    [self addvertisePeripheral];
}

#pragma mark CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if (_manager.state == CBPeripheralManagerStatePoweredOn)
    {
        // Redeclare all services as dynamic services
        NSMutableArray* uuids = [NSMutableArray array];
        NSArray* services = self.services;
        
        for (CBMutableService* service in services)
        {
            [uuids addObject:service.UUID];
            
            NSMutableArray* tmpCharacteristics = [NSMutableArray array];
            for (CBCharacteristic* characteristic in service.characteristics)
            {
                CBMutableCharacteristic* c = [[CBMutableCharacteristic alloc] initWithType:characteristic.UUID properties:characteristic.properties value: nil permissions:CBAttributePermissionsReadable];
                [tmpCharacteristics addObject:c];
            }
            
            CBMutableService* s = [[CBMutableService alloc] initWithType:service.UUID primary:service.isPrimary];
            s.characteristics = [tmpCharacteristics copy];
            [_manager addService:s];
        }
        
        _uuids = [uuids copy];
        
        // Immediately start advertising if @selector(executeWithCompletionHandler) has been invoked meanwhile
        if (_shouldAdvertisePeripheral) { [self addvertisePeripheral]; }
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    [RLALog debug:@"peripheralManagerDidStartAdvertising: %@", peripheral];
    
    // Error: Cancel and invoke callback block
    if (error)
    {
        [_manager stopAdvertising];
        _completion(error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    [RLALog debug:@"peripheralManagerDidAddService: %@ error:%@", service, error];
    
    // Error: Cancel and invoke callback block
    if (error)
    {
        [_manager stopAdvertising];
        _completion(error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    [RLALog debug:@"peripheralManagerDidReceiveReadRequest: %@", request];
    
    // Answer read request with appropriate data
    NSArray* services = self.services;
    for (CBMutableService* service in services)
    {
        for (CBCharacteristic* characteristic in service.characteristics)
        {
            if ([request.characteristic.UUID isEqual:characteristic.UUID])
            {
                // Offset error: Cancel
                if (request.offset > characteristic.value.length)
                {
                    [_manager respondToRequest:request withResult:CBATTErrorInvalidOffset];
                    return;
                }
                
                // Respond with value
                NSRange range = NSMakeRange(request.offset, characteristic.value.length - request.offset);
                request.value = [characteristic.value subdataWithRange:range];
                [_manager respondToRequest:request withResult:CBATTErrorSuccess];
            }
        }
    }
}

#pragma mark - Private methods

- (void)addvertisePeripheral
{
    // Advertise if manager is in appropriate state
    if (_manager.state == CBPeripheralManagerStatePoweredOn)
    {
        NSDictionary* advertisingData= @{ CBAdvertisementDataLocalNameKey : @"WunderbarApp", CBAdvertisementDataServiceUUIDsKey : _uuids };
        [_manager startAdvertising:advertisingData];
        // Automatically start advertising as soon as possible via flag
    }
    else
    {
        _shouldAdvertisePeripheral =YES;
    }
}

@end
