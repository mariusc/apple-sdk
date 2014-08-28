#import "RLAWebViewOAuth.h"     // Header
#import "RLAWebConstants.h"     // Relayr.framework (Web)
#import "RLAError.h"            // Relayr.framework (Utilities)
#import "CPlatforms.h"          // Relayr.framework (Utilities)

#if defined(OS_APPLE_IOS) || defined (OS_APPLE_IOS_SIMULATOR)
#import "RLAWebViewOAuthIOS.h"  // Relayr.framework (Web)
#elif defined(OS_APPLE_OSX)
#import "RLAWebViewOAuthOSX.h"  // Relayr.framework (Web)
#endif

@implementation RLAWebViewOAuth

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (id<RLAWebViewOAuth>)webViewWithOAuthClientID:(NSString*)clientID redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* tmpCode))completion
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
    
    #if defined(OS_APPLE_IOS) || defined (OS_APPLE_IOS_SIMULATOR)
    return [[RLAWebViewOAuthIOS alloc] initWithURL:absoluteURL completion:completion];
    #elif defined(OS_APPLE_OSX)
    return [[RLAWebViewOAuthOSX alloc] initWithURL:absoluteURL completion:completion];
    #else
    completion(RLAErrorSystemNotSupported, nil);
    return nil;
    #endif
}

@end
