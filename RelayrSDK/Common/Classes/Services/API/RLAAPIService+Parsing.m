#import "RLAAPIService+Parsing.h"       // Header
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
#import "RLAAPIConstants.h"             // Relayr.framework (Service/API)

@implementation RLAAPIService (Parsing)

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

    NSString* appID = (jsonDict[Web_RespondKey_AppID]) ? jsonDict[Web_RespondKey_AppID] : jsonDict[Web_RespondKey_AppID_];
    RelayrApp* app = [[RelayrApp alloc] initWithID:appID];
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

    RelayrTransmitter* transmitter = [[RelayrTransmitter alloc] initWithID:jsonDict[Web_RespondKey_TransmitterID]];
    if (!transmitter) { return nil; }

    transmitter.name = jsonDict[Web_RespondKey_TransmitterName];
    transmitter.owner = jsonDict[Web_RespondKey_TransmitterOwner];
    transmitter.secret = jsonDict[Web_RespondKey_TransmitterSecret];
    return transmitter;
}

+ (RelayrDevice*)parseDeviceFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }

    NSString* modelID;
    NSDictionary* modelDict;

    id tmp = jsonDict[Web_RespondKey_DeviceModel];
    if ([tmp isKindOfClass:[NSDictionary class]])
    {
        modelDict = tmp;
        modelID = modelDict[Web_RespondKey_ModelID];
    }
    else if ([tmp isKindOfClass:[NSString class]])
    {
        modelID = tmp;
    }
    else { return nil; }

    RelayrDevice* device = [[RelayrDevice alloc] initWithID:jsonDict[Web_RespondKey_DeviceID] modelID:modelID];
    if (!device) { return nil; }

    device.name = jsonDict[Web_RespondKey_DeviceName];
    device.owner = jsonDict[Web_RespondKey_DeviceOwner];
    device.firmware = [[RelayrFirmware alloc] initWithVersion:jsonDict[Web_RespondKey_DeviceFirmware]];
    device.secret = jsonDict[Web_RespondKey_DeviceSecret];

    NSNumber* isPublic = jsonDict[Web_RespondKey_DevicePublic];
    device.isPublic = (isPublic) ? isPublic : @YES;

    [RLAAPIService parseDeviceModelFromJSONDictionary:modelDict inDeviceObject:device];
    return device;
}

+ (RelayrDeviceModel*)parseDeviceModelFromJSONDictionary:(NSDictionary*)jsonDict inDeviceObject:(RelayrDevice*)device
{
    if (!jsonDict) { return device; }

    RelayrDeviceModel* deviceModel;
    if (!device)
    {
        deviceModel = [[RelayrDeviceModel alloc] initWithModelID:jsonDict[Web_RespondKey_ModelID]];
        if (!deviceModel) { return nil; }
    }
    else { deviceModel = device; }

    deviceModel.modelName = jsonDict[Web_RespondKey_ModelName];
    deviceModel.manufacturer = jsonDict[Web_RespondKey_ModelManufacturer];
    deviceModel.inputs = [RLAAPIService parseDeviceReadingsFromJSONArray:jsonDict[Web_RespondKey_ModelReadings] ofDevice:deviceModel];
    //device.outputs = [RLAAPIService parseDeviceWritingsFromJSONArray:dict[<#name#>];  // TODO: Do the outputs

    NSDictionary* availableFirms = jsonDict[Web_RespondKey_ModelFirmwares];
    if (availableFirms)
    {
        NSMutableArray* firms = [[NSMutableArray alloc] initWithCapacity:availableFirms.count];
        for (NSDictionary* firmDict in availableFirms)
        {
            RelayrFirmwareModel* firmModel = [RLAAPIService parseFirmwareModelFromJSONDictionary:firmDict inFirmwareObject:nil];
            if (firmModel) { [firms addObject:firmModel]; }
        }
        deviceModel.firmwaresAvailable = [NSArray arrayWithArray:firms];
    }

    return deviceModel;
}

+ (RelayrFirmware*)parseFirmwareFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }

    RelayrFirmware* firmware = [[RelayrFirmware alloc] initWithVersion:jsonDict[Web_RespondKey_FirmwareVersion]];
    if (!firmware) { return nil; }

    [RLAAPIService parseFirmwareModelFromJSONDictionary:jsonDict inFirmwareObject:firmware];
    return firmware;
}

+ (RelayrFirmwareModel*)parseFirmwareModelFromJSONDictionary:(NSDictionary*)jsonDict inFirmwareObject:(RelayrFirmware*)firmware
{
    if (!jsonDict) { return firmware; }

    RelayrFirmwareModel* firModel;
    if (!firmware)
    {
        firModel = [[RelayrFirmwareModel alloc] initWithVersion:jsonDict[Web_RespondKey_FirmwareVersion]];
        if (!firModel) { return nil; }
    }
    else { firModel = firmware; }

    /*  // TODO: Look at the configurations
    NSDictionary* configuration = jsonDict[Web_RespondKey_FirmwareConfiguration];

    NSDictionary* defaultValue = configuration[Web_RespondKey_DefaultValues];
    NSDictionary* properties = ((NSDictionary*)configuration[Web_RespondKey_FirmwareSchema])[JSONSchema_Keyword_Properties];
    NSMutableDictionary* firmProperties = [[NSMutableDictionary alloc] initWithCapacity:configuration.count];

    if (properties.count==defaultValue.count)
    {
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString* confKey = key;
            id confValue = [RLAAPIService objectFromJSONSchemaWithType:((NSDictionary*)obj)[JSONSchema_Keyword_Type] withDefaultValue:defaultValue[confKey]];
            if (confValue) { firmProperties[key] = confValue; }
        }];

        firModel.configuration = firmProperties;
    }
     */

    return firModel;
}

#pragma mark - Private methods

/*******************************************************************************
 * This methods parses the <code>reading</code> property of the device model.
 * It will return a set of <code>RelayrInput</code> objects.
 ******************************************************************************/
+ (NSSet*)parseDeviceReadingsFromJSONArray:(NSArray*)jsonArray ofDevice:(RelayrDeviceModel*)device
{
    if (!jsonArray) { return nil; }

    NSUInteger const numInputs = jsonArray.count;
    if (numInputs == 0) { return [NSSet set]; }

    NSMutableSet* result = [NSMutableSet setWithCapacity:numInputs];
    for (NSDictionary* dict in jsonArray)
    {
        RelayrInput* input = [[RelayrInput alloc] initWithMeaning:dict[Web_RespondKey_ReadingsMeaning] unit:dict[Web_RespondKey_ReadingsUnit]];
        if (!input) { continue; }

        input.device = device;
        [result addObject:input];
    }

    return [NSSet setWithSet:result];
}

/*******************************************************************************
 * This methods parses the <code>...</code> property of the device model.
 * It will return a set of <code>RelayrOutput</code> objects.
 ******************************************************************************/
+ (NSSet*)parseDeviceWritingsFromJSONArray:(NSArray*)jsonArray ofDevice:(RelayrDevice*)device
{
    if (jsonArray) { return nil; }

    NSUInteger const numOutputs = jsonArray.count;
    if (numOutputs == 0) { return [NSSet set]; }

    NSMutableSet* result = [NSMutableSet setWithCapacity:jsonArray.count];
    // FIX ME: No outputs are yet tested.

    return [NSSet setWithSet:result];
}

// FIX ME: This method is pretty dumb. Wait till Dmitry really change the JSONSchema
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
