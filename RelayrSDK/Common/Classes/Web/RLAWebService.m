#import "RLAWebService.h"           // Header
#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RelayrApp_Setup.h"         // Relayr.framework (Private)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrPublisher_Setup.h"   // Relayr.framework (Private)

#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RLAWebConstants.h"         // Relayr.framework (Web)
#import "RLAWebOAuthController.h"   // Relayr.framework (Web)

#import "RLAError.h"                // Relayr.framework (Utilities)

@implementation RLAWebService

#pragma mark - Public API

+ (void)isRelayrCloudReachable:(void (^)(NSError*, NSNumber*))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:dRLAWebService_Host]];
    request.relativePath = dRLAWebService_Reachability_RelativePath;
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error, nil); }
        
        NSArray* jsonArray = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { return completion(error, nil); }
        
        if (jsonArray.count == 0) { return completion(RLAErrorWebrequestFailure, nil); }
        completion(nil, @YES);
    }];
}

+ (void)requestAppInfoFor:(NSString*)appID completion:(void (^)(NSError*, NSString*, NSString*, NSString*))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RLAErrorMissingArgument, nil, nil, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:dRLAWebService_Host]];
    request.relativePath = dRLAWebService_AppInfo_RelativePath(appID);
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        if (error) { return completion(error, nil, nil, nil); }
        
        NSDictionary* jsonDict = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { return completion(error, nil, nil, nil); }
        
        if (jsonDict.count == 0) { return completion(RLAErrorWebrequestFailure, nil, nil, nil); }
        completion(nil, jsonDict[dRLAWebService_AppInfo_RespondKey_ID], jsonDict[dRLAWebService_AppInfo_RespondKey_Name], jsonDict[dRLAWebService_AppInfo_RespondKey_Description]);
    }];
}

+ (void)isUserWithEmail:(NSString*)email registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    // FIXME: It does never connect!
    if (!completion) { return; }
    if (!email) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:dRLAWebService_Host]];
    request.relativePath = @"/users/validate?email=roberto@relayr.de";
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error, nil); }
        
        NSDictionary* jsonDict = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { return completion(error, nil); }
        
        NSString* message = jsonDict[dRLAWebService_UserQuery_RespondKey_Message];
        if (!message) { return completion(RLAErrorWebrequestFailure, nil); }
        
        NSRange const result = [message rangeOfString:dRLAWebService_UserQuery_RespondVal_ValidSubstr];
        if (result.location == NSNotFound || result.length == 0) { return completion(nil, @NO); }
        completion(nil, @YES);
    }];
}

+ (void)requestOAuthCodeWithOAuthClientID:(NSString*)clientID redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* tmpCode))completion
{
    [[RLAWebOAuthController webOAuthControllerWithClientID:clientID redirectURI:redirectURI completion:completion] presentModally];
}

+ (void)requestOAuthTokenWithOAuthCode:(NSString*)code OAuthClientID:(NSString*)clientID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* token))completion
{
    if (!completion) { return; }
    if (!clientID || !clientSecret || !redirectURI) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* tokenRequest = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:dRLAWebService_Host]];
    tokenRequest.relativePath = dRLAWebService_OAuthToken_RelativePath;
    tokenRequest.body = dRLAWebService_OAuthToken_Body(code, redirectURI, clientID, clientSecret);
    
    [tokenRequest executeInHTTPMode:kRLAWebRequestModePOST completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        if (error) { return completion(error, nil); }
        
        NSDictionary* jsonDict = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { return completion(error, nil); }
        
        NSString* token = jsonDict[dRLAWebService_OAuthToken_RespondKey_Token];
        if (!token) { return completion(RLAErrorSigningFailure, nil); }
        
        completion(nil, token);
    }];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUser:(__weak RelayrUser *)user
{
    if (!user) { return nil; }
    
    self = [super init];
    if (self)
    {
        _user = user;
        _hostURL = [NSURL URLWithString:dRLAWebService_Host];
    }
    return self;
}

- (void)setHostURL:(NSURL*)hostURL
{
    _hostURL = (hostURL) ? hostURL : [NSURL URLWithString:dRLAWebService_Host];
}

- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion
{
    if (!completion) { return; }
    RLAWebRequest* userInfoRequest = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
    userInfoRequest.relativePath = dRLAWebService_UserInfo_RelativePath;
    
    [userInfoRequest executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error, nil, nil, nil); }
        
        NSDictionary* jsonDict = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { return completion(error, nil, nil, nil); }
        
        NSString* futureID = jsonDict[dRLAWebService_UserInfo_RespondKey_ID];
        NSString* futureName = jsonDict[dRLAWebService_UserInfo_RespondKey_Name];
        NSString* futureEmail = jsonDict[dRLAWebService_UserInfo_RespondKey_Email];
        if (!futureName || !futureEmail) { return completion(RLAErrorMissingExpectedValue, nil, nil, nil); }
        
        completion(nil, futureID, futureName, futureEmail);
    }];
}

- (void)requestUserTransmitters:(void (^)(NSError* error, NSArray* transmitters))completion
{
    // TODO: Fill up
}

- (void)requestUserDevices:(void (^)(NSError* error, NSArray* devices))completion
{
    // TODO: Fill up
}

- (void)requestUserBookmarkedDevices:(void (^)(NSError* error, NSArray* bookDevices))completion
{
    // TODO: Fill up
}

- (void)requestUserPublishers:(void (^)(NSError* error, NSArray* publishers))completion
{
    if (!completion) { return; }
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
    request.relativePath = dRLAWebService_Publishers_RelativePath(_user.uid);
    
    __weak RelayrUser* weakUser = _user;
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error, nil); }
        
        NSArray* jsonArray = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { return completion(error, nil); }
        
        __strong RelayrUser* strongUser = weakUser;
        if (!strongUser) { return completion(RLAErrorMissingExpectedValue, nil); }
        
        NSMutableArray* publishers = [NSMutableArray arrayWithCapacity:jsonArray.count];
        for (NSDictionary* tmp in jsonArray)
        {
            NSString* tmpOwnerID = tmp[dRLAWebService_Publishers_RespondKey_Owner];
            if ( ![tmpOwnerID isEqualToString:strongUser.uid] ) { break; }
            
            RelayrPublisher* pub = [[RelayrPublisher alloc] initWithPublisherID:tmp[dRLAWebService_Publishers_RespondKey_ID] owner:strongUser];
            pub.name = tmp[dRLAWebService_Publishers_RespondKey_Name];
            if (pub) { [publishers addObject:pub]; }
        }
        
        completion(nil, [NSArray arrayWithArray:publishers]);
    }];
}

- (void)requestUserApps:(void (^)(NSError* error, NSArray* apps))completion
{
    // TODO:
//    if (!completion) { return; }
//    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
//    request.relativePath = dRLAWebService_Apps_RelativePath(_user.uid);
//    
//    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
//        if (error) { return completion(error, nil); }
//        
//        NSArray* jsonArray = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
//        if (error) { return completion(error, nil); }
//        
//        NSMutableArray* apps = [NSMutableArray arrayWithCapacity:jsonArray.count];
//        for (NSDictionary* tmp in jsonArray)
//        {
//            RelayrApp* app = [[RelayrApp alloc] initWithID:tmp[dRLAWebService_Apps_RespondKey_ID] publisherID:tmp[dRLAWebService_Apps_RespondKey_Owner]];
//            if (app) { [apps addObject:app]; }
//        }
//    }];
}

@end
