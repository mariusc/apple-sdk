@import CoreBluetooth;              // Apple
#import "RLADeviceLocal.h"          // Header
#import "RLADevice_Setup.h"         // Relayr.framework
#import "RLADeviceLocal_Setup.h"    // Relayr.framework

//#import "RLASensorDelegate.h"       // Relayr.framework
//#import "RLADevicePrivateAPI.h"     // Relayr.framework
//#import "RLASensorPrivateAPI.h"     // Relayr.framework
//// Domain objects
//#import "RLAHandlerInfo.h"
//// Sensors
//#import "RLASensor.h"
//// Sensor values
//#import "RLASensorValue.h"
//// Outputs
//#import "RLAOutput.h"

//@interface RLASensor () <RLASensorPrivateAPI>
//@end
//
//@interface RLADevice () <RLADevicePrivateAPI>
//@end
//
//@interface RLADeviceLocal () <RLABluetoothListenerDelegate,RLASensorDelegate>
//@property (nonatomic, assign, readwrite) RLALocalDeviceState relayrState;
//@property (nonatomic, assign, readwrite) RLALocalDevicePairing relayrPairing;
//@property (nonatomic, strong, readwrite) CBPeripheral *RLA_peripheral;
//@property (nonatomic, strong, readwrite) RLABluetoothServiceListenerManager* RLA_manager;
//// The sole reason for the existence of these collection classes
//// is to prevent the stored objects from beeing released prematurely
//@property (nonatomic, strong, readwrite) NSMutableArray *RLA_storedPeripherals;
//@property (nonatomic, strong, readwrite) NSMutableArray *RLA_storedServices;
//@property (nonatomic, strong, readwrite) NSMutableSet *RLA_storedCharacteristics;
//@property (nonatomic, copy, readwrite) void (^RLA_startHandler)(NSError*);
//@property (nonatomic, copy, readwrite) void (^RLA_stopHandler)(NSError*);
//@property (nonatomic, copy, readwrite) void (^RLA_errorHandler)(NSError*);
//@property (nonatomic, strong, readwrite) NSMutableArray *RLA_readHandlers;
//@property (nonatomic, copy, readwrite) void (^RLA_writeHandler)(CBPeripheral* ,CBCharacteristic*, NSError*);
//@end

@implementation RLADeviceLocal

