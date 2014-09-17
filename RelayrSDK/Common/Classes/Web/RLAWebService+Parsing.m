#import "RLAWebService+Parsing.h"   // Header
#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrDeviceModel.h"       // Relayr.framework (Public)
#import "RelayrFirmware.h"          // Relayr.framework (Public)
#import "RelayrInput.h"             // Relayr.framework (Public)
#import "RelayrOutput.h"            // Relayr.framework (Public)
#import "RelayrApp_Setup.h"         // Relayr.framework (Private)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrPublisher_Setup.h"   // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h" // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)
#import "RelayrFirmware_Setup.h"    // Relayr.framework (Private)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)
#import "RLAWebConstants.h"         // Relayr.framework (Web)

@implementation RLAWebService (Parsing)

+ (RelayrUser*)parseUserFromJSONDictionary:(NSDictionary*)jsonDict
{
    // TODO: Fill up
    return nil;
}

+ (RelayrPublisher*)parsePublisherFromJSONDictionary:(NSDictionary*)jsonDict
{
    RelayrPublisher* publisher = [[RelayrPublisher alloc] initWithPublisherID:jsonDict[Web_RespondKey_PublisherID] owner:jsonDict[Web_RespondKey_PublisherOwner]];
    if (!publisher) { return nil; }
    
    publisher.name = jsonDict[Web_RespondKey_PublisherName];
    return publisher;
}

+ (RelayrApp*)parseAppFromJSONDictionary:(NSDictionary*)jsonDict
{
    RelayrApp* app = [[RelayrApp alloc] initWithID:jsonDict[Web_RespondKey_AppID]];
    if (!app) { return nil; }
    
    app.name = jsonDict[Web_RespondKey_AppName];
    app.publisherID = jsonDict[Web_RespondKey_AppOwner];
    app.oauthClientSecret = jsonDict[Web_RespondKey_AppOAuthClientSecret];
    app.appDescription = jsonDict[Web_RespondKey_AppDescription];
    app.redirectURI = jsonDict[Web_RespondKey_AppRedirectURI];
    return app;
}

+ (RelayrTransmitter*)parseTransmitterFromJSONDictionary:(NSDictionary*)jsonDict
{
    RelayrTransmitter* transmitter = [[RelayrTransmitter alloc] initWithID:jsonDict[Web_RespondKey_TransmitterID] secret:jsonDict[Web_RespondKey_TransmitterSecret]];
    if (!transmitter) { return nil; }
    
    transmitter.owner = jsonDict[Web_RespondKey_TransmitterOwner];
    transmitter.name = jsonDict[Web_RespondKey_TransmitterName];
    return transmitter;
}

+ (RelayrDevice*)parseDeviceFromJSONDictionary:(NSDictionary*)jsonDict
{
    id tmp = jsonDict[Web_RespondKey_DeviceModel];
    NSString* modelID = ([tmp isKindOfClass:[NSString class]])     ? tmp :
                        ([tmp isKindOfClass:[NSDictionary class]]) ? ((NSDictionary*)tmp)[Web_RespondKey_ModelID] : nil;
    
    RelayrDevice* device = [[RelayrDevice alloc] initWithID:jsonDict[Web_RespondKey_DeviceID] secret:jsonDict[Web_RespondKey_DeviceSecret] modelID:modelID];
    if (!device) { return nil; }
    
    device.name = jsonDict[Web_RespondKey_DeviceName];
    device.owner = jsonDict[Web_RespondKey_DeviceOwner];
    device.isPublic = jsonDict[Web_RespondKey_DevicePublic];
    
    NSString* firmVer = jsonDict[Web_RespondKey_DeviceFirmware];
    if (firmVer.length) { device.firmware = [[RelayrFirmware alloc] initWithVersion:firmVer]; }
    
    if ([tmp isKindOfClass:[NSDictionary class]] && ((NSDictionary*)tmp).count)
    {
        NSDictionary* modelDict = tmp;
        device.manufacturer = modelDict[Web_RespondKey_ModelManufacturer];
        device.inputs = [RLAWebService parseDeviceReadingsFromJSONArray:modelDict[Web_RespondKey_ModelReadings] ofDevice:device];
        //device.outputs = [RLAWebService parseDeviceWritingsFromJSONArray:dict[<#name#>];
    }
    
    return device;
}

+ (id <RelayrDeviceModel>)parseDeviceModelFromJSONDictionary:(NSDictionary*)jsonDict
{
    // TODO: Fill up
    return nil;
}

#pragma mark - Private methods

/*******************************************************************************
 * This methods parses the <code>reading</code> property of the device model.
 * It will return a set of <code>RelayrInput</code> objects.
 ******************************************************************************/
+ (NSSet*)parseDeviceReadingsFromJSONArray:(NSArray*)readings ofDevice:(RelayrDevice*)device
{
    if (!readings.count) { return nil; }
    
    NSMutableSet* result = [NSMutableSet setWithCapacity:readings.count];
    for (NSDictionary* dict in readings)
    {
        RelayrInput* input = [[RelayrInput alloc] initWithMeaning:dict[Web_RespondKey_ReadingsMeaning] unit:dict[Web_RespondKey_ReadingsUnit]];
        if (!input) { continue; }
        
        input.device = device;
        [result addObject:input];
    }
    
    return (result.count) ? [NSSet setWithSet:result] : nil;
}

/*******************************************************************************
 * This methods parses the <code>...</code> property of the device model.
 * It will return a set of <code>RelayrOutput</code> objects.
 ******************************************************************************/
+ (NSSet*)parseDeviceWritingsFromJSONArray:(NSArray*)writings ofDevice:(RelayrDevice*)device
{
    if (!writings.count) { return nil; }
    
    NSMutableSet* result = [NSMutableSet setWithCapacity:writings.count];
    //    for (NSDictionary* dict in writings)
    //    {
    //        // Fill up
    //    }
    
    return (result.count) ? [NSSet setWithSet:result] : nil;
    
    return nil;
}

@end
