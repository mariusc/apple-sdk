#import "RLAWebService.h"       // Header
#import "RelayrUser.h"          // Relayr.framework (Public)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLAWebViewForOAuth.h"  // Relayr.framework (Web)
#import "RLAWebRequest.h"       // Relayr.framework (Web)
#import "RLAError.h"            // Relayr.framework (Utilities)

// OAuth temporal code
static NSString* kRLAWebServiceRelayrHost        = @"https://api.relayr.io/";
static NSString* kRLAWebServiceOAuthCodeRequest1 = @"oauth2/auth?client_id=";
static NSString* kRLAWebServiceOAuthCodeRequest2 = @"&redirect_uri=";
static NSString* kRLAWebServiceOAuthCodeRequest3 = @"&response_type=code&scope=access-own-user-info";

// OAuth token
static NSString* kRLAWebRequest_OAuthToken_relativePath         = @"oauth2/token";
static NSString* kRLAWebRequest_OAuthToken_header_clientID      = @"client_id";
static NSString* kRLAWebRequest_OAuthToken_header_clientSecret  = @"client_secret";
static NSString* kRLAWebRequest_OAuthToken_header_grantType     = @"grant_type";
static NSString* kRLAWebRequest_OAuthToken_header_grantType_val = @"authorization_code";
static NSString* kRLAWebRequest_OAuthToken_header_code          = @"code";
static NSString* kRLAWebRequest_OAuthToken_header_redirectURI   = @"redirect_uri";
static NSUInteger const kRLAWebRequest_OAuthRequest_respond_code= 200;
static NSString* kRLAWebRequest_OAuthToken_respond_tokenKey     = @"access_token";

// User info
static NSString* kRLAWebRequest_userInfo_relativePath           = @"oauth2/user-info";
static NSUInteger const kRLAWebRequest_userInfo_respond_code    = 200;
static NSString* kRequest_userInfo_respondKey_name              = @"name";
static NSString* kRequest_userInfo_respondKey_email             = @"email";

@interface RLAWebService ()
@property (weak,readonly,nonatomic) RelayrUser* user;
@end

@implementation RLAWebService

#pragma mark - Public API

// TODO: Fill up
+ (void)requestOAuthCodeWithOAuthClientID:(NSString*)clientID redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* token))completion
{
    if (!completion) { return; }
    if (!clientID || !redirectURI) { return completion(RLAErrorMissingArgument, nil); }
    
    NSURL* hostURL = [NSURL URLWithString:kRLAWebServiceRelayrHost];
    NSMutableString* relativePath = [[NSMutableString alloc] initWithString:kRLAWebServiceOAuthCodeRequest1];
    [relativePath appendString:clientID];
    [relativePath appendString:kRLAWebServiceOAuthCodeRequest2];
    [relativePath appendString:redirectURI];
    [relativePath appendString:kRLAWebServiceOAuthCodeRequest3];
    NSURL* absoluteURL = [NSURL URLWithString:relativePath relativeToURL:hostURL];
    
//    id <RLAWebViewForOAuth> oauthController = ...;
//    oauthController.completion = ^(NSError* error, NSString* result){
//        
//    };
//    
//    BOOL const wasPresented = [oauthController presentModally];
//    if (!wasPresented)
//    {
//        oauthController.completion = nil;
//        return completion(RLAErrorSigningFailure, nil);
//    }
}


// TODO: Fill up
+ (void)requestOAuthTokenWithOAuthCode:(NSString*)code OAuthClientID:(NSString*)clientID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* token))completion
{
    if (!completion) { return; }
    if (!clientID || !clientSecret || !redirectURI) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* tokenRequest = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:kRLAWebServiceRelayrHost]];
    tokenRequest.relativePath = kRLAWebRequest_OAuthToken_relativePath;
    
    tokenRequest.httpHeaders = @{
        kRLAWebRequest_OAuthToken_header_clientID : clientID,
        kRLAWebRequest_OAuthToken_header_clientSecret : clientSecret,
        kRLAWebRequest_OAuthToken_header_grantType : kRLAWebRequest_OAuthToken_header_grantType_val,
        kRLAWebRequest_OAuthToken_header_code : code,
        kRLAWebRequest_OAuthToken_header_redirectURI : redirectURI
    };
    
    [tokenRequest executeInHTTPMode:kRLAWebRequestModePOST withExpectedStatusCode:kRLAWebRequest_OAuthRequest_respond_code completion:^(NSError *error, NSData *data) {
        if (error) { return completion(error, nil); }
        
        NSDictionary* jsonDict = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { return completion(error, nil); }
        
        NSString* token = jsonDict[kRLAWebRequest_OAuthToken_respond_tokenKey];
        if (!token) { return completion(RLAErrorSigningFailure, nil); }
        
        completion(nil, token);
    }];
}

- (instancetype)initWithUser:(__weak RelayrUser *)user
{
    if (!user) { return nil; }
    
    self = [super init];
    if (self)
    {
        _user = user;
        _hostURL = [NSURL URLWithString:kRLAWebServiceRelayrHost];
    }
    return self;
}

- (void)setHostURL:(NSURL*)hostURL
{
    _hostURL = (hostURL) ? hostURL : [NSURL URLWithString:kRLAWebServiceRelayrHost];
}

- (void)requestUserInfo:(void (^)(NSError* error, NSString* name, NSString* email))completion
{
    __weak RelayrUser* weakUser = _user;
    
    RLAWebRequest* infoRequest = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:weakUser.token];
    infoRequest.relativePath = kRLAWebRequest_userInfo_relativePath;
    
    [infoRequest executeInHTTPMode:kRLAWebRequestModeGET withExpectedStatusCode:kRLAWebRequest_userInfo_respond_code completion:^(NSError* error, NSData* data) {
        if (error) { if (completion) { completion(error, nil, nil); } return; }
        
        NSDictionary* jsonDict = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (error) { if (completion) { completion(error, nil, nil); } return; }
        
        NSString* futureName = jsonDict[kRequest_userInfo_respondKey_name];
        NSString* futureEmail = jsonDict[kRequest_userInfo_respondKey_email];
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
