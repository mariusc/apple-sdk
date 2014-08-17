@import CoreBluetooth;                                  // Apple
#import "RLABluetoothService.h"                         // Header
#import "RLABluetoothManager.h"                         // Relayr.framework
#import "RLABluetoothAdapterController.h"               // Relayr.framework

#import "RLABluetoothCentralRequestDiscoverPeripherals.h"
#import "RLADevice.h"
#import "RLADevice_Setup.h"
#import "RLADeviceLocal.h"
#import "RLADeviceLocal_Setup.h"
#import "RLAPeripheralnfo.h"
#import "RLAMappingInfo.h"

#import "RLASensor.h"
#import "RLASensor_Setup.h"
#import "RLAOutput.h"

@interface RLABluetoothService ()
//@property (strong, nonatomic) RLAWunderbarRegistrationPeripheralRequest* registrationRequest;   // Retainer
@end    // The sole purpose of the retainers is to prevent premature deallocation of the requests

@implementation RLABluetoothService
{
    RLABluetoothManager* _bleManager;
    RLABluetoothAdapterController* _bleAdapterController;
    
    // Retainers
    RLABluetoothCentralRequestDiscoverPeripherals* _peripheralRequest;
}

#pragma mark - Public API

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bleManager = [[RLABluetoothManager alloc] init];
        _bleManager.centralManager = [[CBCentralManager alloc] initWithDelegate:_bleManager queue:nil];
        _bleAdapterController = [[RLABluetoothAdapterController alloc] init];
    }
    return self;
}

- (void)devicesWithSensorsAndOutputsOfClasses:(NSArray *)classes timeout:(NSTimeInterval)timeout completion:(void(^)(NSArray*, NSError*))completion
{
    RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
    
    __autoreleasing NSError* error;
    if ( ![self isBluetoothAvailable:&error] ) { return completion(nil, error); }

    // Setup request
    _peripheralRequest = [[RLABluetoothCentralRequestDiscoverPeripherals alloc] initWithListenerManager:_bleManager permittedDeviceClasses:classes timeout:timeout];

    // Execute request
    __weak RLABluetoothService* weakSelf = self;
    [_peripheralRequest executeWithCompletionHandler:^(NSArray* peripherals, NSError* error) {
        // Serialize CBPeriphal objects to RLADevices
        __strong RLABluetoothService* strongSelf = weakSelf;
        NSArray* devices = [strongSelf serializePeripherals:peripherals];
        
        // Callback completion block
        completion(devices, error);
    }];
}

#pragma mark - Private helpers

- (BOOL)isBluetoothAvailable:(__autoreleasing NSError**)error
{
    if ( _bleManager.centralManager.state == CBCentralManagerStatePoweredOn ) { return YES; }
    
    if (error != NULL)
    {
        *error = [RLAError errorWithCode:RLAErrorCodeUnknownConnectionError localizedDescription:@"Could not connect to devices via Bluetooth" failureReason:@"Bluetooth connectity is not available"];
    }
    return NO;
}

- (NSArray*)serializePeripherals:(NSArray *)peripherals
{
    // Setup device objects with all connected peripherals
    NSMutableArray* devices = [NSMutableArray array];
    for (CBPeripheral* peripheral in peripherals)
    {
        RLADeviceLocal* device = [[RLADeviceLocal alloc] initWithPeripheral:peripheral andListenerManager:_bleManager];

        // Assign sensors to device
        if (device)
        {
            // Assign matching model ID to device
            RLAPeripheralnfo* peripheralInfo = [_bleAdapterController infoForPeripheralWithName:peripheral.name bleIdentifier:[peripheral.identifier UUIDString] serviceUUID:nil characteristicUUID:nil];
            RLAErrorAssertTrueAndReturnNil(peripheralInfo, RLAErrorCodeMissingExpectedValue);
            device.modelID = peripheralInfo.relayrModelID;

            // Add sensors and connectors to device based on mappings
            NSMutableArray* tmpSensors = [NSMutableArray array];
            NSMutableArray* tmpOutputs = [NSMutableArray array];
            for (RLAMappingInfo* mappingInfo in peripheralInfo.mappings)
            {
                // Setup sensor and delegate in order to receive updates when objects subscribe for sensor value updates
                if (mappingInfo.sensorClass)
                {
                    RLASensor* sensor = [[mappingInfo.sensorClass alloc] init];
                    sensor.delegate = device;
                    [tmpSensors addObject:sensor];
                }
                else if (mappingInfo.outputClass)
                {
                    RLAOutput* output = [[mappingInfo.outputClass alloc] init];
                    [tmpOutputs addObject:output];
                }
            }
            if (tmpSensors.count) { [device setSensors:[tmpSensors copy]]; }
            if (tmpOutputs.count) { [device setOutputs:[tmpOutputs copy]]; }

            // Store device
            [devices addObject:device];
        }
    }

    return [devices copy];
}

@end
