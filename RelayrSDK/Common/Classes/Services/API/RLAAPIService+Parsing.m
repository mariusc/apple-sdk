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
#import "RelayrOutput_Setup.h"          // Relayr.framework (Private)
#import "RLAAPIConstants.h"             // Relayr.framework (Service/API)

@implementation RLAAPIService (Parsing)

+ (RelayrApp*)parseAppFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict.count) { return nil; }

    NSString* appID = (jsonDict[dRLAAPI_App_RespondKey_ID]) ? jsonDict[dRLAAPI_App_RespondKey_ID] : jsonDict[dRLAAPI_App_RespondKey_App];
    RelayrApp* app = [[RelayrApp alloc] initWithID:appID];
    if (!app) { return nil; }

    app.name = jsonDict[dRLAAPI_App_RespondKey_Name];
    app.publisherID = jsonDict[dRLAAPI_App_RespondKey_Owner];
    app.oauthClientSecret = jsonDict[dRLAAPI_App_RespondKey_OAuthClientSecret];
    app.appDescription = jsonDict[dRLAAPI_App_RespondKey_Description];
    app.redirectURI = jsonDict[dRLAAPI_App_RespondKey_RedirectURI];
    return app;
}

+ (RelayrUser*)paraseUserFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict.count) { return nil; }
    
    RelayrUser* user = [[RelayrUser alloc] initWithID:jsonDict[dRLAAPI_User_RespondKey_ID]];
    if (!user) { return nil; }
    
    user.name = jsonDict[dRLAAPI_User_RespondKey_Name];
    user.email = jsonDict[dRLAAPI_User_RespondKey_Email];
    return user;
}

+ (RelayrPublisher*)parsePublisherFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict.count) { return nil; }
    
    RelayrPublisher* publisher = [[RelayrPublisher alloc] initWithPublisherID:jsonDict[dRLAAPI_Publisher_RespondKey_ID]];
    if (!publisher) { return nil; }
    
    publisher.name = jsonDict[dRLAAPI_Publisher_RespondKey_Name];
    publisher.owner = jsonDict[dRLAAPI_Publisher_RespondKey_Owner];
    return publisher;
}

- (RelayrTransmitter*)parseTransmitterFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict.count) { return nil; }

    RelayrTransmitter* transmitter = [[RelayrTransmitter alloc] initWithID:jsonDict[dRLAAPI_Transmitter_RespondKey_ID]];
    if (!transmitter) { return nil; }

    transmitter.user = self.user;
    transmitter.name = jsonDict[dRLAAPI_Transmitter_RespondKey_Name];
    transmitter.owner = jsonDict[dRLAAPI_Transmitter_RespondKey_Owner];
    transmitter.secret = jsonDict[dRLAAPI_Transmitter_RespondKey_Secret];
    return transmitter;
}

- (RelayrDevice*)parseDeviceFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }

    NSString* modelID;
    NSDictionary* modelDict;

    id tmp = jsonDict[dRLAAPI_Device_RespondKey_Model];
    if ([tmp isKindOfClass:[NSDictionary class]])
    {
        modelDict = tmp;
        modelID = modelDict[dRLAAPI_DeviceModel_RespondKey_ID];
    }
    else if ([tmp isKindOfClass:[NSString class]])
    {
        modelID = tmp;
    }
    else { return nil; }

    RelayrDevice* device = [[RelayrDevice alloc] initWithID:jsonDict[dRLAAPI_Device_RespondKey_ID] modelID:modelID];
    if (!device) { return nil; }

    device.user = self.user;
    device.name = jsonDict[dRLAAPI_Device_RespondKey_Name];
    device.owner = jsonDict[dRLAAPI_Device_RespondKey_Owner];
    device.firmware = [[RelayrFirmware alloc] initWithVersion:jsonDict[dRLAAPI_Device_RespondKey_Firmware]];
    device.firmware.deviceModel = device;
    device.secret = jsonDict[dRLAAPI_Device_RespondKey_Secret];

    NSNumber* isPublic = jsonDict[dRLAAPI_Device_RespondKey_Public];
    device.isPublic = (isPublic) ? isPublic : @YES;

    [self parseDeviceModelFromJSONDictionary:modelDict inDeviceObject:device];
    return device;
}

