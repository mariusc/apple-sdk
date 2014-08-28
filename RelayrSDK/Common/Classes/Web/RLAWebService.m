#import "RLAWebService.h"       // Header
#import "RelayrUser.h"          // Relayr.framework (Public)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLAWebRequest.h"       // Relayr.framework (Web)
#import "RLAWebConstants.h"     // Relayr.framework (Web)
#import "RLAWebOAuthController.h"     // Relayr.framework (Web)
#import "RLAError.h"            // Relayr.framework (Utilities)

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
    
    RLAWebRequest* tokenRequest = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:dRLARequestHost]];
    tokenRequest.relativePath = dRLARequestOAuthToken_RelativePath;
    
    NSData* header64Data = [[[NSString stringWithFormat:@"%@:%@", clientID, clientSecret] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:kNilOptions];
    NSString* header64String = [[NSString alloc] initWithData:header64Data encoding:NSUTF8StringEncoding];
    tokenRequest.httpHeaders = @{
        @"Authorization" : [NSString stringWithFormat:@"Basic %@", header64String]
    };
    
    tokenRequest.body = [NSString stringWithFormat:@"code=%@", [code stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [tokenRequest executeInHTTPMode:kRLAWebRequestModePOST withExpectedStatusCode:dRLARequestOAuthToken_RespondKey_Code completion:^(NSError *error, NSData *data) {
        if (error) { return completion(error, nil); }
        
        NSDictionary* jsonDict = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { return completion(error, nil); }
        
        NSString* token = jsonDict[dRLARequestOAuthToken_RespondKey_Token];
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
        _hostURL = [NSURL URLWithString:dRLARequestHost];
    }
    return self;
}

- (void)setHostURL:(NSURL*)hostURL
{
    _hostURL = (hostURL) ? hostURL : [NSURL URLWithString:dRLARequestHost];
}

- (void)requestUserInfo:(void (^)(NSError* error, NSString* name, NSString* email))completion
{
    RLAWebRequest* infoRequest = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
    infoRequest.relativePath = dRLARequestUserInfo_RelativePath;
    
    [infoRequest executeInHTTPMode:kRLAWebRequestModeGET withExpectedStatusCode:dRLARequestUserInfo_RespondKey_Code completion:^(NSError* error, NSData* data) {
        if (error) { if (completion) { completion(error, nil, nil); } return; }
        
        NSDictionary* jsonDict = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { if (completion) { completion(error, nil, nil); } return; }
        
        NSString* futureName = jsonDict[dRLARequestUserInfo_RespondKey_Name];
        NSString* futureEmail = jsonDict[dRLARequestUserInfo_RespondKey_Email];
        if (!futureName || !futureEmail) { if (completion) { completion(RLAErrorMissingExpectedValue, nil, nil); }  return; }
        
        if (completion) { completion(nil, futureName, futureEmail); }
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
