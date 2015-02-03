#import "RLAServiceSelector.h"      // Header

#import "RelayrUser.h"              // Relayr (Public)
#import "RelayrDevice.h"            // Relayr (Public)
#import "RelayrConnection.h"        // Relayr (Public)
#import "RelayrErrors.h"            // Relyar.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr (Private)
#import "RLABLEService.h"           // Relayr (Service/BLE)
#import "RLAMQTTService.h"          // Relayr (Service/MQTT)

@implementation RLAServiceSelector

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (void)selectServiceForDevice:(RelayrDevice*)device completion:(void (^)(NSError* error, id <RLAService> service))completion
{
    if (!completion) { return; }
    if (!device) { return completion(RelayrErrorMissingArgument, nil); }
    
    RelayrUser* user = device.user;
    if (!user) { return completion(RelayrErrorMissingObjectPointer, nil); }
    
    id <RLAService> selectedService = [RLAServiceSelector serviceCurrentlyInUseByDevice:device];
    if (selectedService) { return completion(nil, selectedService); }
    
    // FIXME: For now, we always return an MQTT service and we are calling the wrong initialiser. Fix it!!!
    if (!user.mqttService)
    {
        RLAMQTTService* mqttService = [[RLAMQTTService alloc] initWithUser:user device:device];
        if (!mqttService) { return completion(RelayrErrorNoServiceAvailable, nil); }
        user.mqttService = mqttService;
    }
    
    return completion(nil, user.mqttService);
}

+ (id<RLAService>)serviceCurrentlyInUseByDevice:(RelayrDevice*)device
{
    RelayrUser* user = device.user;
    if (!user) { return nil; }
    
    RelayrConnectionProtocol const protocolInUse = device.connection.protocol;
    return  (protocolInUse == RelayrConnectionProtocolBLE)  ? user.bleService :
            (protocolInUse == RelayrConnectionProtocolMQTT) ? user.mqttService : nil;
}

@end
