#import "RLABluetoothCentralRequestDiscoverPeripherals.h" // Header
#import "RLABluetoothManager.h"                     // Relayr.framework
#import "RLAPeripheralnfo.h"                        // Relayr.framework (Domain object)
#import "RLAMappingInfo.h"                          // Relayr.framework (Domain object)
#import "RLABluetoothAdapterController.h"           // Relayr.framework (Controller)

@interface RLABluetoothCentralRequestDiscoverPeripherals () <RLABluetoothDelegate>
@end

@implementation RLABluetoothCentralRequestDiscoverPeripherals
{
    NSTimer* _timer;
    NSSet* _deviceClasses;
    NSTimeInterval _timeout;
    RLABluetoothAdapterController* _adapterController;
    NSMutableSet* _foundClasses;
    NSMutableSet* _foundPeripherals;
}

#pragma mark - Public API

- (instancetype)initWithListenerManager:(RLABluetoothManager*)manager permittedDeviceClasses:(NSArray*)classes timeout:(NSTimeInterval)timeout
{
    RLAErrorAssertTrueAndReturnNil(classes, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(timeout, RLAErrorCodeMissingArgument);
    
    self = [super initWithListenerManager:manager];
    if (self)
    {
        _adapterController = [[RLABluetoothAdapterController alloc] init];  // Provides bluetooth peripheral and conversion info
        
        _timeout = timeout;
        _deviceClasses = [NSSet setWithArray:classes];
        _foundClasses = [[NSMutableSet alloc] init];
        _foundPeripherals = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark Parent classes

- (instancetype)initWithListenerManager:(RLABluetoothManager*)manager
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)executeWithCompletionHandler:(void(^)(NSArray*, NSError*))completion
{
    RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
    [super executeWithCompletionHandler:completion];
    
    // Kick off scanning
    CBCentralManager* centralManager = self.manager.centralManager;
    if (centralManager.state == CBCentralManagerStatePoweredOn)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeout target:self selector:@selector(peripheralDiscoveryTimeoutHandler) userInfo:nil repeats:NO];
        [centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    else
    {
        NSError* error = [RLAError errorWithCode:RLAErrorCodeConnectionChannelPoweredOff localizedDescription:@"Could not connect to devices via Bluetooth" failureReason:@"Bluetooth connectity is not available"];
        self.completionHandler(nil, error);
    }
}

#pragma mark RLABluetoothDelegate

- (void)manager:(RLABluetoothManager*)manager didUpdateState:(CBCentralManagerState)state
{
    if (state == CBCentralManagerStatePoweredOn)
    {
        [self.manager.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

#warning Onboarding potential error
- (void)manager:(RLABluetoothManager*)manager didDiscoverPeripheral:(CBPeripheral*)peripheral
{
    // Store class if a required one was found
    NSArray* classes = [self requiredClassesForPeripheral:peripheral];
    [_foundClasses addObjectsFromArray:classes];
    
    // Store or update peripheral, the closest one is prefered. Check if a peripheral with same name is already stored
    if ( classes.count )
    {
        CBPeripheral* storedPeripheral;
        for (CBPeripheral* p in _foundPeripherals)
        {
            if ([p.name isEqualToString:peripheral.name])
            {
                storedPeripheral = p;
                break;
            }
        }
        
        // Peripheral with same name is already stored
        if (storedPeripheral)
        {
            // Replace the old peripheral with the new one if its closer
            BOOL const newPeripheralIsCloser = (peripheral.RSSI.integerValue > storedPeripheral.RSSI.integerValue);
            if (newPeripheralIsCloser)
            {
                [_foundPeripherals removeObject:storedPeripheral];
                [_foundPeripherals addObject:peripheral];
            }
            
            // The old one is closer, keep this one
        }
        else
        {
            [_foundPeripherals addObject:peripheral];
        }
    }
    
    // Invoke completion handler if objects of all provided classes were found
    if ([self isRequestFinished]) { [self requestCompletedHandler]; }
}

#pragma mark - Private methods

- (void)peripheralDiscoveryTimeoutHandler
{
    [self requestCleanUp];
    NSError *error = [RLAError errorWithCode:RLAErrorCodeMissingExpectedValue localizedDescription:@"Connection error" failureReason:@"Peripherals not found"];
    self.completionHandler(_foundPeripherals.allObjects, error);
}

- (void)requestCleanUp
{
    RLABluetoothManager* manager = self.manager;
    [manager.centralManager stopScan];
    [manager removeListener:self];
}

- (BOOL)isPermittedDeviceClass:(RLAMappingInfo *)info
{
    // Sensors
    Class sensorClass = info.sensorClass;
    for (Class class in _deviceClasses)
    {
        if (class == sensorClass) { return YES; }
    }
    
    // Outputs
    Class outputClass = info.outputClass;
    for (Class class in _deviceClasses)
    {
        if (class == outputClass) { return YES; }
    }
    return NO;
}

- (NSArray *)requiredClassesForPeripheral:(CBPeripheral*)peripheral
{
    // Find mapping for peripheral
    RLAPeripheralnfo* info = [_adapterController infoForPeripheralWithName:peripheral.name bleIdentifier:[peripheral.identifier UUIDString] serviceUUID:nil characteristicUUID:nil];
    NSArray* mappings = info.mappings;
    
    // Return appropriate class if one was found
    NSMutableArray* classes = [NSMutableArray array];
    for (RLAMappingInfo* info in mappings)
    {
        if ([self isPermittedDeviceClass:info])
        {
            for (RLAMappingInfo* info in mappings)
            {
                for (Class class in _deviceClasses) {
                    if ((info.sensorClass == class) || (info.outputClass == class)){ [classes addObject:class]; }
                }
            }
        }
    }
    
    return (classes.count) ? [classes copy] : nil;
}

- (BOOL)isRequestFinished
{
    return (_foundClasses.count == _deviceClasses.count);
}

- (void)requestCompletedHandler
{
    // Cleanup and invoke callback with connected devices
    if ([_timer isValid]) { [_timer invalidate]; }
    
    [self requestCleanUp];
    self.completionHandler(_foundPeripherals.allObjects, nil);
}

@end
