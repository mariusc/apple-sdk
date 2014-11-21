#import "RLAAPIService+Cloud.h"     // Header

#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)
#import "RLAWebOAuthController.h"   // Relayr.framework (Service/API)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)

@implementation RLAAPIService (Cloud)

#pragma mark - Public API

+ (void)isRelayrCloudReachable:(void (^)(NSError*, NSNumber*))completion
{
    if (!completion) { return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:dRLAAPI_Host relativeString:dRLAAPI_CloudReachability_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:nil];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.networkServiceType = NSURLNetworkServiceTypeDefault;
    request.allowsCellularAccess = YES;
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = (!error && ((NSHTTPURLResponse*)response).statusCode==dRLAAPI_CloudReachability_ResponseCode && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!json) { completion((error) ? error : RelayrErrorWebRequestFailure, @NO); }
            else { completion(nil, @YES); }
        });
    }];
    [task resume];
}

+ (void)requestOAuthCodeWithOAuthClientID:(NSString*)clientID redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* tmpCode))completion
{
    [[RLAWebOAuthController webOAuthControllerWithClientID:clientID redirectURI:redirectURI completion:completion] presentModally];
}

+ (void)requestOAuthTokenWithOAuthCode:(NSString*)code OAuthClientID:(NSString*)clientID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* token))completion
{
    if (!completion) { return; }
    if (!clientID.length || !clientSecret.length || !redirectURI.length) { return completion(RelayrErrorMissingArgument, nil); }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:dRLAAPI_Host relativeString:dRLAAPI_CloudOAuthToken_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:nil];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.networkServiceType = NSURLNetworkServiceTypeDefault;
    request.allowsCellularAccess = YES;
    
    NSString* httpBodyString = dRLAAPI_CloudOAuthToken_HTTPBody(code, redirectURI, clientID, clientSecret);
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_UTF8 forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = [httpBodyString dataUsingEncoding:NSUTF8StringEncoding];

    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = (!error && ((NSHTTPURLResponse*)response).statusCode==dRLAAPI_CloudOAuthToken_ResponseCode && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (json)
            {
                NSString* token = json[dRLAAPI_CloudOAuthToken_RespondKey_AccessToken];
                if (token) { completion(nil, token); }
                else { completion(RelayrErrorRequestParsingFailure, nil); }
            }
            else { completion((error) ? error : RelayrErrorWebRequestFailure, nil); }
        });
    }];
    [task resume];
}

@end
