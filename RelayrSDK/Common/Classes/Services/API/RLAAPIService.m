#import "RLAAPIService.h"           // Header
#import "RelayrCloud.h"             // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)

// WebRequests methods
NSString* const kRLAAPIRequestModeCOPY      = @"COPY";
NSString* const kRLAAPIRequestModeDELETE    = @"DELETE";
NSString* const kRLAAPIRequestModeGET       = @"GET";
NSString* const kRLAAPIRequestModeHEAD      = @"HEAD";
NSString* const kRLAAPIRequestModeOPTIONS   = @"OPTIONS";
NSString* const kRLAAPIRequestModePATCH     = @"PATCH";
NSString* const kRLAAPIRequestModePOST      = @"POST";
NSString* const kRLAAPIRequestModePUT       = @"PUT";

@implementation RLAAPIService

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUser:(RelayrUser*)user
{
    if (!user.token.length) { return nil; }

    self = [super init];
    if (self)
    {
        _user = user;
        _hostString = dRLAAPI_Host;
        
        NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        sessionConfiguration.HTTPCookieStorage = nil;
        sessionConfiguration.HTTPShouldSetCookies = NO;
        sessionConfiguration.TLSMinimumSupportedProtocol = kTLSProtocol12;
        sessionConfiguration.networkServiceType = NSURLNetworkServiceTypeDefault;
        sessionConfiguration.allowsCellularAccess = YES;
        sessionConfiguration.HTTPAdditionalHeaders = @{
            dRLAAPIRequest_HeaderField_UserAgent    : [RelayrCloud userAgentString]
        };
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        if (!_session) { return nil; }
    }
    return self;
}

- (void)setHostString:(NSString*)hostString
{
    _hostString = (hostString) ? hostString : dRLAAPI_Host;
}

+ (NSURL*)buildAbsoluteURLFromHost:(NSString*)hostString relativeString:(NSString*)relativePath
{
    NSString* result = (hostString)
        ? (relativePath.length) ? [hostString stringByAppendingString:relativePath] : hostString
        : (relativePath.length) ? relativePath : nil;
    return [NSURL URLWithString:[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSMutableURLRequest*)requestForURL:(NSURL*)absoluteURL HTTPMethod:(NSString*)httpMode authorizationToken:(NSString*)authorizationToken
{
    if (!absoluteURL || !httpMode.length) { return nil; }
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:absoluteURL];
    if (!request) { return nil; }
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPMethod = httpMode;
    request.HTTPShouldUsePipelining = YES;
    request.HTTPShouldHandleCookies = NO;
    if (authorizationToken.length) { [request setValue:dRLAAPIRequest_HeaderValue_Authorization(authorizationToken) forHTTPHeaderField:dRLAAPIRequest_HeaderField_Authorization]; }
    
    return request;
}

@end
