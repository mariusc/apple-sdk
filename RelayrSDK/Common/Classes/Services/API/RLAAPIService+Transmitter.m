#import "RLAAPIService+Transmitter.h"   // Header

#import "RelayrUser.h"                  // Relayr.framework (Public)
#import "RelayrTransmitter.h"           // Relayr.framework (Public)
#import "RelayrDevice.h"                // Relayr.framework (Public)
#import "RelayrFirmware.h"              // Relayr.framework (Public)
#import "RLAAPIConstants.h"             // Relayr.framework (Service/API)
#import "RLAAPIService+Parsing.h"       // Relayr.framework (Service/API)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)

@implementation RLAAPIService (Transmitter)

#pragma mark - Public API

- (void)registerTransmitterWithName:(NSString*)transmitterName ownerID:(NSString*)ownerID model:(NSString*)modelID firmwareVersion:(NSString*)firmwareVersion completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    if (!transmitterName.length || !ownerID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_TransmitterRegistration_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    
    NSDictionary* body = @{ dRLAAPI_Transmitter_RequestKey_Owner : ownerID, dRLAAPI_Transmitter_RequestKey_Name : transmitterName };
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError, nil); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_TransmitterRegistration_ResponseCode, nil);
        
        RelayrTransmitter* result = [self parseTransmitterFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)requestTransmitter:(NSString*)transmitterID completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    if (!completion) { return; }
    if (!transmitterID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_TransmitterInfo_RelativePath(transmitterID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_TransmitterInfo_ResponseCode, nil);
        
        RelayrTransmitter* result = [self parseTransmitterFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)setTransmitter:(NSString*)transmitterID withName:(NSString*)futureTransmitterName completion:(void (^)(NSError*))completion
{
    if (!transmitterID.length || !futureTransmitterName.length) { if (completion) { return completion(RelayrErrorMissingArgument); } return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_TransmitterInfoSet_RelativePath(transmitterID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePATCH authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    
    NSDictionary* body = @{ dRLAAPI_Transmitter_RequestKey_Name : futureTransmitterName };
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_TransmitterInfoSet_ResponseCode) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
    [task resume];
}

- (void)deleteTransmitter:(NSString*)transmitterID completion:(void (^)(NSError* error))completion
{
    if (!transmitterID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_TransmitterDelete_RelativePath(transmitterID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeDELETE authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_TransmitterDelete_ResponseCode) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
    [task resume];
}

- (void)setConnectionBetweenTransmitter:(NSString*)transmitterID andDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    if (!transmitterID.length || !deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_TransmitterConnectDevice_RelativePath(transmitterID, deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_TransmitterConnectDevice_ResponseCode) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
    [task resume];
}

- (void)requestDevicesFromTransmitter:(NSString*)transmitterID completion:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!completion) { return; }
    if (!transmitterID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_TransmitterDevices_RelativePath(transmitterID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_TransmitterDevices_ResponseCode, nil);
        
        NSMutableSet* result = [NSMutableSet setWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [self parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)deleteConnectionBetweenTransmitter:(NSString*)transmitterID andDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    if (!transmitterID.length || !deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_TransmitterDisconnectDevice_RelativePath(transmitterID, deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeDELETE authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return ( ((NSHTTPURLResponse*)response).statusCode != dRLAAPI_TransmitterDisconnectDevice_ResponseCode ) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
    [task resume];
}

@end
