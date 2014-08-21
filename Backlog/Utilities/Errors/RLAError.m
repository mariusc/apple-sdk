#import "RLAError.h" // Header

NSString* const kRLAErrorDomain = @"io.relayr";
NSString* const kRLAErrorStringFile = @"RLYError";

@implementation RLAError

#pragma mark - Public API

+ (NSError*)errorWithCode:(RLAErrorCode)code localizedDescription:(NSString*)localizedDescription userInfo:(NSDictionary*)userInfo
{
    if (localizedDescription)
    {
        NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        tmp[NSLocalizedDescriptionKey] = localizedDescription;
        userInfo = [NSDictionary dictionaryWithDictionary:tmp];
    }
    
    return [NSError errorWithDomain:kRLAErrorDomain code:code userInfo:userInfo];
}

+ (NSError*)errorWithCode:(RLAErrorCode)code localizedDescription:(NSString*)localizedDescription failureReason:(NSString*)failureReason userInfo:(NSDictionary*)userInfo
{
    NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    if (localizedDescription) { tmp[NSLocalizedDescriptionKey] = localizedDescription; }
    if (failureReason) { tmp[NSLocalizedFailureReasonErrorKey] = failureReason; }
    
    return [NSError errorWithDomain:kRLAErrorDomain code:code userInfo:[NSDictionary dictionaryWithDictionary:tmp]];
}

@end
