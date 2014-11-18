#import "RLAAPIService+Device.h"    // Header

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrDeviceModel.h"       // Relayr.framework (Public)
#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)
#import "RLAAPIService+Parsing.h"   // Relayr.framework (Service/API)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)

@implementation RLAAPIService (Device)

- (void)registerDeviceWithName:(NSString*)deviceName owner:(NSString*)ownerID model:(NSString*)modelID firmwareVersion:(NSString*)firmwareVersion completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!deviceName.length || !ownerID.length || !modelID.length || !firmwareVersion.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceRegister_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    
    NSDictionary* body = @{ dRLAAPI_Device_RequestKey_Name : deviceName, dRLAAPI_Device_RequestKey_Owner : ownerID, dRLAAPI_Device_RequestKey_Model : modelID, dRLAAPI_Device_RequestKey_FirmwareVersion : firmwareVersion };
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError, nil); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceRegister_ResponseCode, nil);
        
        RelayrDevice* result = [self parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)requestDevice:(NSString*)deviceID completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!completion) { return; }
    if (!deviceID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceInfo_RelativePath(deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceInfo_ResponseCode, nil);
        
        RelayrDevice* result = [self parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)setDevice:(NSString*)deviceID name:(NSString*)deviceName modelID:(NSString*)futureModelID isPublic:(NSNumber*)isPublic description:(NSString*)description completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceInfoSet_RelativePath(deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePATCH authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }

    NSMutableDictionary* body = [[NSMutableDictionary alloc] init];
    if (deviceName.length) { body[dRLAAPI_Device_RequestKey_Name] = deviceName; }
    if (description.length) { body[dRLAAPI_Device_RequestKey_Description] = description; }
    if (futureModelID.length) { body[dRLAAPI_Device_RequestKey_Model] = futureModelID; }
    if (isPublic) { body[dRLAAPI_Device_RequestKey_Public] = isPublic; }
    if (!body.count) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError, nil); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceInfoSet_ResponseCode, nil);
        
        RelayrDevice* result = [self parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)deleteDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceDelete_RelativePath(deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeDELETE authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_DeviceDelete_ResponseCode) ? RelayrErrorWebRequestFailure : nil);
    }];
    [task resume];
}

- (void)setConnectionBetweenDevice:(NSString*)deviceID andApp:(NSString*)appID completion:(void (^)(NSError* error, id credentials))completion
{
    if (!completion) { return; }
    if (!deviceID.length || !appID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceConnect_RelativePath(deviceID, appID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceConnect_ResponseCode, nil);
        return completion(nil, json);
    }];
    [task resume];
}

- (void)requestAppsConnectedToDevice:(NSString*)deviceID completion:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    if (!deviceID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceApps_RelativePath(deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceApps_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrApp* dev = [RLAAPIService parseAppFromJSONDictionary:dict]; if (dev) { [result addObject:dev]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)deleteConnectionBetweenDevice:(NSString*)deviceID andApp:(NSString*)appID completion:(void (^)(NSError* error))completion
{
    if (!deviceID.length || !appID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceDisconnect_RelativePath(deviceID, appID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeDELETE authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion ( (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_DeviceDisconnect_ResponseCode) ? RelayrErrorWebRequestFailure : nil );
    }];
    [task resume];
}

- (void)sendToDeviceID:(NSString*)deviceID withMeaning:(NSString*)meaning value:(NSString*)value completion:(void (^)(NSError* error))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceSend_RelativePath(deviceID, meaning)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion ( (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_DeviceSend_ResponseCode) ? RelayrErrorWebRequestFailure : nil );
    }];
    [task resume];
}

- (void)requestPublicDevices:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DevicesPublic_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_DevicesPublic_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrDevice* dev = [self parseDeviceFromJSONDictionary:dict]; if (dev) { [result addObject:dev]; } }
        return completion(nil, (result.count) ? [NSSet setWithSet:result] : nil);
    }];
    [task resume];
}

- (void)requestPublicDevicesFilteredByMeaning:(NSString*)meaning completion:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!meaning) { return [self requestPublicDevices:completion]; }
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DevicesPublicMean_RelativePath(meaning)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_DevicesPublicMean_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrDevice* dev = [self parseDeviceFromJSONDictionary:dict]; if (dev) { [result addObject:dev]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

+ (void)setConnectionToPublicDevice:(NSString*)deviceID completion:(void (^)(NSError* error, id credentials))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:dRLAAPI_Host relativeString:dRLAAPI_DevicesPublicSub_RelativePath(deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:nil];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }

    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_DevicesPublicSub_ResponseCode, nil);
        return completion(nil, json);
    }];
    [task resume];
}

- (void)requestAllDeviceModels:(void (^)(NSError* error, NSSet* deviceModels))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceModels_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceModels_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrDeviceModel* devModel = [self parseDeviceModelFromJSONDictionary:dict inDeviceObject:nil]; if (devModel) { [result addObject:devModel]; } }
        return completion(nil, (result.count) ? [NSSet setWithSet:result] : nil);
    }];
    [task resume];
}

- (void)requestDeviceModel:(NSString*)deviceModelID completion:(void (^)(NSError* error, RelayrDeviceModel* deviceModel))completion
{
    if (!completion) { return; }
    if (!deviceModelID) { return completion(RelayrErrorMissingArgument, nil); }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceModelGet_RelativePath(deviceModelID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceModelGet_ResponseCode, nil);
        
        RelayrDeviceModel* devModel = [self parseDeviceModelFromJSONDictionary:json inDeviceObject:nil];
        return (!deviceModelID) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, devModel);
    }];
    [task resume];
}

- (void)requestAllDeviceMeanings:(void (^)(NSError* error, NSDictionary* meanings))completion
{
    if (!completion) { return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceModelMean_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceModelMean_ResponseCode, nil);
        
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            NSString* key = dict[dRLAAPI_DeviceModel_RespondKey_Key];
            NSString* value = dict[dRLAAPI_DeviceModel_RespondKey_Value];
            if (key && value) { result[key] = value; }
        }
        
        return completion(nil, [NSDictionary dictionaryWithDictionary:result]);
    }];
    [task resume];
}

- (void)requestFirmwaresFromDeviceModel:(NSString*)deviceModelID completion:(void (^)(NSError*, NSArray*))completion
{
    if (!completion) { return; }
    if (!deviceModelID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceModelFirmwares_RelativePath(deviceModelID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceModelFirmwares_RepsonseCode, nil);
        
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrFirmwareModel* firmwareModel = [self parseFirmwareModelFromJSONDictionary:dict inFirmwareObject:nil];
            if (firmwareModel) { [result addObject:firmwareModel]; }
        }
        return completion(nil, [NSArray arrayWithArray:result]);
    }];
    [task resume];
}

- (void)requestFirmwareWithVersion:(NSString *)versionString fromDeviceModel:(NSString *)deviceModelID completion:(void (^)(NSError *, RelayrFirmwareModel *))completion
{
    if (!completion) { return; }
    if (!versionString.length || !deviceModelID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_DeviceModelFirmwareVersion_RelativePath(deviceModelID, versionString)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_DeviceModelFirmwareVersion_ResponseCode, nil);
        
        RelayrFirmwareModel* firmwareModel = [self parseFirmwareModelFromJSONDictionary:json inFirmwareObject:nil];
        return (!firmwareModel) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, firmwareModel);
    }];
    [task resume];
}

@end