- (RelayrDeviceModel*)parseDeviceModelFromJSONDictionary:(NSDictionary*)jsonDict inDeviceObject:(RelayrDevice*)device
{
    if (!jsonDict) { return device; }

    RelayrDeviceModel* deviceModel;
    if (!device)
    {
        deviceModel = [[RelayrDeviceModel alloc] initWithModelID:jsonDict[dRLAAPI_DeviceModel_RespondKey_ID]];
        if (!deviceModel) { return nil; }
    }
    else { deviceModel = device; }

    deviceModel.user = self.user;
    deviceModel.modelName = jsonDict[dRLAAPI_DeviceModel_RespondKey_Name];
    deviceModel.manufacturer = jsonDict[dRLAAPI_DeviceModel_RespondKey_Manufacturer];
    deviceModel.inputs = [self parseDeviceReadingsFromJSONArray:jsonDict[dRLAAPI_DeviceModel_RespondKey_Readings] ofDevice:deviceModel];
    //device.outputs = [RLAAPIService parseDeviceWritingsFromJSONArray:dict[<#name#>];

    NSDictionary* availableFirms = jsonDict[dRLAAPI_DeviceModel_RespondKey_Firmware];
    if (availableFirms.count)
    {
        NSMutableArray* firms = [[NSMutableArray alloc] initWithCapacity:availableFirms.count];
        for (NSDictionary* firmDict in availableFirms)
        {
            RelayrFirmwareModel* firmModel = [self parseFirmwareModelFromJSONDictionary:firmDict inFirmwareObject:nil ofDeviceModel:deviceModel];
            if (firmModel) { [firms addObject:firmModel]; }
        }
        deviceModel.firmwaresAvailable = [NSArray arrayWithArray:firms];
    }

    return deviceModel;
}

- (RelayrFirmwareModel*)parseFirmwareModelFromJSONDictionary:(NSDictionary*)jsonDict inFirmwareObject:(RelayrFirmware*)firmware ofDeviceModel:(RelayrDeviceModel*)deviceModel
{
    if (!jsonDict) { return firmware; }

    RelayrFirmwareModel* firModel;
    if (!firmware)
    {
        firModel = [[RelayrFirmwareModel alloc] initWithVersion:jsonDict[dRLAAPI_DeviceFirmware_RespondKey_Version]];
        if (!firModel) { return nil; }
    }
    else { firModel = firmware; }

    firModel.deviceModel = deviceModel;
    
    NSDictionary* configuration = jsonDict[dRLAAPI_DeviceFirmware_RespondKey_Configuration];
    NSDictionary* defaultValue = configuration[dRLAAPI_DeviceFirmware_RespondKey_DefaultValues];
    NSDictionary* properties = ((NSDictionary*)configuration[dRLAAPI_DeviceFirmware_RespondKey_Schema])[JSONSchema_Keyword_Properties];
    
    NSMutableDictionary* firmProperties = [[NSMutableDictionary alloc] initWithCapacity:configuration.count];
    if (properties.count==defaultValue.count)
    {
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString* confKey = key;
            id confValue = [self objectFromJSONSchemaWithType:((NSDictionary*)obj)[JSONSchema_Keyword_Type] withDefaultValue:defaultValue[confKey]];
            if (confValue) { firmProperties[key] = confValue; }
        }];

        firModel.configuration = firmProperties;
    }

    return firModel;
}

#pragma mark - Private methods

/*!
 *  @abstract This methods parses the <code>reading</code> property of the device model.
 *  @discussion It will return a set of <code>RelayrInput</code> objects.
 */
- (NSSet*)parseDeviceReadingsFromJSONArray:(NSArray*)jsonArray ofDevice:(RelayrDeviceModel*)device
{
    if (!jsonArray) { return nil; }

    NSUInteger const numInputs = jsonArray.count;
    if (numInputs == 0) { return [NSSet set]; }

    NSMutableSet* result = [NSMutableSet setWithCapacity:numInputs];
    for (NSDictionary* dict in jsonArray)
    {
        RelayrInput* input = [[RelayrInput alloc] initWithMeaning:dict[dRLAAPI_DeviceReading_RespondKey_Meaning] unit:dict[dRLAAPI_DeviceReading_RespondKey_Unit]];
        if (!input) { continue; }

        input.deviceModel = device;
        [result addObject:input];
    }

    return [NSSet setWithSet:result];
}

/*!
 *  @abstract This methods parses the <code>...</code> property of the device model.
 *  @discussion It will return a set of <code>RelayrOutput</code> objects.
 */
- (NSSet*)parseDeviceWritingsFromJSONArray:(NSArray*)jsonArray ofDevice:(RelayrDevice*)device
{
    if (!jsonArray) { return nil; }

    NSUInteger const numOutputs = jsonArray.count;
    if (numOutputs == 0) { return [NSSet set]; }
    
    NSMutableSet* result = [NSMutableSet setWithCapacity:numOutputs];
//    for (NSDictionary* dict in jsonArray)
//    {
//        RelayrOutput* output = [[RelayrOutput alloc] initWithMeaning:nil];
//        if (!output) { continue; }
//        
//        output.deviceModel = device;
//        [result addObject:output];
//    }

    return [NSSet setWithSet:result];
}

/*!
 *  @abstract It returns a value understandable by Cocoa from a JSON object.
 */
- (id)objectFromJSONSchemaWithType:(NSString*)type withDefaultValue:(id)defaultValue
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
