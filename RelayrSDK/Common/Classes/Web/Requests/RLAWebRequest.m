#import "RLAWebRequest.h"       // Header
#import "RLAWebConstants.h"     // Relayr.framework (Web)
#import "RLALog.h"              // Relayr.framework (Utilities)
#import "RLAError.h"            // Relayr.framework (Utilities)

NSString* const kRLAWebRequestModeCOPY      = @"COPY";
NSString* const kRLAWebRequestModeDELETE    = @"DELETE";
NSString* const kRLAWebRequestModeGET       = @"GET";
NSString* const kRLAWebRequestModeHEAD      = @"HEAD";
NSString* const kRLAWebRequestModeOPTIONS   = @"OPTIONS";
NSString* const kRLAWebRequestModePATCH     = @"PATCH";
NSString* const kRLAWebRequestModePOST      = @"POST";
NSString* const kRLAWebRequestModePUT       = @"PUT";

@implementation RLAWebRequest

#pragma mark - Public API

- (instancetype)initWithHostURL:(NSURL*)hostURL
{
    return [self initWithHostURL:hostURL timeout:nil oauthToken:nil];
}

- (instancetype)initWithHostURL:(NSURL*)hostURL timeout:(NSNumber*)timeout oauthToken:(NSString*)token
{
    self = [self init];
    if (self)
    {
        _hostURL = hostURL;
        _timeout = timeout;
        _oauthToken = token;
    }
    return self;
}

- (BOOL)executeInHTTPMode:(NSString*)mode withExpectedStatusCode:(NSUInteger const)statusCode completion:(void (^)(NSError* error, NSData* data))completion
{
    if (!mode) { return NO; }
    
    NSURL* url = [RLAWebRequest buildAbsoluteURLWithHost:_hostURL relativeURL:_relativePath];
    if (!url) { return NO; }

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPMethod = mode;
    request.timeoutInterval = (_timeout) ? _timeout.doubleValue : dRLAWebRequest_Timeout;
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
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:(!completion) ? nil : ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) { return completion(connectionError, nil); }
        
        if ( ((NSHTTPURLResponse*)response).statusCode != statusCode )
        {
            NSString* serverString = (data) ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
            NSError* error = [RLAError errorWithCode:kRLAErrorCodeWebrequestFailure localizedDescription:((serverString) ? serverString : dRLAErrorMessageWebrequestFailure) userInfo:RLAErrorUserInfoLocal];
            return completion(error, nil);
        }
        else { completion(nil, data); }
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
