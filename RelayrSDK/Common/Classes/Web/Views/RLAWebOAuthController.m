#import "RLAWebOAuthController.h"       // Header
#import "RLAWebConstants.h"             // Relayr.framework (Web)
#import "RLAError.h"                    // Relayr.framework (Utilities)
#import "CPlatforms.h"                  // Relayr.framework (Utilities)

#if defined(OS_APPLE_IOS) || defined (OS_APPLE_IOS_SIMULATOR)
#import "RLAWebOAuthControllerIOS.h"    // Relayr.framework (Web)
#elif defined(OS_APPLE_OSX)
#import "RLAWebOAuthControllerOSX.h"    // Relayr.framework (Web)
#endif

@implementation RLAWebOAuthController

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (id<RLAWebOAuthController>)webOAuthControllerWithClientID:(NSString*)clientID redirectURI:(NSString*)redirectURI completion:(void (^)(NSError*, NSString*))completion
{
    if (!completion) { return nil; }
    if (!clientID || !redirectURI) { completion(RLAErrorMissingArgument, nil); return nil; }
    
    NSURL* hostURL = [NSURL URLWithString:dRLARequestHost];
    NSMutableString* relativePath = [[NSMutableString alloc] initWithString:dRLARequestOAuthCode1];
    [relativePath appendString:clientID];
    [relativePath appendString:dRLARequestOAuthCode2];
    [relativePath appendString:redirectURI];
    [relativePath appendString:dRLARequestOAuthCode3];
    NSURL* absoluteURL = [NSURL URLWithString:relativePath relativeToURL:hostURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:absoluteURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:dRLAWebOAuthControllerTimeout];
    
    #if defined(OS_APPLE_IOS) || defined (OS_APPLE_IOS_SIMULATOR)
    return [[RLAWebOAuthControllerIOS alloc] initWithURLRequest:request redirectURI:redirectURI completion:completion];
    #elif defined(OS_APPLE_OSX)
    return [[RLAWebOAuthControllerOSX alloc] initWithURLRequest:request redirectURI:redirectURI completion:completion];
    #else
    completion(RLAErrorSystemNotSupported, nil);
    return nil;
    #endif
}

+ (NSString *)OAuthTemporalCodeFromRequest:(NSURLRequest *)request withRedirectURI:(NSString *)redirectURI
{
    NSString* result;
    if (!request || !redirectURI) { return result; }
    
    NSString* urlString = [request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    BOOL const isRedirectURI = ([urlString rangeOfString:redirectURI].location == 0);
    if (isRedirectURI)
    {
        NSString* query = [request.URL.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString* codeKey = @"code=";
        NSRange const range = [query rangeOfString:codeKey];
        if (range.location != NSNotFound)
        {
            result = [[query substringFromIndex:(range.location + codeKey.length)] componentsSeparatedByString:@"&"].firstObject;
        }
    }
    
    return result;
}

@end
