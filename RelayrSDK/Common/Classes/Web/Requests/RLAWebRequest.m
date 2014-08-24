#import "RLAWebRequest.h"       // Header
#import "RLALog.h"              // Relayr.framework (Utilities)
#import "RLAError.h"            // Relayr.framework (Utilities)

NSString* const kRLAWebRequestModeGET = @"GET";
NSString* const kRLAWebRequestModePOST = @"POST";

static NSTimeInterval const kDefaultTimeout = 10;
static NSString* const kDefaultHTTPHeaderFieldAuthorization = @"Authorization";
static NSString* const kDefaultHTTPHeaderValueTokenFormat   = @"Bearer %@";
static NSString* const kDefaultHTTPHeaderFieldContentType   = @"Content-Type";
static NSString* const kDefaultHTTPHeaderValueContentUTF8   = @"application/x-www-form-urlencoded";
static NSString* const kDefaultHTTPHeaderValueContentJSON   = @"application/json";

@implementation RLAWebRequest

#pragma mark - Public API

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
    request.timeoutInterval = (_timeout) ? _timeout.doubleValue : kDefaultTimeout;
    if (!request) { return NO; }
    
    if (_oauthToken)
    {
        [request setValue:kDefaultHTTPHeaderFieldAuthorization forHTTPHeaderField:kDefaultHTTPHeaderValueTokenFormat];
    }
    
    if (_httpHeaders.count)
    {
        [_httpHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setValue:key forHTTPHeaderField:obj];
        }];
    }
    
    if (_body)
    {
        NSData* bodyData;
        NSError* error;
        
        if ( [_body isKindOfClass:[NSString class]] && ((NSString*)_body).length )
        {
            bodyData = [((NSString*)_body) dataUsingEncoding:NSUTF8StringEncoding];
            [request setValue:kDefaultHTTPHeaderFieldContentType forHTTPHeaderField:kDefaultHTTPHeaderValueContentUTF8];
        }
        else if ( [_body isKindOfClass:[NSDictionary class]] && ((NSDictionary*)_body).count )
        {
            bodyData = [NSJSONSerialization dataWithJSONObject:_body options:kNilOptions error:&error];
            [request setValue:kDefaultHTTPHeaderFieldContentType forHTTPHeaderField:kDefaultHTTPHeaderValueContentJSON];
        }
        
        if (!bodyData)
        {
            [request setValue:kDefaultHTTPHeaderFieldContentType forHTTPHeaderField:nil];
            [RLALog debug:((error) ? error.localizedDescription : RLAErrorMessageMissingExpectedValue)];
            return NO;
        }
        
        request.HTTPBody = bodyData;
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        
        if (!completion) { return; }
        if (connectionError) { return completion(connectionError, nil); }
        
        if ( ((NSHTTPURLResponse*)response).statusCode != statusCode )
        {
            NSString* serverString = (data) ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
            NSError* error = [RLAError errorWithCode:kRLAErrorCodeWebrequestFailure localizedDescription:((serverString) ? serverString : RLAErrorMessageWebrequestFailure) userInfo:RLAErrorUserInfoLocal];
            
            return completion(error, nil);
        }
        
        if (completion) { completion(nil, data); }
    }];
    
    return YES;
}

#pragma mark - Private methods

+ (NSURL*)buildAbsoluteURLWithHost:(NSURL*)hostURL relativeURL:(NSString*)relativePath
{
    NSURL* result;
    
    if (hostURL)
    {
        result = (!relativePath.length) ? hostURL : [hostURL URLByAppendingPathComponent:relativePath];
    }
    else
    {
        result = (!relativePath.length) ? nil : [NSURL URLWithString:relativePath];
    }
    
    return result;
}

@end
