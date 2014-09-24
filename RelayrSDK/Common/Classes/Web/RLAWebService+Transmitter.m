#import "RLAWebService+Transmitter.h"   // Header
#import "RLAWebService+Parsing.h"       // Relayr.framework (Web)

#import "RelayrUser.h"                  // Relayr.framework (Public)
#import "RelayrTransmitter.h"           // Relayr.framework (Public)
#import "RelayrDevice.h"                // Relayr.framework (Public)
#import "RelayrFirmware.h"              // Relayr.framework (Public)
#import "RLAWebRequest.h"               // Relayr.framework (Web)
#import "RLAWebConstants.h"             // Relayr.framework (Web)
#import "RelayrErrors.h"                    // Relayr.framework (Utilities)

@implementation RLAWebService (Transmitter)

#pragma mark - Public API

- (void)registerTransmitterWithName:(NSString*)transmitterName ownerID:(NSString*)ownerID model:(NSString*)modelID firmwareVersion:(NSString*)firmwareVersion completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    if (!transmitterName.length || !ownerID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_TransRegistration;
    request.body = @{ Web_RequestBodyKey_TransOwner : ownerID, Web_RequestBodyKey_TransName : transmitterName };
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_TransRegistration, nil);
        
        RelayrTransmitter* result = [RLAWebService parseTransmitterFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)requestTransmitter:(NSString*)transmitterID completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    if (!completion) { return; }
    if (!transmitterID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_TransInfo(transmitterID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_TransInfo, nil);
        
        RelayrTransmitter* result = [RLAWebService parseTransmitterFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)setTransmitter:(NSString*)transmitterID withName:(NSString*)futureTransmitterName completion:(void (^)(NSError*))completion
{
    if (!transmitterID.length || !futureTransmitterName.length) { if (completion) { return completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_TransInfoSet(transmitterID);
    request.body = @{ Web_RequestBodyKey_TransName : futureTransmitterName };
    
    [request executeInHTTPMode:kRLAWebRequestModePATCH completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_TransInfoSet) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

- (void)deleteTransmitter:(NSString*)transmitterID completion:(void (^)(NSError* error))completion
{
    if (!transmitterID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_TransDeletion(transmitterID);
    
    [request executeInHTTPMode:kRLAWebRequestModeDELETE completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_TransDeletion) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

- (void)setConnectionBetweenTransmitter:(NSString*)transmitterID andDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    if (!transmitterID.length || !deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_TransConnectionDev(transmitterID, deviceID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_TransConnectionDev) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

- (void)requestDevicesFromTransmitter:(NSString*)transmitterID completion:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!completion) { return; }
    if (!transmitterID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_TransDevices(transmitterID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_TransDevices, nil);
        
        NSMutableSet* result = [NSMutableSet setWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [RLAWebService parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)deleteConnectionBetweenTransmitter:(NSString*)transmitterID andDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    if (!transmitterID.length || !deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_TransConnectionDevDeletion(transmitterID, deviceID);
    
    [request executeInHTTPMode:kRLAWebRequestModeDELETE completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_TransConnectionDevDeletion) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

@end
