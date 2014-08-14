#import "RLABluetoothService.h"                         // Header
@import CoreBluetooth;                                  // Apple
//#import "RLASensorPrivateAPI.h"                         // Relayr.framework (protocol)
//#import "RLADevicePrivateAPI.h"                         // Relayr.framework (protocol)
//#import "RLALocalDevicePrivateAPI.h"                    // Relayr.framework (protocol)
//#import "RLASensorDelegate.h"                           // Relayr.framework (protocol)
//#import "RLABluetoothServiceListenerManager.h"          // Relayr.framework
//#import "RLAPeripheralnfo.h"                            // Relayr.framework
//#import "RLAMappingInfo.h"                              // Relayr.framework
//#import "RLALocalDevice.h"                              // Relayr.framework
//#import "RLABluetoothPeripheralsDiscoveryRequest.h"     // Relayr.framework (central role)
//#import "RLAWunderbarRegistrationPeripheralRequest.h"   // Relayr.framework (peripheral role)
//#import "RLAColorSensor.h"                              // Relayr.framework (sensor)
//#import "RLAOutput.h"                                   // Relayr.framework (output)
//#import "RLABluetoothAdapterController.h"               // Relayr.framework

//@interface RLADevice () <RLASensorDelegate>
//@end
//
//@interface RLALocalDevice () <RLADevicePrivateAPI, RLALocalDevicePrivateAPI>
//@end
//
//@interface RLASensor () <RLASensorPrivateAPI>
//@end

@interface RLABluetoothService ()
//@property (strong, nonatomic) RLABluetoothAdapterController* bleAdapterCntrll;
//@property (strong, nonatomic) RLABluetoothPeripheralsDiscoveryRequest* peripheralRequest;       // Retainer
//@property (strong, nonatomic) RLAWunderbarRegistrationPeripheralRequest* registrationRequest;   // Retainer
@end    // The sole purpose of the retainers is to prevent premature deallocation of the requests

@implementation RLABluetoothService
{
    CBCentralManager* _centralManager;
//    RLABluetoothServiceListenerManager* _serviceListener;
}

#pragma mark - Public API

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _serviceListener = [[RLABluetoothServiceListenerManager alloc] init];
//        _centralManager = [[CBCentralManager alloc] initWithDelegate:_serviceListener queue:nil];
//        _serviceListener.centralManager = _centralManager;
    }
    return self;
}

- (void)devicesWithSensorsAndOutputsOfClasses:(NSArray *)classes timeout:(NSTimeInterval)timeout completion:(void(^)(NSArray*, NSError*))completion
{
    RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
    
//    __autoreleasing NSError* error;
//    if ( ![self isBluetoothAvailable:&error] ) { return completion(nil, error); }
//    
//    // Setup request
//    self.peripheralRequest = [[RLABluetoothPeripheralsDiscoveryRequest alloc] initWithListenerManager:_serviceListener permittedDeviceClasses:classes timeout:timeout];
//    
//    // Execute request
//    __weak typeof(self) weakSelf = self;
//    [self.peripheralRequest executeWithCompletionHandler: ^(NSArray *peripherals, NSError *error) {
//        // Serialize CBPeriphal objects to RLADevices
//        __strong typeof(weakSelf) self = weakSelf;
//        NSArray *devices = [self serializePeripherals:peripherals];
//        
//        // Callback completion block
//        completion(devices, error);
//    }];
}

#pragma mark Onboarding

//- (void)peripheralWithWunderbarCredentials:(RLAWunderbarCredentials *)credentials wifiSSID:(NSString *)ssid wifiPassword:(NSString *)password andCompletionHandler:(void(^)(NSError*))completion
//{
//    RLAErrorAssertTrueAndReturn(ssid, RLAErrorCodeMissingArgument);
//    RLAErrorAssertTrueAndReturn(password, RLAErrorCodeMissingArgument);
//    RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
//    
//    __autoreleasing NSError* error;
//    if ( ![self isBluetoothAvailable:&error] ) { return completion(error); }
//    
//    // The central manager may not habe any connections to peripherals otherwise the peripheral manager used for this request is not usable
//    [_centralManager stopScan];
//    for (CBPeripheral *peripheral in [_serviceListener connectedPeripherals]) {
//        [_centralManager cancelPeripheralConnection:peripheral];
//    }
//    
//    // Setup request
//    self.registrationRequest = [[RLAWunderbarRegistrationPeripheralRequest alloc] initWithCredentials:credentials wifiSSID:ssid wifiPassword:password];
//    
//    // Execute request
//    [self.registrationRequest executeWithCompletionHandler:^(NSError *error){ completion(error); }];
//}

#pragma mark - Private helpers

//- (BOOL)isBluetoothAvailable:(__autoreleasing NSError**)error
//{
//    if ( _centralManager.state == CBCentralManagerStatePoweredOn ) return YES;
//    
//    if (error != NULL) { *error = [RLAError errorWithCode:RLAErrorCodeUnknownConnectionError localizedDescription:@"Could not connect to devices via Bluetooth" failureReason:@"Bluetooth connectity is not available"]; }
//    return NO;
//}
//
//- (RLABluetoothAdapterController*)bleAdapterCntrll
//{
//    if (!_bleAdapterCntrll) {
//        _bleAdapterCntrll = self.bleAdapterCntrll = [[RLABluetoothAdapterController alloc] init];
//    }
//    return _bleAdapterCntrll;
//}
//
//- (NSArray*)serializePeripherals:(NSArray *)peripherals
//{
//    // Setup device objects with all connected peripherals
//    NSMutableArray *mArray = [NSMutableArray array];
//    for (CBPeripheral *peripheral in peripherals) {
//        // Init device
//        RLALocalDevice *device = [[RLALocalDevice alloc] initWithPeripheral:peripheral andListenerManager:_serviceListener];
//        
//        // Assign sensors to device
//        if (device) {
//            
//            // Assign matching model id to device
//            RLAPeripheralnfo *info = [self.bleAdapterCntrll infoForPeripheralWithName:peripheral.name bleIdentifier:[peripheral.identifier UUIDString] serviceUUID:nil characteristicUUID:nil];
//            RLAErrorAssertTrueAndReturnNil(info, RLAErrorCodeMissingExpectedValue);
//            device.modelID = info.relayrModelID;
//            
//            // Add sensors and connectors to device based on mappings
//            NSArray *mappings = [info mappings];
//            NSMutableArray *mSensors = [NSMutableArray array];
//            NSMutableArray *mOutputs = [NSMutableArray array];
//            for (RLAMappingInfo *info in mappings) {
//                
//                // Setup sensor and delegate in order to receive updates when
//                // objects subscribe for sensor value updates
//                if ([info sensorClass]) {
//                    RLASensor *sensor = [[[info sensorClass] alloc] init];
//                    sensor.delegate = device;
//                    [mSensors addObject:sensor];
//                } else if ([info outputClass]) {
//                    RLAOutput *output = [[[info outputClass] alloc] init];
//                    [mOutputs addObject:output];
//                }
//            }
//            if ([mSensors count]) [device setSensors:[mSensors copy]];
//            if ([mOutputs count]) [device setOutputs:[mOutputs copy]];
//            
//            // Store device
//            [mArray addObject:device];
//        }
//    }
//    
//    return [mArray copy];
//}

@end
