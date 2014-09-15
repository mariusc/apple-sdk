#import "RLAWebService+App.h"   // Header
#import "RelayrApp.h"           // Relayr.framework (Public)
#import "RelayrUser.h"          // Relayr.framework (Public)
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RLAWebRequest.h"       // Relayr.framework (Web)
#import "RLAWebConstants.h"     // Relayr.framework (Web)
#import "RLAError.h"            // Relayr.framework (Utilities)

@implementation RLAWebService (App)

#pragma mark - Public API

+ (void)requestAppInfoFor:(NSString*)appID completion:(void (^)(NSError*, NSString*, NSString*, NSString*))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RLAErrorMissingArgument, nil, nil, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:Web_Host]];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil, nil, nil); }
    request.relativePath = Web_RequestRelativePath_AppInfo(appID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppInfo, nil, nil, nil);
        
        completion(nil, json[Web_RespondKey_AppID], json[Web_RespondKey_AppName], json[Web_RespondKey_AppDescription]);
    }];
}

- (void)requestAllRelayrApps:(void (^)(NSError* error, NSArray* apps))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_Apps;
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_Apps, nil);
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        
        for (NSDictionary* dict in json)
        {
            RelayrApp* app = [self app_parseAppFromJSONDictionary:dict];
            if (app) { [result addObject:app]; }
        }
        
        return completion(nil, (!result.count) ? nil : [NSArray arrayWithArray:result]);
    }];
}

- (void)registerAppWithName:(NSString*)appName description:(NSString*)appDescription publisher:(NSString*)publisher redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, RelayrApp* app))completion
{
    if (!appName.length || !publisher.length) { if (completion) { completion(RLAErrorMissingArgument, nil); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RLAErrorWebrequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_AppRegistration;
    
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:@{ Web_RequestBodyKey_AppName : appName, Web_RequestBodyKey_AppPublisher : publisher }];
    if (appDescription.length) { body[Web_RequestBodyKey_AppDescription] = appDescription; }
    if (redirectURI.length) { body[Web_RequestBodyKey_AppRedirectURI] = redirectURI; }
    request.body = [NSDictionary dictionaryWithDictionary:body];
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_Apps, nil);
        
        RelayrApp* result = [self app_parseAppFromJSONDictionary:json];
        return (result) ? completion(nil, result) : completion(RLAErrorWebrequestFailure, nil);
    }];
}

- (void)requestApp:(NSString*)appID completion:(void (^)(NSError* error, RelayrApp* app))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_AppInfoExtended(appID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppInfo, nil);
#warning Apiary says that I receive an array here, although it doesn't make sense. Check it out with Postman
        RelayrApp* result = [self app_parseAppFromJSONDictionary:json];
        return (result) ? completion(nil, result) : completion(RLAErrorWebrequestFailure, nil);
    }];
}

- (void)setApp:(NSString*)appID name:(NSString*)appName description:(NSString*)appDescription redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error))completion
{
    if (!appID.length) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    request.relativePath = Web_RequestRelativePath_AppInfoSet(appID);
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc] init];
    if (appName.length) { body[Web_RequestBodyKey_AppName] = appName; }
    if (appDescription.length) { body[Web_RequestBodyKey_AppDescription] = appDescription; }
    if (redirectURI.length) { body[Web_RequestBodyKey_AppRedirectURI] = redirectURI; }
    request.body = [NSDictionary dictionaryWithDictionary:body];
    
    [request executeInHTTPMode:kRLAWebRequestModePATCH completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        if (responseCode.unsignedIntegerValue != Web_RequestResponseCode_AppInfoSet || !data) { return completion(RLAErrorWebrequestFailure); }
        
        return completion(nil);
    }];
}

- (void)removeApp:(NSString*)appID completion:(void (^)(NSError* error))completion
{
    if (!appID.length) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RLAErrorWebrequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_AppDeletion(appID);
    
    [request executeInHTTPMode:kRLAWebRequestModeDELETE completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        if (responseCode.unsignedIntegerValue != Web_RequestResponseCode_AppDeletion || !data) { return completion(RLAErrorWebrequestFailure); }
        
        return completion(nil);
    }];
}

#pragma mark - Private methods

- (RelayrApp*)app_parseAppFromJSONDictionary:(NSDictionary*)jsonDict
{
    RelayrApp* app = [[RelayrApp alloc] initWithID:jsonDict[Web_RespondKey_AppID]];
    if (!app) { return nil; }
    
    app.name = jsonDict[Web_RespondKey_AppName];
    app.publisherID = jsonDict[Web_RespondKey_AppOwner];
    app.oauthClientSecret = jsonDict[Web_RespondKey_AppOAuthClientSecret];
    app.appDescription = jsonDict[Web_RespondKey_AppDescription];
    return app;
}

@end