//#pragma mark - Public API
//
//- (instancetype)init
//{
//    [self doesNotRecognizeSelector:_cmd];
//    return nil;
//}
//
//#pragma mark - <RLADevicePrivateAPI>
//
//#pragma mark - Outputs
//
//- (void)setOutputs:(NSArray *)outputs
//{
//  [super setOutputs:outputs];
//
//  // Monitor changes of all outputs "data" properties
//  // in order to propagate the data to the device
//  for (RLAOutput* output in [self outputs])
//  {
//      [output addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:NULL];
//  }
//}
//
//#pragma mark - <RLALocalDevicePrivateAPI>
//
//#pragma mark - Designated initializer
//
//- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral andListenerManager:(RLABluetoothManager *)service
//{
//    RLAErrorAssertTrueAndReturnNil(peripheral, RLAErrorCodeMissingArgument);
//    RLAErrorAssertTrueAndReturnNil(manager, RLAErrorCodeMissingArgument);
//    
//    self = [super init];
//    if (self)
//    {
//        // Store arguments
//        _peripheral = peripheral;
//        self.name = peripheral.name;
//        self.uid = [peripheral.identifier UUIDString];
//        self.manufacturer = @"undefined";
//        
//        // Register for service notifications
//        self.RLA_manager = manager;
//        [self.RLA_manager addListener:self forPeripheral:peripheral];
//        
//        // Setup storage arrays
//        self.RLA_storedPeripherals = [NSMutableArray array];
//        self.RLA_storedServices = [NSMutableArray array];
//        self.RLA_storedCharacteristics = [NSMutableSet set];
//        self.RLA_readHandlers = [NSMutableArray array];
//        
//        // Scan peripheral
//        self.RLA_peripheral.delegate = self.RLA_manager;
//    }
//    return self;
//}
//
//#pragma mark - Setters
//
//- (void)setPeripheral:(CBPeripheral *)peripheral
//{
//    self.RLA_peripheral = peripheral;
//}
//
//- (void)setRelayrPairing:(RLALocalDevicePairing)pairing
//              completion:(void(^)(NSError*))completion
//{
//  RLAErrorAssertTrueAndReturn((pairing != RLALocalDevicePairingUnknown),
//                              RLAErrorCodeAPIMisuse);
//  
//  // Setup flag
//  uint8_t d[1];
//  if (pairing == RLALocalDevicePairingAny) {
//    d[0]=0;
//  } else if (pairing == RLALocalDevicePairingNone) {
//    d[0]=1;
//  }
//  NSData* flag =
//  [NSData dataWithBytes:(const void*)d length:sizeof(unsigned char)];
//  
//  // Write data
//  [self setData:flag
//forServiceWithUUID:@"2001"
//forCharacteristicWithUUID:@"2019"
//     completion: ^(CBPeripheral *p, CBCharacteristic *c, NSError *error) {
//       completion(error);
//     }];
//}
//
//#pragma mark - <RLALocalDeviceAPI>
//
//#pragma mark - Getters
//
//- (NSNumber *)RSSI
//{
//  return self.peripheral.RSSI;
//}
//
//- (void)dataForServiceWithUUID:(NSString *)serviceUUID
//     forCharacteristicWithUUID:(NSString *)characteristicUUID
//                    completion:(void(^)(NSData*, NSError*))completion
//{
//  RLAErrorAssertTrueAndReturn(serviceUUID, RLAErrorCodeMissingArgument);
//  RLAErrorAssertTrueAndReturn(characteristicUUID, RLAErrorCodeMissingArgument);
//  RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
//  
//  // Callback with error error if the device is not connected
////  if (!self.isConnected) {
////    NSError *error =
////    [RLAError errorWithCode:RLAErrorCodeConnectionError
////       localizedDescription:@"Could not write data"
////              failureReason:@"Device is not connected"];
////    completion(nil, error);
////  }
//  
//  // Store completion handler
//  RLAHandlerInfo *info = [[RLAHandlerInfo alloc] initWithServiceUUID:serviceUUID
//                                                  characteristicUUID:characteristicUUID
//                                                             handler:completion];
//  RLAErrorAssertTrueAndReturn(info, RLAErrorCodeMissingExpectedValue);
//  [self.RLA_readHandlers addObject:info];
//  
//  // Find characteristic with matching UUID on peripheral ans read value
//  for (CBService *service in [self.peripheral services]) {
//    NSString *sUUID = [service.UUID UUIDString];
//    if ([sUUID isEqualToString:serviceUUID]) {
//      for (CBCharacteristic *characteristic in [service characteristics]) {
//        NSString *cUUID = [characteristic.UUID UUIDString];
//        if ([cUUID isEqualToString:characteristicUUID]) {
//          [self.RLA_peripheral readValueForCharacteristic:characteristic];
//          return;
//        }
//      }
//    }
//  }
//}
//
//#pragma mark - Setters
//
//- (void)setData:(NSData *)data
//  forServiceWithUUID:(NSString *)serviceUUID
//  forCharacteristicWithUUID:(NSString *)characteristicUUID
//  completion:(void(^)(CBPeripheral*, CBCharacteristic*, NSError*))completion;
//{
//  RLAErrorAssertTrueAndReturn(serviceUUID, RLAErrorCodeMissingArgument);
//  RLAErrorAssertTrueAndReturn(characteristicUUID, RLAErrorCodeMissingArgument);
//  RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
//  
//  // Callback with error if the device is not connected
//  if (!self.isConnected) {
//    NSError *error =
//      [RLAError errorWithCode:RLAErrorCodeConnectionError
//         localizedDescription:@"Could not write data"
//                failureReason:@"Device is not connected"];
//    completion(nil, nil, error);
//  }
//  
//  // Callback with error if a write operation is already in progress
//  if (self.RLA_writeHandler) {
//    NSError *error =
//    [RLAError errorWithCode:RLAErrorCodeAPIMisuse
//       localizedDescription:@"Could not write data"
//              failureReason:@"A write operation is already in progress"
//                             "and only one write operations is allowed at a time"];
//    completion(nil, nil, error);
//  }
//  
//  // Store completion handler
//  self.RLA_writeHandler = completion;
//  
//  // Find characteristic with matching UUID on peripheral ans set value
//  for (CBService *service in [self.peripheral services]) {
//    NSString *sUUID = [service.UUID UUIDString];
//    if ([sUUID isEqualToString:serviceUUID]) {
//      for (CBCharacteristic *characteristic in [service characteristics]) {
//        NSString *cUUID = [characteristic.UUID UUIDString];
//        if ([cUUID isEqualToString:characteristicUUID]) {
//          [self.RLA_peripheral writeValue:data
//                    forCharacteristic:characteristic
//                                 type:CBCharacteristicWriteWithResponse];
//        }
//      }
//    }
//  }
//}
//
//#pragma mark - Peripheral
//
//- (CBPeripheral *)peripheral
//{
//  return self.RLA_peripheral;
//}
//
//#pragma mark - <RLADeviceConnectionAPI>
//
//#pragma mark - Sensor data
//
//- (BOOL)isConnected
//{
//  return (self.peripheral.state == CBPeripheralStateConnected);
//}
//
//- (void)connectWithSuccessHandler:(void(^)(NSError*))handler
//{
//  RLAErrorAssertTrueAndReturn(handler, RLAErrorCodeMissingArgument);
//  NSAssert(!([[self peripheral] state] == CBPeripheralStateConnected),
//           @"Device is already connected.");
//  
//  // Subscribe for updates on each characteristic
//  self.RLA_startHandler = handler;
//  if (!self.isConnected) [self RLA_connect];
//}
//
//- (void)disconnectWithSuccessHandler:(void(^)(NSError*))handler
//{
//  // Handlers are also used as state indicators
//  // in order to check if connection was lost or terminated on purpose
//  // Therefore NULL value handlers are not allowed
//  if (!handler) handler = ^(NSError *e){};
//  
//  // Unsubscribe from updates on each characteristic
//  self.RLA_stopHandler = handler;
//  for (CBService *service in self.RLA_peripheral.services) {
//    for (CBCharacteristic *characteristic in service.characteristics) {
//      [self.RLA_peripheral setNotifyValue:NO forCharacteristic:characteristic];
//    }
//  }
//
//  CBCentralManager *manager = self.RLA_manager.centralManager;
//  [manager cancelPeripheralConnection:self.RLA_peripheral];
//}
//
//#pragma mark - Error handling
//
//- (void)setErrorHandler:(void(^)(NSError*))handler
//{
//  self.RLA_errorHandler = handler;
//}
//
//#pragma mark - <RLABluetoothListenerDelegate>
//
//- (void)manager:(RLABluetoothServiceListenerManager*)manager
//  didConnectPeripheral:(CBPeripheral *)peripheral
//{
//  // Store updated peripheral instance
//  self.RLA_peripheral = peripheral;
//  
//  // Discover all available services
//  [peripheral discoverServices:nil];
//}
//
//- (void)manager:(RLABluetoothServiceListenerManager*)manager
//  didDisconnectPeripheral:(CBPeripheral *)peripheral
//{
//  // Update device state
//  [self RLA_updateRelayrStateAndPairing];
//  
//  // Store updated peripheral instance
//  self.RLA_peripheral = peripheral;
//  
//  // Invoke callback block if connection was stopped intentionally
//  if (self.RLA_stopHandler) {
//    self.RLA_stopHandler(nil);
//    self.RLA_stopHandler = nil;
//    return;
//
//  // Invoke error callback if connection was lost
//  } else {
//    NSError *error =
//      [RLAError errorWithCode:RLAErrorCodeUnknownConnectionError
//         localizedDescription:@"Connection lost"
//                failureReason:@"Unknow reason"];
//    if (self.RLA_errorHandler) self.RLA_errorHandler(error);
//    return;
//  }
//}
//
//- (void)manager:(RLABluetoothServiceListenerManager*)manager
//  peripheral:(CBPeripheral *)peripheral
//  didDiscoverCharacteristicsForService:(CBService *)service
//  error:(NSError *)error
//{
//  // Update device state
//  [self RLA_updateRelayrStateAndPairing];
//  
//  // Invoke callback handler
//  if (self.RLA_startHandler) {
//    self.RLA_startHandler(nil);
//    self.RLA_startHandler = nil;
//  }
//  
//  // Subscription to actual values stored in the characteristics
//  // only happens after an observer was added, see <RLASensorDelegate>
//  // Subscribing to updates right here reliably disrupts the bluetooth
//  // stack when connections to lots of devices are scheduled
//  // Therefore subscription to the characteristics is beeing delayed
//  // until they are really needed (== observed)
//  
//  // Sensor observation was stopped before but observers are still subscribed
//  // Kick off monitoring characteristics again
//  BOOL anySensorObserving = NO;
//  for (RLASensor *sensor in [self sensors]) {
//    if ([sensor observationInfo]) {
//      anySensorObserving = YES;
//      continue;
//    }
//  }
//  if (anySensorObserving) {
//    NSArray *services = [[self peripheral] services];
//    for (CBService *service in services) {
//      for (CBCharacteristic *characteristic in service.characteristics) {
//        [self.RLA_peripheral setNotifyValue:YES forCharacteristic:characteristic];
//      }
//    }
//  }
//}
//
//- (void)manager:(RLABluetoothServiceListenerManager*)manager
//  peripheral:(CBPeripheral *)peripheral
//  didUpdateData:(NSData *)data
//  forCharacteristic:(CBCharacteristic *)characteristic
//  error:(NSError *)error
//{  
//  // Invoke and remove callback handler in case one was stored for this characteristic
//  for (RLAHandlerInfo *info in self.RLA_readHandlers) {
//    NSString *serviceUUID = [characteristic.service.UUID UUIDString];
//    if ([info.serviceUUID isEqualToString:serviceUUID]) {
//      NSString *characteristicUUID = [characteristic.UUID UUIDString];
//      if ([info.characteristicUUID isEqualToString:characteristicUUID]) {
//        info.handler(data, error);
//        [self.RLA_readHandlers removeObject:info];
//        return;
//      }
//    }
//  }
//}
//
//- (void)manager:(RLABluetoothServiceListenerManager*)manager
//  peripheral:(CBPeripheral *)peripheral
//  didUpdateValue:(NSDictionary *)value
//  withSensorClass:(Class)class
//  forCharacteristic:(CBCharacteristic *)characteristic
//  error:(NSError *)error
//{
//  // Populate matching sensor with value
//  RLASensor *sensor = [self sensorOfClass:class];
//  RLAErrorAssertTrueAndReturn(sensor, RLAErrorCodeMissingExpectedValue);
//  Class sensorValueClass = [sensor sensorValueClass];
//  RLAErrorAssertTrueAndReturn(sensorValueClass, RLAErrorCodeMissingExpectedValue);
//  id sensorValue = [[sensorValueClass alloc] initWithDictionary:value];
//  [sensor setSensorValue:sensorValue];
//  
//  // Store characteristic in order to prevent premature deallocation
//  [self.RLA_storedCharacteristics addObject:characteristic];
//  
//  // Invoke callback block
//  if (self.RLA_startHandler) {
//    self.RLA_startHandler(error);
//    self.RLA_startHandler = nil;
//  }
//  
//  [RLALog debug:@"didUpdateValue: %@", value];
//}
//
//- (void)manager:(RLABluetoothServiceListenerManager*)manager
//  peripheral:(CBPeripheral *)peripheral
//  didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
//  error:(NSError *)error;
//{
//  RLAErrorAssertTrueAndReturn(self.RLA_writeHandler, RLAErrorCodeMissingExpectedValue);
//  
//  // Update device state
//  [self RLA_updateRelayrStateAndPairing];
//
//  void (^writeHandler)(CBPeripheral* ,CBCharacteristic*, NSError*) = self.RLA_writeHandler;
//  self.RLA_writeHandler = nil;
//  writeHandler(peripheral, characteristic, error);
//}
//
//#pragma mark - <RLASensorDelegate>
//
//- (void)sensorDidAddObserver:(RLASensor *)sensor
//{
//  // Subscribe for updates on each characteristic
//  if (![sensor observationInfo]) {
//    NSArray *services = [[self peripheral] services];
//    for (CBService *service in services) {
//      for (CBCharacteristic *characteristic in service.characteristics) {
//        [self.RLA_peripheral setNotifyValue:YES forCharacteristic:characteristic];
//      }
//    }
//  }
//}
//
//- (void)sensorDidRemoveObserver:(RLASensor *)sensor
//{
//  // Stop notifications when no object is listening any more
//  if (![sensor observationInfo]) {
//    NSArray *services = [[self peripheral] services];
//    for (CBService *service in services) {
//      for (CBCharacteristic *characteristic in service.characteristics) {
//        [self.RLA_peripheral setNotifyValue:NO forCharacteristic:characteristic];
//      }
//    }
//  }
//}
//
//#pragma mark - <NSKeyValueObserving>
//
//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object change:(NSDictionary *)change
//                       context:(void *)context
//{
//  // Output changed
//  if ([object isKindOfClass:[RLAOutput class]]) {
//    
//    // Write data to matching characteristic
//    RLAOutput *output = (RLAOutput *)object;
//    for (CBService *service in [self.RLA_peripheral services]) {
//      for (CBCharacteristic *characteristic in [service characteristics]) {
//        if ([[characteristic.UUID UUIDString] isEqualToString:[output uid]]) {
//          [self.RLA_peripheral writeValue:output.data
//                        forCharacteristic:characteristic
//                                     type:CBCharacteristicWriteWithResponse];
//          return;
//        }
//      }
//    }
//    
//    // Data could not be sent
//    // Callback with error
//    NSString *failureReason =
//    [NSString stringWithFormat:@"No characteristic matching uid: %@", output.uid];
//    NSError *error =
//      [RLAError errorWithCode:RLAErrorCodeMissingExpectedValue
//         localizedDescription:@"Writing data to output failed"
//                failureReason:failureReason];
//    if (self.RLA_errorHandler) self.RLA_errorHandler(error);
//  }
//}
//
//#pragma mark - Private helpers
//
//- (void)RLA_connect
//{
//    if (![self.peripheral services]) {
//        [self.RLA_manager.centralManager connectPeripheral:self.peripheral options:nil];
//    } else {
//        for (CBService *service in self.RLA_peripheral.services) {
//            for (CBCharacteristic *characteristic in service.characteristics) {
//                [self.RLA_peripheral setNotifyValue:YES forCharacteristic:characteristic];
//            }
//        }
//    }
//}
//
//- (void)RLA_updateRelayrStateAndPairing
//{
//    // Derive device state from available services
//    RLALocalDeviceState state = RLALocalDeviceStateUnknown;
//    RLALocalDevicePairing pairing = RLALocalDevicePairingUnknown;
//    NSArray *services = [[self peripheral] services];
//    for (CBService *service in services) {
//        
//        // Only connections to master module allowed
//        NSString *serviceUUID = [service.UUID UUIDString];
//        if ([serviceUUID isEqualToString:@"2000"]) {
//            state = RLALocalDeviceStateBroadcasting;
//            pairing = RLALocalDevicePairingNone;
//            
//            // Onboarding mode (device can be configured via characteristics)
//        } else if ([serviceUUID isEqualToString:@"2001"]) {
//            state = RLALocalDeviceStateOnboarding;
//            pairing = RLALocalDevicePairingUnknown;
//            
//            // Connections from every client allowed
//        } else if ([serviceUUID isEqualToString:@"2002"]) {
//            state = RLALocalDeviceStateBroadcasting;
//            pairing = RLALocalDevicePairingAny;
//        }
//    }
//    if (self.relayrState != state) self.relayrState = state;
//    if (self.relayrPairing != pairing) self.relayrPairing = pairing;
//    
//    // Update pairing state in case the required characteristic is available
//    __weak typeof(self) weakSelf = self;
//    [self dataForServiceWithUUID:@"2001"
//       forCharacteristicWithUUID:@"2019"
//                      completion:^(NSData *data, NSError *error) {
//                          __strong typeof(weakSelf) self = weakSelf;
//                          const uint8_t* p = [data bytes];
//                          NSUInteger pp = *p;
//                          if (pp == 0) {
//                              self.relayrPairing = RLALocalDevicePairingAny;
//                          } else if (pp == 1) {
//                              self.relayrPairing = RLALocalDevicePairingNone;
//                          } else {
//                              self.relayrPairing = RLALocalDevicePairingUnknown;
//                          }
//                      }];
//}

@end
