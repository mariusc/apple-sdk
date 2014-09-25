#import "RLAWebService+App.h"       // Header
#import "RLAWebService+Parsing.h"   // Relayr.framework (Web)

#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RLAWebConstants.h"         // Relayr.framework (Web)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)

@implementation RLAWebService (App)

#pragma mark - Public API

+ (void)requestAppInfoFor:(NSString*)appID completion:(void (^)(NSError* error, NSString* appID, NSString* appName, NSString* appDescription, NSString* appPublisher))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RelayrErrorMissingArgument, nil, nil, nil, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:Web_Host];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil, nil, nil, nil); }
    request.relativePath = Web_RequestRelativePath_AppInfo(appID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppInfo, nil, nil, nil, nil);
        
        completion(nil, json[Web_RespondKey_AppID], json[Web_RespondKey_AppName], json[Web_RespondKey_AppDescription], json[Web_RespondKey_AppPublisher]);
    }];
}

- (void)requestAllRelayrApps:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_Apps;
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_Apps, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrApp* app = [RLAWebService parseAppFromJSONDictionary:dict];
            if (app) { [result addObject:app]; }
        }
        
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)registerAppWithName:(NSString*)appName description:(NSString*)appDescription publisher:(NSString*)publisher redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, RelayrApp* app))completion
{
    if (!appName.length || !publisher.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_AppRegistration;
    
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:@{ Web_RequestBodyKey_AppName : appName, Web_RequestBodyKey_AppPublisher : publisher }];
    if (appDescription.length) { body[Web_RequestBodyKey_AppDescription] = appDescription; }
    if (redirectURI.length) { body[Web_RequestBodyKey_AppRedirectURI] = redirectURI; }
    request.body = [NSDictionary dictionaryWithDictionary:body];
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppRegistration, nil);
        
        RelayrApp* result = [RLAWebService parseAppFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)requestApp:(NSString*)appID completion:(void (^)(NSError* error, RelayrApp* app))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_AppInfoExtended(appID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppInfo, nil);
        
        RelayrApp* result = [RLAWebService parseAppFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)setApp:(NSString*)appID name:(NSString*)appName description:(NSString*)appDescription redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, RelayrApp* app))completion
{
    if (!appID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    if (appName.length) { tmpDict[Web_RequestBodyKey_AppName] = appName; }
    if (appDescription.length) { tmpDict[Web_RequestBodyKey_AppDescription] = appDescription; }
    if (redirectURI.length) { tmpDict[Web_RequestBodyKey_AppRedirectURI] = redirectURI; }
    if (!tmpDict.count) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    request.relativePath = Web_RequestRelativePath_AppInfoSet(appID);
    request.body = [NSDictionary dictionaryWithDictionary:tmpDict];
    
    [request executeInHTTPMode:kRLAWebRequestModePATCH completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppInfoSet, nil);
        
        RelayrApp* result = [RLAWebService parseAppFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)setConnectionBetweenApp:(NSString*)appID andDevice:(NSString*)deviceID completion:(void (^)(NSError* error, id credentials))completion
{
    if (!completion) { return; }
    if (!deviceID.length || !appID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_AppConnection(appID, deviceID);
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppConnection, nil);
        return completion(nil, json);
    }];
}

- (void)deleteConnectionBetweenApp:(NSString*)appID andDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    if (!appID.length || !deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_AppDisconnect(appID, deviceID);
    
    [request executeInHTTPMode:kRLAWebRequestModeDELETE completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_AppDisconnect) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

- (void)deleteApp:(NSString*)appID completion:(void (^)(NSError* error))completion
{
    if (!appID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_AppDeletion(appID);
    
    [request executeInHTTPMode:kRLAWebRequestModeDELETE completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return completion( (responseCode.unsignedIntegerValue != Web_RequestResponseCode_AppDeletion) ? RelayrErrorWebRequestFailure : nil);
    }];
}

@end
