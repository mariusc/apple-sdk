#import "RLAWebService+User.h"      // Header
#import "RLAWebService+Parsing.h"   // Relayr.framework (Web)

#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrFirmware.h"          // Relayr.framework (Public)
#import "RelayrInput.h"             // Relayr.framework (Public)
#import "RelayrOutput.h"            // Relayr.framework (Public)

#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RLAWebConstants.h"         // Relayr.framework (Web)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)

@implementation RLAWebService (User)

#pragma mark - Public API

// TODO: Check how headers should be parse within the GET (relativePath). As in this example
+ (void)isUserWithEmail:(NSString*)email registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    if (!completion) { return; }
    if (!email) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:Web_Host]];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_EmailCheck(email);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_EmailCheck, nil);
        
        NSString* exists = json[Web_RequestResponseKey_EmailCheck_Exists];
        if (!exists) { return completion(RelayrErrorRequestParsingFailure, nil); }
        
        NSRange const result = [exists rangeOfString:Web_RequestResponseVal_EmailCheck_Exists];
        return (result.location == NSNotFound || result.length == 0) ? completion(nil, @NO) : completion(nil, @YES);
    }];
}

- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil, nil, nil); }
    request.relativePath = Web_RequestRelativePath_UserInfo;
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_UserInfo, nil, nil, nil);
        
        NSString* futureID = json[Web_RespondKey_UserID];
        return (!futureID) ? completion(RelayrErrorRequestParsingFailure, nil, nil, nil) : completion(nil, futureID, json[Web_RespondKey_UserName], json[Web_RespondKey_UserEmail]);
    }];
}

- (void)setUserName:(NSString*)name email:(NSString*)email completion:(void (^)(NSError* error))completion
{
    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    if (name.length) { tmpDict[Web_RespondKey_UserID] = name; }
    if (email.length) { tmpDict[Web_RespondKey_UserName] = email; }
    if (!tmpDict.count) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure); }
    request.relativePath = Web_RequestRelativePath_UserInfoSet(self.user.uid);
    request.body = [NSDictionary dictionaryWithDictionary:tmpDict];
    
    [request executeInHTTPMode:kRLAWebRequestModePATCH completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return completion((responseCode.unsignedIntegerValue!=Web_RequestResponseCode_UserInfoSet) ? RelayrErrorWebRequestFailure : nil);
    }];
}

- (void)authoriseApp:(NSString*)appID forCurrentUser:(void (^)(NSError* error))completion
{
    if (!appID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_UserInstallApp(self.user.uid, appID);
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return completion((responseCode.unsignedIntegerValue != Web_RequestResponseCode_UserInstallApp) ? RelayrErrorWebRequestFailure : nil);
    }];
}

- (void)requestUserAuthorisedApps:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserInstalledApps(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserInstalledApps, nil);
        
        NSMutableSet* result = [NSMutableSet setWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrApp* app = [RLAWebService parseAppFromJSONDictionary:dict];
            if (app) { [result addObject:app]; }
        }
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)unauthoriseApp:(NSString*)appID forCurrentUser:(void (^)(NSError* error))completion
{
    if (!appID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_UserUninstallApp(self.user.uid, appID);
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return completion((responseCode.unsignedIntegerValue != Web_RequestResponseCode_UserUninstallApp) ? RelayrErrorWebRequestFailure : nil);
    }];
}

- (void)requestUserPublishers:(void (^)(NSError* error, NSSet* publishers))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserPubs(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserPubs, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrPublisher* pub = [RLAWebService parsePublisherFromJSONDictionary:dict];
            if (pub) { [result addObject:pub]; }
        }
        
        completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)requestUserTransmitters:(void (^)(NSError* error, NSSet* transmitters))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserTrans(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserTrans, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrTransmitter* transmitter = [RLAWebService parseTransmitterFromJSONDictionary:dict];
            if (transmitter) { [result addObject:transmitter]; }
        }
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)requestUserDevices:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserDevices(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserDevices, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [RLAWebService parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)requestUserDevicesFilteredByMeaning:(NSString*)meaning completion:(void (^)(NSError* error, NSSet* devices))completion
{
    if (!completion) { return; }
    if (!meaning.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserDevicesMeaning(self.user.uid, meaning);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserDevices, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [RLAWebService parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)registerUserBookmarkToDevice:(NSString*)deviceID completion:(void (^) (NSError* error))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure); }
    request.relativePath = Web_RequestRelativePath_UserBookmarkDev(self.user.uid, deviceID);
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        if (error) { return completion(error); }
        return completion((responseCode.unsignedIntegerValue!=Web_RequestResponseCode_UserBookmarkDev) ? RelayrErrorWebRequestFailure : nil);
    }];
}

- (void)requestUserBookmarkedDevices:(void (^)(NSError* error, NSSet* bookDevices))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserBookmarkDevices(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserBookmarkDevices, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [RLAWebService parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)deleteUserBookmarkToDevice:(NSString*)deviceID completion:(void (^) (NSError* error))completion
{
    if (!deviceID.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure); }
    request.relativePath = Web_RequestRelativePath_UserBookmarkDeletion(self.user.uid, deviceID);
    
    [request executeInHTTPMode:kRLAWebRequestModeDELETE completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return completion((responseCode.unsignedIntegerValue!=Web_RequestResponseCode_UserBookmarkDeletion) ? RelayrErrorWebRequestFailure : nil);
    }];
}

@end
