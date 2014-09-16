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
#import "RLAError.h"                // Relayr.framework (Utilities)

@implementation RLAWebService (User)

#pragma mark - Public API

// TODO: Check how headers should be parse within the GET (relativePath). As in this example
+ (void)isUserWithEmail:(NSString*)email registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    if (!completion) { return; }
    if (!email) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:Web_Host]];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_EmailCheck(email);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_EmailCheck, nil);
        
        NSString* exists = json[Web_RequestResponseKey_EmailCheck_Exists];
        if (!exists) { return completion(RLAErrorWebrequestFailure, nil); }
        
        NSRange const result = [exists rangeOfString:Web_RequestResponseVal_EmailCheck_Exists];
        if (result.location == NSNotFound || result.length == 0) { return completion(nil, @NO); }
        return completion(nil, @YES);
    }];
}

- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil, nil, nil); }
    request.relativePath = Web_RequestRelativePath_UserInfo;
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_UserInfo, nil, nil, nil);
        
        NSString* futureID = json[Web_RespondKey_UserID];
        NSString* futureName = json[Web_RespondKey_UserName];
        NSString* futureEmail = json[Web_RespondKey_UserEmail];
        if (!futureID || !futureName || !futureEmail) { return completion(RLAErrorMissingExpectedValue, nil, nil, nil); }
        
        completion(nil, futureID, futureName, futureEmail);
    }];
}

- (void)setUserName:(NSString*)name email:(NSString*)email completion:(void (^)(NSError* error))completion
{
    NSMutableDictionary* body = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (name) { body[Web_RespondKey_UserID] = name; }
    if (email) { body[Web_RespondKey_UserName] = email; }
    if (!body.count) { if (completion) { completion(nil); } return; }
    
    RelayrUser* user = self.user;
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure); }
    
    request.relativePath = Web_RequestRelativePath_UserInfoSet(user.uid);
    request.body = [NSDictionary dictionaryWithDictionary:body];
    [request executeInHTTPMode:kRLAWebRequestModePATCH completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        if (responseCode.unsignedIntegerValue!=Web_RequestResponseCode_UserInfoSet || !data) { return completion(RLAErrorWebrequestFailure); }
        
        return completion(nil);
    }];
}

- (void)requestUserApps:(void (^)(NSError* error, NSArray* apps))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserInstalledApps(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserInstalledApps, nil);
        
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrApp* app = [RLAWebService parseAppFromJSONDictionary:dict];
            if (app) { [result addObject:app]; }
        }
        
        return completion(nil, (result.count) ? [NSArray arrayWithArray:result] : nil);
    }];
}

- (void)requestUserPublishers:(void (^)(NSError* error, NSArray* publishers))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserPubs(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserPubs, nil);
        
        NSMutableArray* publishers = [NSMutableArray arrayWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrPublisher* pub = [RLAWebService parsePublisherFromJSONDictionary:dict];
            if (pub) { [publishers addObject:pub]; }
        }
        
        completion(nil, (publishers.count) ? [NSArray arrayWithArray:publishers] : nil);
    }];
}

- (void)requestUserTransmitters:(void (^)(NSError* error, NSArray* transmitters))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserTrans(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserTrans, nil);
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        
        for (NSDictionary* dict in json)
        {
            RelayrTransmitter* transmitter = [RLAWebService parseTransmitterFromJSONDictionary:dict];
            if (transmitter) { [result addObject:transmitter]; }
        }
        
        return completion(nil, (result.count) ? [NSArray arrayWithArray:result] : nil);
    }];
}

- (void)requestUserDevices:(void (^)(NSError* error, NSArray* devices))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserDevices(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserDevices, nil);
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [RLAWebService parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        
        return completion(nil, (result.count) ? [NSArray arrayWithArray:result] : nil);
    }];
}

- (void)requestUserBookmarkedDevices:(void (^)(NSError* error, NSArray* bookDevices))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RLAErrorWebrequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_UserBookmarkDevices(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserBookmarkDevices, nil);
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [RLAWebService parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        
        return completion(nil, (result.count) ? [NSArray arrayWithArray:result] : nil);
    }];
}

@end
