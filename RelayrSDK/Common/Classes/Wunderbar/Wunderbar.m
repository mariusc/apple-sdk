#import "Wunderbar.h"           // Header
#import "WunderbarConstants.h"  // Relayr (Wunderbar)
#import "RelayrTransmitter.h"   // Relayr (Public)
#import "RelayrDevice.h"        // Relayr (Public)

@implementation Wunderbar

+ (BOOL)isWunderbar:(RelayrTransmitter*)transmitter
{
    if (!transmitter.uid) { return NO; }
    
    NSUInteger const numDevices = transmitter.devices.count;
    if (numDevices < 6) { return NO; }
    
    if ( ![Wunderbar humidityTemperatureDeviceFromWunderbar:transmitter] ||
         ![Wunderbar gyroscopeDeviceFromWunderbar:transmitter]           ||
         ![Wunderbar lighProximityDeviceFromWunderbar:transmitter]       ||
         ![Wunderbar microphoneDeviceFromWunderbar:transmitter]          ||
         ![Wunderbar bridgeDeviceFromWunderbar:transmitter]              ||
         ![Wunderbar infraredDeviceFromWunderbar:transmitter] ) { return NO; }
    
    return YES;
}

+ (BOOL)isDeviceSupportedByWunderbar:(RelayrDevice*)device
{
    NSString* modelID = device.modelID;
    if (!modelID) { return NO; }
    
    if ( [modelID isEqualToString:Wunderbar_devicemodel_gyroscope]   ||
         [modelID isEqualToString:Wunderbar_devicemodel_light]       ||
         [modelID isEqualToString:Wunderbar_devicemodel_microphone]  ||
         [modelID isEqualToString:Wunderbar_devicemodel_thermometer] ||
         [modelID isEqualToString:Wunderbar_devicemodel_bridge]      ||
         [modelID isEqualToString:Wunderbar_devicemodel_infrared] ) { return YES; }
    
    return NO;
}

+ (RelayrDevice*)gyroscopeDeviceFromWunderbar:(RelayrTransmitter*)transmitter
{
    for (RelayrDevice* device in transmitter.devices)
    {
        if ([device.modelID isEqualToString:Wunderbar_devicemodel_gyroscope]) { return device; }
    }
    return nil;
}

+ (RelayrDevice*)lighProximityDeviceFromWunderbar:(RelayrTransmitter*)transmitter
{
    for (RelayrDevice* device in transmitter.devices)
    {
        if ([device.modelID isEqualToString:Wunderbar_devicemodel_light]) { return device; }
    }
    return nil;
}

+ (RelayrDevice*)microphoneDeviceFromWunderbar:(RelayrTransmitter*)transmitter
{
    for (RelayrDevice* device in transmitter.devices)
    {
        if ([device.modelID isEqualToString:Wunderbar_devicemodel_microphone]) { return device; }
    }
    return nil;
}

+ (RelayrDevice*)humidityTemperatureDeviceFromWunderbar:(RelayrTransmitter*)transmitter
{
    for (RelayrDevice* device in transmitter.devices)
    {
        if ([device.modelID isEqualToString:Wunderbar_devicemodel_thermometer]) { return device; }
    }
    return nil;
}

+ (RelayrDevice*)bridgeDeviceFromWunderbar:(RelayrTransmitter*)transmitter
{
    for (RelayrDevice* device in transmitter.devices)
    {
        if ([device.modelID isEqualToString:Wunderbar_devicemodel_bridge]) { return device; }
    }
    return nil;
}

+ (RelayrDevice*)infraredDeviceFromWunderbar:(RelayrTransmitter*)transmitter
{
    for (RelayrDevice* device in transmitter.devices)
    {
        if ([device.modelID isEqualToString:Wunderbar_devicemodel_infrared]) { return device; }
    }
    return nil;
}

+ (NSString*)advertisementLocalNameForWunderbarDevice:(RelayrDevice*)device
{
    NSString* modelID = device.modelID;
    if (!modelID) { return nil; }
    NSString* result;
    
    if ( [modelID isEqualToString:Wunderbar_devicemodel_gyroscope] )
    {
        result = Wunderbar_deviceAdvertisement_gyroscope;
    }
    else if ( [modelID isEqualToString:Wunderbar_devicemodel_light] )
    {
        result = Wunderbar_deviceAdvertisement_light;
    }
    else if ( [modelID isEqualToString:Wunderbar_devicemodel_microphone] )
    {
        result = Wunderbar_deviceAdvertisement_microphone;
    }
    else if ( [modelID isEqualToString:Wunderbar_devicemodel_thermometer] )
    {
        result = Wunderbar_deviceAdvertisement_thermometer;
    }
    else if ( [modelID isEqualToString:Wunderbar_devicemodel_infrared] )
    {
        result = Wunderbar_deviceAdvertisement_infrared;
    }
    else if ( [modelID isEqualToString:Wunderbar_devicemodel_bridge] )
    {
        result = Wunderbar_deviceAdvertisement_bridge;
    }
    
    return result;
}

@end
