#import "RLAAPIRequest.h"       // Header
#import "RLAAPIConstants.h"     // Relayr.framework (Service/API)
#import "RLALog.h"              // Relayr.framework (Utilities)
#import "RelayrErrors.h"        // Relayr.framework (Utilities)

// WebRequests methods
NSString* const kRLAAPIRequestModeCOPY      = @"COPY";
NSString* const kRLAAPIRequestModeDELETE    = @"DELETE";
NSString* const kRLAAPIRequestModeGET       = @"GET";
NSString* const kRLAAPIRequestModeHEAD      = @"HEAD";
NSString* const kRLAAPIRequestModeOPTIONS   = @"OPTIONS";
NSString* const kRLAAPIRequestModePATCH     = @"PATCH";
NSString* const kRLAAPIRequestModePOST      = @"POST";
NSString* const kRLAAPIRequestModePUT       = @"PUT";

// UserAgent WebRequest header
NSString* kRLAAPIRequestUserAgent;

@implementation RLAAPIRequest

#pragma mark - Public API

//+ (void)initialize
//{
//    kRLAAPIRequestUserAgent = [NSString stringWithCString:BUILDVARIABLE_USERAGENT encoding:NSUTF8StringEncoding];
//}

- (instancetype)initWithHost:(NSString*)hostString
{
    return [self initWithHost:hostString timeout:nil oauthToken:nil];
}

- (instancetype)initWithHost:(NSString*)hostString timeout:(NSNumber*)timeout oauthToken:(NSString*)token
{
    self = [self init];
    if (self)
    {
        _hostString = hostString;
        _timeout = timeout;
        _oauthToken = token;
    }
    return self;
}

- (BOOL)executeInHTTPMode:(NSString*)mode completion:(void (^)(NSError* error, NSNumber* responseCode, NSData* data))completion
{
    if (!mode) { return NO; }

    NSURL* url = [RLAAPIRequest buildAbsoluteURLWithHost:_hostString relativeURL:_relativePath];
    if (!url) { return NO; }

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    if (!request) { return NO; }
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPMethod = mode;
    request.timeoutInterval = (_timeout) ? _timeout.doubleValue : dRLAAPIRequest_Timeout;
    request.HTTPShouldUsePipelining = YES;
    // FIX ME: Resolve the problem
    //[request setValue:kRLAAPIRequestUserAgent forHTTPHeaderField:dRLAAPIRequest_HeaderField_UserAgent];

    if (_oauthToken)
    {
        [request setValue:dRLAAPIRequest_HeaderValue_Authorization(_oauthToken) forHTTPHeaderField:dRLAAPIRequest_HeaderField_Authorization];
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
            headerValue = dRLAAPIRequest_HeaderValue_ContentType_UTF8;
            bodyValue = [((NSString*)_body) dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ( ([_body isKindOfClass:[NSDictionary class]] && ((NSDictionary*)_body).count) ||
                  ([_body isKindOfClass:[NSArray class]] && ((NSArray*)_body).count) )
        {
            headerValue = dRLAAPIRequest_HeaderValue_ContentType_JSON;

            NSError* error;
            bodyValue = [NSJSONSerialization dataWithJSONObject:_body options:kNilOptions error:&error];
            if (error) { return NO; }
        }

        if (!bodyValue) { return NO; }
        [request setValue:headerValue forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
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

+ (NSURL*)buildAbsoluteURLWithHost:(NSString*)hostString relativeURL:(NSString*)relativePath
{
    NSString* result;
    if (hostString)
    {
        result = (relativePath.length) ? [hostString stringByAppendingString:relativePath] : hostString;
    }
    else
    {
        result = (relativePath.length) ? relativePath : nil;
    }
    return [NSURL URLWithString:[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
