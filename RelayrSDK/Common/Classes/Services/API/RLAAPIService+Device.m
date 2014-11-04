#import "RLAAPIService+Device.h"    // Header
#import "RLAAPIService+Parsing.h"   // Relayr.framework (Service/API)

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrDeviceModel.h"       // Relayr.framework (Public)
#import "RLAAPIRequest.h"           // Relayr.framework (Service/API)
#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)

@implementation RLAAPIService (Device)

- (void)registerDeviceWithName:(NSString*)deviceName owner:(NSString*)ownerID model:(NSString*)modelID firmwareVersion:(NSString*)firmwareVersion completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!deviceName.length || !ownerID.length || !modelID.length || !firmwareVersion.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_DevRegistration;
    request.body = @{ Web_RequestBodyKey_DevName : deviceName, Web_RequestBodyKey_DevOwner : ownerID, Web_RequestBodyKey_DevModel : modelID, Web_RequestBodyKey_DevFirmwareVersion : firmwareVersion };

    [request executeInHTTPMode:kRLAAPIRequestModePOST completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevRegistration, nil);

        RelayrDevice* result = [RLAAPIService parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)requestDevice:(NSString*)deviceID completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!completion) { return; }
    if (!deviceID.length) { return completion(RelayrErrorMissingArgument, nil); }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevInfo(deviceID);

    [request executeInHTTPMode:kRLAAPIRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevInfo, nil);

        RelayrDevice* result = [RLAAPIService parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)setDevice:(NSString*)deviceID name:(NSString*)deviceName modelID:(NSString*)futureModelID isPublic:(NSNumber*)isPublic description:(NSString*)description completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }

    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    if (deviceName.length) { tmpDict[Web_RequestBodyKey_DevName] = deviceName; }
    if (description.length) { tmpDict[Web_RequestBodyKey_DevDescription] = description; }
    if (futureModelID.length) { tmpDict[Web_RequestBodyKey_DevModel] = futureModelID; }
    if (isPublic) { tmpDict[Web_RequestBodyKey_DevPublic] = isPublic; }
    if (!tmpDict.count) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_DevInfoSet(deviceID);
    request.body = [NSDictionary dictionaryWithDictionary:tmpDict];

    [request executeInHTTPMode:kRLAAPIRequestModePATCH completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevInfoSet, nil);

        RelayrDevice* result = [RLAAPIService parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)deleteDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_DevDelete(deviceID);

    [request executeInHTTPMode:kRLAAPIRequestModeDELETE completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_DevDelete) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

- (void)setConnectionBetweenDevice:(NSString*)deviceID andApp:(NSString*)appID completion:(void (^)(NSError* error, id credentials))completion
{
    if (!completion) { return; }
    if (!deviceID.length || !appID.length) { return completion(RelayrErrorMissingArgument, nil); }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevConnection(deviceID, appID);

    [request executeInHTTPMode:kRLAAPIRequestModePOST completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevConnection, nil);
        return completion(nil, json);
    }];
}

- (void)requestAppsConnectedToDevice:(NSString*)deviceID completion:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    if (!deviceID.length) { return completion(RelayrErrorMissingArgument, nil); }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevConnected(deviceID);

    [request executeInHTTPMode:kRLAAPIRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_DevConnected, nil);

        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrApp* dev = [RLAAPIService parseAppFromJSONDictionary:dict];
            if (dev) { [result addObject:dev]; }
        }

        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)deleteConnectionBetweenDevice:(NSString*)deviceID andApp:(NSString*)appID completion:(void (^)(NSError* error))completion
{
    if (!deviceID.length || !appID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_DevDisconnect(deviceID, appID);

    [request executeInHTTPMode:kRLAAPIRequestModeDELETE completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_DevDisconnect) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

- (void)sendToDeviceID:(NSString*)deviceID withMeaning:(NSString*)meaning value:(NSString*)value completion:(void (^)(NSError* error))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_DevSend(deviceID, meaning);

    [request executeInHTTPMode:kRLAAPIRequestModePOST completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_DevSend) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

- (void)requestPublicDevices:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!completion) { return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevPublic;

    [request executeInHTTPMode:kRLAAPIRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_DevPublic, nil);

        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDevice* dev = [RLAAPIService parseDeviceFromJSONDictionary:dict];
            if (dev) { [result addObject:dev]; }
        }

        return completion(nil, (result.count) ? [NSSet setWithSet:result] : nil);
    }];
}

- (void)requestPublicDevicesFilteredByMeaning:(NSString*)meaning completion:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!meaning) { return [self requestPublicDevices:completion]; }
    if (!completion) { return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevPublicMeaning(meaning);

    [request executeInHTTPMode:kRLAAPIRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_DevPublic, nil);

        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDevice* dev = [RLAAPIService parseDeviceFromJSONDictionary:dict];
            if (dev) { [result addObject:dev]; }
        }

        return completion(nil, [NSSet setWithSet:result]);
    }];
}

+ (void)setConnectionToPublicDevice:(NSString*)deviceID completion:(void (^)(NSError* error, id credentials))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:Web_Host];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevPublicSubcription(deviceID);

    [request executeInHTTPMode:kRLAAPIRequestModePOST completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevPublicSubcription, nil);
        return completion(nil, json);
    }];
}

- (void)requestAllDeviceModels:(void (^)(NSError* error, NSSet* deviceModels))completion
{
    if (!completion) { return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevModel;

    [request executeInHTTPMode:kRLAAPIRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_DevModel, nil);

        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDeviceModel* devModel = [RLAAPIService parseDeviceModelFromJSONDictionary:dict inDeviceObject:nil];
            if (devModel) { [result addObject:devModel]; }
        }

        return completion(nil, (result.count) ? [NSSet setWithSet:result] : nil);
    }];
}

- (void)requestDeviceModel:(NSString*)deviceModelID completion:(void (^)(NSError* error, RelayrDeviceModel* deviceModel))completion
{
    if (!completion) { return; }
    if (!deviceModelID) { return completion(RelayrErrorMissingArgument, nil); }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevModelID(deviceModelID);

    [request executeInHTTPMode:kRLAAPIRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevModelID, nil);

        RelayrDeviceModel* devModel = [RLAAPIService parseDeviceModelFromJSONDictionary:json inDeviceObject:nil];
        return (!deviceModelID) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, devModel);
    }];
}

- (void)requestAllDeviceMeanings:(void (^)(NSError* error, NSDictionary* meanings))completion
{
    if (!completion) { return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevModelMeanings;

    [request executeInHTTPMode:kRLAAPIRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_DevModelMeanings, nil);

        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            NSString* key = dict[Web_RespondKey_DeviceModelKey];
            NSString* value = dict[Web_RespondKey_DeviceModelValue];
            if (key && value) { result[key] = value; }
        }

        return completion(nil, (result.count) ? [NSDictionary dictionaryWithDictionary:result] : nil);
    }];
}

@end
