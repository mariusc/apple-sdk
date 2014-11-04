#import "RLAWebOAuthController.h"       // Header
#import "RLAAPIConstants.h"             // Relayr.framework (Service/API)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)
#import <CBasics/CPlatforms.h>          // Relayr.framework (Utilities)

#if defined(OS_APPLE_IOS) || defined (OS_APPLE_SIMULATOR)
#import "RLAWebOAuthControllerIOS.h"    // Relayr.framework (Service/API)
#elif defined(OS_APPLE_OSX)
#import "RLAWebOAuthControllerOSX.h"    // Relayr.framework (Service/API)
#endif

@implementation RLAWebOAuthController

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (id<RLAWebOAuthController>)webOAuthControllerWithClientID:(NSString*)clientID redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* tmpCode))completion
{
    if (!clientID || !redirectURI) { return nil; }

    NSURL* hostURL = [NSURL URLWithString:Web_Host];
    NSURL* absoluteURL = [NSURL URLWithString:dRLAWebOAuthController_CodeRequestURL(clientID, redirectURI) relativeToURL:hostURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:absoluteURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:dRLAWebOAuthController_Timeout];

    #if defined(OS_APPLE_IOS) || defined (OS_APPLE_SIMULATOR)
    return [[RLAWebOAuthControllerIOS alloc] initWithURLRequest:request redirectURI:redirectURI completion:completion];
    #elif defined(OS_APPLE_OSX)
    return [[RLAWebOAuthControllerOSX alloc] initWithURLRequest:request redirectURI:redirectURI completion:completion];
    #else
    return nil;
    #endif
}

+ (NSString*)OAuthTemporalCodeFromRequest:(NSURLRequest*)request withRedirectURI:(NSString*)redirectURI
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
