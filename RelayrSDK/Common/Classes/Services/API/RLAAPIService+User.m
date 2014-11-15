#import "RLAAPIService+User.h"      // Header
#import "RLAAPIService+Parsing.h"   // Relayr.framework (Service/API)

#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrFirmware.h"          // Relayr.framework (Public)
#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)

@implementation RLAAPIService (User)

#pragma mark - Public API

+ (void)isUserWithEmail:(NSString*)email registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    if (!completion) { return; }
    if (!email) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:dRLAAPI_Host relativeString:dRLAAPI_UserEmailCheck_RelativePath(email)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:nil];
    if (!request) { completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_UserEmailCheck_ResponseCode, nil);
        NSNumber* result = json[dRLAAPI_UserEmailCheck_ResponseKey];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserInfo_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil, nil, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_UserInfo_ResponseCode, nil, nil, nil);
        NSString* futureID = json[RLAAPI_User_RespondKey_ID];
        return (!futureID) ? completion(RelayrErrorRequestParsingFailure, nil, nil, nil) : completion(nil, futureID, json[RLAAPI_User_RespondKey_Name], json[RLAAPI_User_RespondKey_Email]);
    }];
    [task resume];
}

- (void)setUserName:(NSString*)name email:(NSString*)email completion:(void (^)(NSError* error))completion
{
    NSMutableDictionary* body = [[NSMutableDictionary alloc] init];
    if (name.length) { body[dRLAAPI_User_RequestKey_ID] = name; }
    if (email.length) { body[dRLAAPI_User_RequestKey_Name] = email; }
    if (!body.count) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserSetInfo_RelativePath(self.user.uid)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePATCH authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode!=dRLAAPI_UserSetInfo_ResponseCode) ? RelayrErrorWebRequestFailure : nil );
    }];
    [task resume];
}

- (void)authoriseApp:(NSString*)appID forCurrentUser:(void (^)(NSError* error))completion
{
    if (!appID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserAppAuth_RelativePath(self.user.uid, appID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_UserAppAuth_ResponseCode) ? RelayrErrorWebRequestFailure : nil);
    }];
    [task resume];
}

- (void)requestUserAuthorisedApps:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserAuthApps_RelativePath(self.user.uid)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_UserAuthApps_ResponseCode, nil);
        
        NSMutableSet* result = [NSMutableSet setWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrApp* app = [RLAAPIService parseAppFromJSONDictionary:dict]; if (app) { [result addObject:app]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)unauthoriseApp:(NSString*)appID forCurrentUser:(void (^)(NSError* error))completion
{
    if (!appID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserUnauthApp_RelativePath(self.user.uid, appID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_UserUnauthApp_ResponseCode) ? RelayrErrorWebRequestFailure : nil);
    }];
    [task resume];
}

- (void)requestUserPublishers:(void (^)(NSError* error, NSSet* publishers))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserPublishers_RelativePath(self.user.uid)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_UserPublishers_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrPublisher* pub = [RLAAPIService parsePublisherFromJSONDictionary:dict]; if (pub) { [result addObject:pub]; } }
        completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)requestUserTransmitters:(void (^)(NSError* error, NSSet* transmitters))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserTransmitters_RelativePath(self.user.uid)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_UserTransmitters_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrTransmitter* transmitter = [RLAAPIService parseTransmitterFromJSONDictionary:dict];
            if (transmitter) { [result addObject:transmitter]; }
        }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)requestUserDevices:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!completion) { return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserDevices_RelativePath(self.user.uid)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_UserDevices_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrDevice* device = [RLAAPIService parseDeviceFromJSONDictionary:dict]; if (device) { [result addObject:device]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)requestUserDevicesFilteredByMeaning:(NSString*)meaning completion:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!completion) { return; }
    if (!meaning.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserDevicesFilter_RelativePath(self.user.uid, meaning)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_UserDevicesFilter_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrDevice* device = [RLAAPIService parseDeviceFromJSONDictionary:dict]; if (device) { [result addObject:device]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)registerUserBookmarkToDevice:(NSString*)deviceID completion:(void (^) (NSError* error))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserBookDeviceNew_RelativePath(self.user.uid, deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode!=dRLAAPI_UserBookDeviceNew_ResponseCode) ? RelayrErrorWebRequestFailure : nil);
    }];
    [task resume];
}

- (void)requestUserBookmarkedDevices:(void (^)(NSError* error, NSSet* bookDevices))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserBookDevices_RelativePath(self.user.uid)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_UserBookDevices_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrDevice* device = [RLAAPIService parseDeviceFromJSONDictionary:dict]; if (device) { [result addObject:device]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)deleteUserBookmarkToDevice:(NSString*)deviceID completion:(void (^) (NSError* error))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_UserBookDeviceDelete_RelativePath(self.user.uid, deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeDELETE authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode!=dRLAAPI_UserBookDeviceDelete_ResponseCode) ? RelayrErrorWebRequestFailure : nil);
    }];
    [task resume];
}

@end
