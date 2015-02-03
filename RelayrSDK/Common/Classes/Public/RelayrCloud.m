#import "RelayrCloud.h"         // Header
#import "RelayrUser.h"          // Relayr (Public)
#import "RLAAPIService.h"       // Relayr (Service/API)
#import "RLAAPIService+Cloud.h" // Relayr (Service/API)
#import "RLAAPIService+App.h"   // Relayr (Service/API)
#import "RLAAPIService+User.h"  // Relayr (Service/API)
#import "RLAAPIConstants.h"     // Relayr (Service/API)
#import "RelayrErrors.h"        // Relayr (Utilities)
#import "RLALog.h"              // Relayr (Utilities)
#import <CBasics/CPlatforms.h>  // CBasics
#import <sys/sysctl.h>          // BSD

static NSString* const kRelayrCloud_LoggingSession_ID           = @"io.relayr.sdk.RelayrCloud.logginURLSession";
static NSString* const kRelayrCloud_LoggingSession_timestamp    = @"timestamp";
static NSString* const kRelayrCloud_LoggingSession_message      = @"message";
static NSString* const kRelayrCloud_LoggingSession_connection   = @"connection";

#define dRelayrCloud_operatingSystem_iOS        @"iOS"
#define dRelayrCloud_operatingSystem_OSX        @"OSX"
#define dRelayrCloud_relayrSDK                  @"io.relayr.sdk.apple"
#define dRelayrCloud_platform_simulator         @"iPhoneSimulator"

@implementation RelayrCloud

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Cloud information

+ (void)isReachable:(void (^)(NSError* error, NSNumber* isReachable))completion
{
    if (!completion) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    [RLAAPIService isRelayrCloudReachable:completion];
}

+ (void)isUserWithEmail:(NSString*)email registered:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    if (!completion) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    [RLAAPIService isUserWithEmail:email registeredInRelayrCloud:completion];
}

+ (void)queryForAllRelayrPublicApps:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    [RLAAPIService requestAllRelayrApps:completion];
}

#pragma mark Logging system

+ (BOOL)logMessage:(NSString*)message onBehalfOfUser:(RelayrUser*)user
{
    if (!message.length || !user.token.length) { return NO; }
    
    NSArray* jsonArray = [NSArray arrayWithObject:@{
        kRelayrCloud_LoggingSession_timestamp   : [[RelayrCloud sharedLoggingDateFormatter] stringFromDate:[NSDate date]],
        kRelayrCloud_LoggingSession_message     : message
    }];
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:kNilOptions error:&serializationError];
    if (serializationError || !jsonData) { return NO; }
    
    NSURL* endPoint = [NSURL URLWithString:[dRLAAPI_Host stringByAppendingString:dRLAAPI_CloudLogging_RelativePath]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:endPoint];
    request.HTTPShouldUsePipelining = YES;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPMethod = kRLAAPIRequestModePOST;
    request.HTTPBody = jsonData;
    [request setValue:dRLAAPIRequest_HeaderValue_Authorization(user.token) forHTTPHeaderField:dRLAAPIRequest_HeaderField_Authorization];
    
    NSURLSessionDataTask* task = [[RelayrCloud sharedLoggingURLSession] dataTaskWithRequest:request];
    [task resume];
    return YES;
}

#pragma mark System information

+ (NSString*)userAgentString
{
    static NSString* userAgent;
    
    static dispatch_once_t userAgentToken;
    dispatch_once(&userAgentToken, ^{
        userAgent = [NSString stringWithFormat:@"%@/%@ (%@;%@)", dRelayrCloud_relayrSDK, [RelayrCloud sdkVersionNumber], [RelayrCloud operatingSystem], [RelayrCloud platform]];
    });
    
    return userAgent;
}

+ (NSString*)sdkVersionNumber
{
    static NSString* sdkVersion;
    
    static dispatch_once_t sdkVersionToken;
    dispatch_once(&sdkVersionToken, ^{
        char const* const version = RELAYRSDK_VERSION;
        sdkVersion = [NSString stringWithCString:version encoding:NSUTF8StringEncoding];
    });
    
    return sdkVersion;
}

+ (NSString*)operatingSystem
{
    static NSString* operatingSystem;
    
    static dispatch_once_t osToken;
    dispatch_once(&osToken, ^{
        NSString* os;
        #if defined(OS_APPLE_IOS) || defined(OS_APPLE_SIMULATOR)
        os = dRelayrCloud_operatingSystem_iOS;
        #elif defined(OS_APPLE_OSX)
        os = dRelayrCloud_operatingSystem_OSX;
        #else
        #error "System not supported"
        #endif
        
        NSOperatingSystemVersion version = NSProcessInfo.processInfo.operatingSystemVersion;
        operatingSystem = [NSString stringWithFormat:@"%@ %i.%i.%i", os, (int)version.majorVersion, (int)version.minorVersion, (int)version.patchVersion];
    });
    
    return operatingSystem;
}

+ (NSString*)platform
{
    static NSString* platform;
    
    static dispatch_once_t platformToken;
    dispatch_once(&platformToken, ^{
        size_t stringSize;
        sysctlbyname("hw.machine", NULL, &stringSize, NULL, 0);
        char* machine = malloc(stringSize);
        sysctlbyname("hw.machine", machine, &stringSize, NULL, 0);
        
        #if defined(OS_APPLE_IOS) || defined(OS_APPLE_OSX)
        platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        #elif defined(OS_APPLE_SIMULATOR)
        platform = [NSString stringWithFormat:@"%@ %@", dRelayrCloud_platform_simulator, [NSString stringWithCString:machine encoding:NSUTF8StringEncoding]];
        #else
        #error "System not supported"
        #endif
        
        free(machine);
    });
    
    return platform;
}

#pragma mark - Private functionality

/*!
 *  @abstract It returns the <code>NSURLSession</code> singleton used for logging.
 *  @discussion It is a lazily created object. So, if you never use logging, it will never be created.
 */
+ (NSURLSession*)sharedLoggingURLSession
{
    static NSURLSession* logginSession;
    
    static dispatch_once_t logginSessionToken;
    dispatch_once(&logginSessionToken, ^{
        NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kRelayrCloud_LoggingSession_ID];
        sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        sessionConfiguration.HTTPCookieStorage = nil;
        sessionConfiguration.HTTPShouldSetCookies = NO;
        sessionConfiguration.TLSMinimumSupportedProtocol = kTLSProtocol12;
        sessionConfiguration.networkServiceType = NSURLNetworkServiceTypeBackground;
        sessionConfiguration.allowsCellularAccess = YES;
        sessionConfiguration.HTTPAdditionalHeaders = @{
            dRLAAPIRequest_HeaderField_ContentType  : dRLAAPIRequest_HeaderValue_ContentType_JSON,
            dRLAAPIRequest_HeaderField_UserAgent    : [RelayrCloud userAgentString]
        };
        
        logginSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    });
    
    return logginSession;
}

/*!
 *  @abstract It returns the <code>NSDateFormatter</code> singleton used to transform a <code>NSDate</code> into an <code>NSString</code>.
 *  @discussion The logging system uses the ISO 8601 date formatting.
 */
+ (NSDateFormatter*)sharedLoggingDateFormatter
{
    static NSDateFormatter* dateFormatter;
    
    static dispatch_once_t dateFormatterToken;
    dispatch_once(&dateFormatterToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });
    
    return dateFormatter;
}

@end
