#import "RLADispatcher.h"       // Header
#import "RelayrUser.h"          // Relayr (Public)
#import "RelayrTransmitter.h"   // Relayr (Public/IoTs)
#import "RelayrDevice.h"        // Relayr (Public/IoTs)
#import "RelayrReading.h"       // Relayr (Public/IoTs)
#import "RelayrConnection.h"    // Relayr (Public/IoTs)
#import "RelayrUser_Setup.h"    // Relayr (Private)
#import "RelayrReading_Setup.h" // Relayr (Private/IoTs)
#import "RLAAPIService.h"       // Relayr (Services/API)
#import "RLABLEService.h"       // Relayr (Services/BLE)
#import "RLAMQTTService.h"      // Relayr (Services/MQTT)
#import "RelayrErrors.h"        // Relayr (Utilities)

@implementation RLADispatcher

#pragma mark - Public API

- (instancetype)initWithUser:(RelayrUser*)user
{
    if (!user) { return nil; }
    
    self = [super init];
    if (self)
    {
        _user = user;
        user.apiService = [[RLAAPIService alloc] initWithUser:user];
    }
    return self;
}

- (void)queryDataFromReading:(RelayrReading*)reading
{
    // TODO:
}

- (void)subscribeToDataFromReading:(RelayrReading*)reading
{
    if (!reading) { return; }
    
    __weak RelayrReading* weakReading = reading;
    __weak RelayrDevice* weakDevice = (RelayrDevice*)reading.deviceModel;
    
    [self selectServiceForDevice:weakDevice completion:^(NSError* error, id<RLAService> service) {
        if (error) { return [weakReading errorReceived:error atDate:[NSDate date]]; }
        
        [service subscribeToDataFromDevice:weakDevice completion:^(NSError* error) {
            if (error) { [weakReading errorReceived:error atDate:[NSDate date]]; }
        }];
    }];
}

- (void)subscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofReading:(RelayrReading*)reading
{
    // TODO:
}

- (void)unsubscribeToDataFromReading:(RelayrReading*)reading
{
    if (!reading) { return; }
    
    __weak RelayrDevice* weakDevice = (RelayrDevice*)reading.deviceModel;
    [self selectServiceForDevice:weakDevice completion:^(NSError* error, id<RLAService> service) {
        [service unsubscribeToDataFromDevice:weakDevice];
    }];
}

- (void)unsubscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofReading:(RelayrReading*)reading
{
    // TODO:
}

- (void)unsubscribeToCommunicationChannelStateOfReading:(RelayrReading*)reading
{
    // TODO:
}

#pragma mark NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private functionality

- (void)selectServiceForDevice:(RelayrDevice*)device completion:(void (^)(NSError* error, id <RLAService> service))completion
{
    if (!completion) { return; }
    if (!device) { return completion(RelayrErrorMissingArgument, nil); }
    
    RelayrUser* user = device.user;
    if (!user) { return completion(RelayrErrorMissingObjectPointer, nil); }
    
    id <RLAService> selectedService = [self serviceCurrentlyInUseByDevice:device];
    if (selectedService) { return completion(nil, selectedService); }
    
    // TODO: For now, we always return an MQTT service and we are calling the wrong initialiser. Fix it!!!
    if (!user.mqttService)
    {
        RLAMQTTService* mqttService = [[RLAMQTTService alloc] initWithUser:user device:device];     // Change to only support device
        if (!mqttService) { return completion(RelayrErrorNoServiceAvailable, nil); }
        user.mqttService = mqttService;
    }
    
    return completion(nil, user.mqttService);
}

- (id<RLAService>)serviceCurrentlyInUseByDevice:(RelayrDevice*)device
{
    RelayrUser* user = device.user;
    if (!user) { return nil; }
    
    RelayrConnectionProtocol const protocolInUse = device.connection.protocol;
    return  (protocolInUse == RelayrConnectionProtocolBLE)  ? user.bleService :
    (protocolInUse == RelayrConnectionProtocolMQTT) ? user.mqttService : nil;
}

@end
