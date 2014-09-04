#import "RLAWebRequest.h"       // Header
#import "RLAWebConstants.h"     // Relayr.framework (Web)
#import "RLALog.h"              // Relayr.framework (Utilities)
#import "RLAError.h"            // Relayr.framework (Utilities)

// WebRequests methods
NSString* const kRLAWebRequestModeCOPY      = @"COPY";
NSString* const kRLAWebRequestModeDELETE    = @"DELETE";
NSString* const kRLAWebRequestModeGET       = @"GET";
NSString* const kRLAWebRequestModeHEAD      = @"HEAD";
NSString* const kRLAWebRequestModeOPTIONS   = @"OPTIONS";
NSString* const kRLAWebRequestModePATCH     = @"PATCH";
NSString* const kRLAWebRequestModePOST      = @"POST";
NSString* const kRLAWebRequestModePUT       = @"PUT";

// UserAgent WebRequest header
NSString* kRLAWebRequestUserAgent;

@implementation RLAWebRequest

#pragma mark - Public API

+ (void)initialize
{
    // TODO: Find a better way that doesn't require it to retrieve the constant at runtime.
    kRLAWebRequestUserAgent = [[NSProcessInfo processInfo].environment objectForKey:@"WEBREQUEST_USERAGENT"];
}

- (instancetype)initWithHostURL:(NSURL*)hostURL
{
    return [self initWithHostURL:hostURL timeout:nil oauthToken:nil];
}

- (instancetype)initWithHostURL:(NSURL*)hostURL timeout:(NSNumber*)timeout oauthToken:(NSString*)token
{
    self = [self init];
    if (self)
    {
        [[NSProcessInfo processInfo].environment objectForKey:@"WEBREQUEST_USERAGENT"];
        _hostURL = hostURL;
        _timeout = timeout;
        _oauthToken = token;
    }
    return self;
}

- (BOOL)executeInHTTPMode:(NSString *)mode completion:(void (^)(NSError* error, NSNumber* responseCode, NSData* data))completion
{
    if (!mode) { return NO; }
    
    NSURL* url = [RLAWebRequest buildAbsoluteURLWithHost:_hostURL relativeURL:_relativePath];
    if (!url) { return NO; }

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPMethod = mode;
    request.timeoutInterval = (_timeout) ? _timeout.doubleValue : dRLAWebRequest_Timeout;
    [request setValue:kRLAWebRequestUserAgent forHTTPHeaderField:dRLAWebRequest_HeaderField_UserAgent];
    if (!request) { return NO; }
    
    if (_oauthToken)
    {
        [request setValue:dRLAWebRequest_HeaderValue_Authorization(_oauthToken) forHTTPHeaderField:dRLAWebRequest_HeaderField_Authorization];
    }
    
    if (_httpHeaders.count)
    {
        [_httpHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    if (_body)
    {
        NSString* headerValue;
        NSData* bodyValue;
        
        if ( [_body isKindOfClass:[NSString class]] && ((NSString*)_body).length )
        {
            headerValue = dRLAWebRequest_HeaderValue_ContentType_UTF8;
            bodyValue = [((NSString*)_body) dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ( ([_body isKindOfClass:[NSDictionary class]] && ((NSDictionary*)_body).count) ||
                  ([_body isKindOfClass:[NSArray class]] && ((NSArray*)_body).count) )
        {
            headerValue = dRLAWebRequest_HeaderValue_ContentType_JSON;
            
            NSError* error;
            bodyValue = [NSJSONSerialization dataWithJSONObject:_body options:kNilOptions error:&error];
            if (error) { return NO; }
        }
        
        if (!bodyValue) { return NO; }
        [request setValue:headerValue forHTTPHeaderField:dRLAWebRequest_HeaderField_ContentType];
        request.HTTPBody = bodyValue;
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        if (!completion) { return; }
        if (connectionError) { completion(connectionError, nil, nil); return; }
        
        NSNumber* statusCode;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode != NSNotFound) { statusCode = [NSNumber numberWithInteger:httpResponse.statusCode]; }
        }
        
        completion(nil, statusCode, data);
    }];
    
    return YES;
}

#pragma mark - Private methods

+ (NSURL*)buildAbsoluteURLWithHost:(NSURL*)hostURL relativeURL:(NSString*)relativePath
{
    if (hostURL)
    {
        return (!relativePath.length) ? hostURL : [hostURL URLByAppendingPathComponent:relativePath];
    }
    else
    {
        return (!relativePath.length) ? nil : [NSURL URLWithString:relativePath];
    }
}

@end
