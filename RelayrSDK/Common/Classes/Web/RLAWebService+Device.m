#import "RLAWebService+Device.h"    // Header
#import "RLAWebService+Parsing.h"   // Relayr.framework (Web)

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RLAWebConstants.h"         // Relayr.framework (Web)
#import "RLAError.h"                // Relayr.framework (Utilities)

@implementation RLAWebService (Device)

- (void)registerDeviceWithName:(NSString*)deviceName owner:(NSString*)ownerID model:(NSString*)modelID firmwareVersion:(NSString*)firmwareVersion completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!deviceName.length || !ownerID.length || !modelID.length || !firmwareVersion.length) { if (completion) { completion(RLAErrorMissingArgument, nil); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RLAErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_DevRegistration;
    request.body = @{ Web_RequestBodyKey_DevName : deviceName, Web_RequestBodyKey_DevOwner : ownerID, Web_RequestBodyKey_DevModel : modelID, Web_RequestBodyKey_DevFirmwareVersion : firmwareVersion };
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevRegistration, nil);
        
        RelayrDevice* result = [RLAWebService parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RLAErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)requestDevice:(NSString*)deviceID completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!completion) { return; }
    if (!deviceID.length) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { completion(RLAErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_DevInfo(deviceID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevInfo, nil);
        
        RelayrDevice* result = [RLAWebService parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RLAErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)setDevice:(NSString*)deviceID name:(NSString*)deviceName modelID:(NSString*)futureModelID isPublic:(NSNumber*)isPublic description:(NSString*)description completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!deviceID.length) { if (completion) { completion(RLAErrorMissingArgument, nil); } return; }
    
    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    if (deviceName.length) { tmpDict[Web_RequestBodyKey_DevName] = deviceName; }
    if (description.length) { tmpDict[Web_RequestBodyKey_DevDescription] = description; }
    if (futureModelID.length) { tmpDict[Web_RequestBodyKey_DevModel] = futureModelID; }
    if (isPublic) { tmpDict[Web_RequestBodyKey_DevPublic] = isPublic; }
    if (!tmpDict.count) { if (completion) { completion(RLAErrorMissingArgument, nil); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RLAErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_DevInfoSet(deviceID);
    request.body = [NSDictionary dictionaryWithDictionary:tmpDict];
    
    [request executeInHTTPMode:kRLAWebRequestModePATCH completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_DevInfoSet, nil);
        
        RelayrDevice* result = [RLAWebService parseDeviceFromJSONDictionary:json];
        return (!result) ? completion(RLAErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)deleteDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    
}

- (void)setConnectionBetweenDevice:(NSString*)deviceID andApp:(NSString*)appID completion:(void (^)(NSError* error, id credentials))completion
{
    
}

- (void)deleteConnectionBetweenDevice:(NSString*)deviceID andApp:(NSString*)appID completion:(void (^)(NSError* error))completion
{
    
}

- (void)requestPublicDevices:(void (^)(NSError* error, NSArray* devices))completion
{
    
}

- (void)requestPublicDevicesFilteredByMeaning:(NSString*)meaning completion:(void (^)(NSError* error, NSArray* devices))completion
{
    
}

+ (void)setConnectionToPublicDevice:(NSString*)deviceID completion:(void (^)(NSError* error, id credentials))completion
{
    
}

- (void)requestAllDeviceModels:(void (^)(NSError* error, NSArray* deviceModels))completion
{
    
}

- (void)requestDeviceModel:(NSString*)deviceModelID completion:(void (^)(NSError* error, id <RelayrDeviceModel> deviceModel))completion
{
    
}

- (void)requestAllDeviceMeanings:(void (^)(NSError* error, NSArray* meanings))completion
{
    
}

@end
