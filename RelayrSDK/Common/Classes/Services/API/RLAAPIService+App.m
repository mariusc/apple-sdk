#import "RLAAPIService+App.h"       // Header

#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)
#import "RLAAPIService+Parsing.h"   // Relayr.framework (Service/API)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)

@implementation RLAAPIService (App)

#pragma mark - Public API

+ (void)requestAllRelayrApps:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:dRLAAPI_Host relativeString:dRLAAPI_Apps_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:nil];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_Apps_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrApp* app = [RLAAPIService parseAppFromJSONDictionary:dict]; if (app) { [result addObject:app]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)registerAppWithName:(NSString*)appName description:(NSString*)appDescription publisher:(NSString*)publisher redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, RelayrApp* app))completion
{
    if (!appName.length || !publisher.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:@{ dRLAAPI_App_RequestKey_Name : appName, dRLAAPI_App_RequestKey_Publisher : publisher }];
    if (appDescription.length) { body[dRLAAPI_App_RequestKey_Description] = appDescription; }
    if (redirectURI.length) { body[dRLAAPI_App_RequestKey_RedirectURI] = redirectURI; }
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError, nil); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_AppRegistration_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_AppRegistration_ResponseCode, nil);
        
        RelayrApp* result = [RLAAPIService parseAppFromJSONDictionary:json];
        if (completion) { return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result); }
    }];
    [task resume];
}

+ (void)requestAppInfoFor:(NSString*)appID completion:(void (^)(NSError* error, NSString* appID, NSString* appName, NSString* appDescription))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RelayrErrorMissingArgument, nil, nil, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:dRLAAPI_Host relativeString:dRLAAPI_AppInfo_RelativePath(appID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:nil];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil, nil, nil); }
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_AppInfo_ResponseCode, nil, nil, nil);
        completion(nil, json[dRLAAPI_App_RespondKey_ID], json[dRLAAPI_App_RespondKey_Name], json[dRLAAPI_App_RespondKey_Description]);
    }];
    [task resume];
}

- (void)requestAppInfoExtendedFor:(NSString*)appID completion:(void (^)(NSError* error, RelayrApp* app))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RelayrErrorMissingArgument, nil); }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_AppInfoExt_RelativePath(appID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_AppInfoExt_ResponseCode, nil);
        
        RelayrApp* result = [RLAAPIService parseAppFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)setApp:(NSString*)appID name:(NSString*)appName description:(NSString*)appDescription redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, RelayrApp* app))completion
{
    if (!appID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc] init];
    if (appName.length) { body[dRLAAPI_App_RequestKey_Name] = appName; }
    if (appDescription) { body[dRLAAPI_App_RequestKey_Description] = appDescription; }
    if (redirectURI.length) { body[dRLAAPI_App_RequestKey_RedirectURI] = redirectURI; }
    if (!body.count) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError, nil); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_AppInfoSet_RelativePath(appID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePATCH authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_AppInfoSet_ResponseCode, nil);
        
        RelayrApp* result = [RLAAPIService parseAppFromJSONDictionary:json];
        if (completion) { return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result); }
    }];
    [task resume];
}

- (void)setConnectionBetweenApp:(NSString*)appID andDevice:(NSString*)deviceID completion:(void (^)(NSError* error, id credentials))completion
{
    if (!deviceID.length || !appID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_AppConnection_RelativePath(appID, deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_AppConnection_ResponseCode, nil);
        if (completion) { completion(nil, json); }
    }];
    [task resume];
}

- (void)deleteConnectionBetweenApp:(NSString*)appID andDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    if (!appID.length || !deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_AppDisconn_RelativePath(appID, deviceID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeDELETE authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_AppDisconn_ResponseCode) ? RelayrErrorWebRequestFailure : nil );
    }];
    [task resume];
}

- (void)deleteApp:(NSString*)appID completion:(void (^)(NSError* error))completion
{
    if (!appID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_AppDeletion_RelativePath(appID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeDELETE authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode != dRLAAPI_AppDeletion_ResponseCode) ? RelayrErrorWebRequestFailure : nil);
    }];
    [task resume];}

@end
