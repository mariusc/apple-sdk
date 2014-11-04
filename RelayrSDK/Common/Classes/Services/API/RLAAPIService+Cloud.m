#import "RLAAPIService+Cloud.h"     // Header
#import "RLAAPIRequest.h"           // Relayr.framework (Service/API)
#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)
#import "RLAWebOAuthController.h"   // Relayr.framework (Service/API)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)

@implementation RLAAPIService (Cloud)

#pragma mark - Public API

+ (void)isRelayrCloudReachable:(void (^)(NSError*, NSNumber*))completion
{
    if (!completion) { return; }

    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:Web_Host];
    request.relativePath = Web_RequestRelativePath_Reachability;

    [request executeInHTTPMode:kRLAAPIRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
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

    RLAAPIRequest* tokenRequest = [[RLAAPIRequest alloc] initWithHost:Web_Host];
    tokenRequest.relativePath = Web_RequestRelativePath_OAuthToken;
    tokenRequest.body = Web_RequestBody_OAuthToken(code, redirectURI, clientID, clientSecret);

    [tokenRequest executeInHTTPMode:kRLAAPIRequestModePOST completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_OAuthToken, nil);

        NSString* token = json[Web_RequestResponseKey_OAuthToken_AccessToken];
        return (!token) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, token);
    }];
}

@end
