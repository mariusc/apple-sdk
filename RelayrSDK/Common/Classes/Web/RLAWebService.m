#import "RLAWebService.h"           // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RLAWebConstants.h"         // Relayr.framework (Web)
#import "RLAWebOAuthController.h"   // Relayr.framework (Web)
#import "RLAError.h"                // Relayr.framework (Utilities)

@implementation RLAWebService

#pragma mark - Public API

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

+ (void)isUserWithEmail:(NSString*)email registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    if (!completion) { return; }
    if (!email) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:dRLAWebService_Host]];
    request.relativePath = dRLAWebService_UserQuery_RelativePath(email);
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error, nil); }
        
        // TODO: Talk to Dmitry about the body implementation
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
    RLAWebRequest* userInfoRequest = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
    userInfoRequest.relativePath = dRLAWebService_UserInfo_RelativePath;
    
    [userInfoRequest executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (!completion) { return; }
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

// TODO: Fill up
- (void)requestUserPublishers:(void (^)(NSError* error, NSArray* publishers))completion
{
    
}

// TODO: Fill up
- (void)requestUserDevices:(void (^)(NSError* error, NSArray* devices))completion
{
    
}

// TODO: Fill up
- (void)requestUserTransmitters:(void (^)(NSError* error, NSArray* transmitter))completion
{
    
}

// TODO: Fill up
- (void)resquestUserBookmarkedDevices:(void (^)(NSError* error, NSArray* bookDevices))completion
{
    
}

@end
