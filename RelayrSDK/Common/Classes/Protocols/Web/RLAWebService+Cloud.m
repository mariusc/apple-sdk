#import "RLAWebService+Cloud.h"     // Header
#import "RLAWebRequest.h"           // Relayr.framework (Protocols/Web)
#import "RLAWebConstants.h"         // Relayr.framework (Protocols/Web)
#import "RLAWebOAuthController.h"   // Relayr.framework (Protocols/Web)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)

@implementation RLAWebService (Cloud)

#pragma mark - Public API

+ (void)isRelayrCloudReachable:(void (^)(NSError*, NSNumber*))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:Web_Host];
    request.relativePath = Web_RequestRelativePath_Reachability;
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_Reachability, @NO);
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
    if (!clientID || !clientSecret || !redirectURI) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* tokenRequest = [[RLAWebRequest alloc] initWithHost:Web_Host];
    tokenRequest.relativePath = Web_RequestRelativePath_OAuthToken;
    tokenRequest.body = Web_RequestBody_OAuthToken(code, redirectURI, clientID, clientSecret);
    
    [tokenRequest executeInHTTPMode:kRLAWebRequestModePOST completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_OAuthToken, nil);
        
        NSString* token = json[Web_RequestResponseKey_OAuthToken_AccessToken];
        return (!token) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, token);
    }];
}

@end
