#import "RelayrErrors.h"    // Header

NSString* const kRelayrErrorDomain = @"io.relayr";
NSString* const kRelayrErrorStringFile = @"RLAErrors";

@implementation RelayrErrors

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (NSError*)errorWithCode:(NSInteger)code localizedDescription:(NSString*)localizedDescription userInfo:(NSDictionary*)userInfo
{
    if (localizedDescription)
    {
        NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        tmp[NSLocalizedDescriptionKey] = localizedDescription;
        userInfo = [NSDictionary dictionaryWithDictionary:tmp];
    }
    
    return [NSError errorWithDomain:kRelayrErrorDomain code:code userInfo:userInfo];
}

+ (NSError*)errorWithCode:(NSInteger)code localizedDescription:(NSString*)localizedDescription failureReason:(NSString*)failureReason userInfo:(NSDictionary*)userInfo
{
    NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    if (localizedDescription) { tmp[NSLocalizedDescriptionKey] = localizedDescription; }
    if (failureReason) { tmp[NSLocalizedFailureReasonErrorKey] = failureReason; }
    
    return [NSError errorWithDomain:kRelayrErrorDomain code:code userInfo:[NSDictionary dictionaryWithDictionary:tmp]];
}

@end
