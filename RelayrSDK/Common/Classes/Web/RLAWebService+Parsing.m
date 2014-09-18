#import "RLAWebService+Parsing.h"       // Header
#import "RelayrApp.h"                   // Relayr.framework (Public)
#import "RelayrUser.h"                  // Relayr.framework (Public)
#import "RelayrPublisher.h"             // Relayr.framework (Public)
#import "RelayrTransmitter.h"           // Relayr.framework (Public)
#import "RelayrDevice.h"                // Relayr.framework (Public)
#import "RelayrDeviceModel.h"           // Relayr.framework (Public)
#import "RelayrFirmware.h"              // Relayr.framework (Public)
#import "RelayrFirmwareModel.h"         // Relayr.framework (Public)
#import "RelayrInput.h"                 // Relayr.framework (Public)
#import "RelayrOutput.h"                // Relayr.framework (Public)
#import "RelayrApp_Setup.h"             // Relayr.framework (Private)
#import "RelayrUser_Setup.h"            // Relayr.framework (Private)
#import "RelayrPublisher_Setup.h"       // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h"     // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"          // Relayr.framework (Private)
#import "RelayrDeviceModel_Setup.h"     // Relayr.framework (Private)
#import "RelayrFirmware_Setup.h"        // Relayr.framework (Private)
#import "RelayrFirmwareModel_Setup.h"   // Relayr.framework (Private)
#import "RelayrInput_Setup.h"           // Relayr.framework (Private)
#import "RLAWebConstants.h"             // Relayr.framework (Web)

@implementation RLAWebService (Parsing)

+ (RelayrUser*)parseUserFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
    // TODO: Fill up
    return nil;
}

+ (RelayrPublisher*)parsePublisherFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
    RelayrPublisher* publisher = [[RelayrPublisher alloc] initWithPublisherID:jsonDict[Web_RespondKey_PublisherID] owner:jsonDict[Web_RespondKey_PublisherOwner]];
    if (!publisher) { return nil; }
    
    publisher.name = jsonDict[Web_RespondKey_PublisherName];
    return publisher;
}

+ (RelayrApp*)parseAppFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
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
    if (!jsonDict) { return nil; }
    
    RelayrTransmitter* transmitter = [[RelayrTransmitter alloc] initWithID:jsonDict[Web_RespondKey_TransmitterID] secret:jsonDict[Web_RespondKey_TransmitterSecret]];
    if (!transmitter) { return nil; }
    
    transmitter.owner = jsonDict[Web_RespondKey_TransmitterOwner];
    transmitter.name = jsonDict[Web_RespondKey_TransmitterName];
    return transmitter;
}

+ (RelayrDevice*)parseDeviceFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
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

+ (RelayrDeviceModel*)parseDeviceModelFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
    
    
    // TODO: Fill up
    return nil;
}

+ (RelayrFirmware*)parseFirmwareFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
    RelayrFirmware* firModel = [[RelayrFirmware alloc] initWithVersion:jsonDict[Web_RespondKey_FirmwareVersion]];
    if (!firModel) { return nil; }
    
    NSDictionary* configuration = jsonDict[Web_RespondKey_FirmwareConfiguration];
    NSDictionary* properties = ((NSDictionary*)configuration[Web_RespondKey_FirmwareSchema])[JSONSchema_Keyword_Properties];
    NSDictionary* defaultValue = configuration[Web_RespondKey_DefaultValues];
    
    NSUInteger const numProperties = properties.count;
    if (numProperties)
    {
        NSMutableDictionary* firmwareConfs = [[NSMutableDictionary alloc] initWithCapacity:configuration.count];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString* confKey = key;
            id confValue = [RLAWebService objectFromJSONSchemaWithType:((NSDictionary*)obj)[JSONSchema_Keyword_Type] withDefaultValue:defaultValue[confKey]];
            if (confValue) { firmwareConfs[key] = confValue; }
        }];
    }
    
    return firModel;
}

+ (RelayrFirmwareModel*)parseFirmwareModelFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
    RelayrFirmwareModel* firModel = [[RelayrFirmwareModel alloc] initWithVersion:jsonDict[Web_RespondKey_FirmwareVersion]];
    if (!firModel) { return nil; }
    
    NSDictionary* configuration = jsonDict[Web_RespondKey_FirmwareConfiguration];
    NSDictionary* properties = ((NSDictionary*)configuration[Web_RespondKey_FirmwareSchema])[JSONSchema_Keyword_Properties];
    NSDictionary* defaultValue = configuration[Web_RespondKey_DefaultValues];
    
    NSUInteger const numProperties = properties.count;
    if (numProperties)
    {
        NSMutableDictionary* firmwareConfs = [[NSMutableDictionary alloc] initWithCapacity:configuration.count];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString* confKey = key;
            id confValue = [RLAWebService objectFromJSONSchemaWithType:((NSDictionary*)obj)[JSONSchema_Keyword_Type] withDefaultValue:defaultValue[confKey]];
            if (confValue) { firmwareConfs[key] = confValue; }
        }];
    }
    
    return firModel;
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

// Change this...
+ (id)objectFromJSONSchemaWithType:(NSString*)type withDefaultValue:(id)defaultValue
{
    id result;
    
    if ([type isEqualToString:JSONSchema_Type_Integer])
    {
        result = defaultValue;
    }
    else if ([type isEqualToString:JSONSchema_Type_Number])
    {
        result = defaultValue;
    }
    else if ([type isEqualToString:JSONSchema_Type_Boolean])
    {
        result = defaultValue;
    }
    else if ([type isEqualToString:JSONSchema_Type_String])
    {
        result = defaultValue;
    }
    else if ([type isEqualToString:JSONSchema_Type_Null])
    {
        result = [NSNull null];
    }
    else
    {
        result = nil;
    }
    
    return result;
}

@end
