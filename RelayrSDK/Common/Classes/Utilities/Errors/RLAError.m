#import "RLAError.h" // Header

static NSString* const kRLAErrorDomain = @"io.relayr";

@implementation RLAError

#pragma mark - Public API

+ (NSError*)errorWithCode:(RLAErrorCode)code info:(NSDictionary*)info
{
    return [NSError errorWithDomain:kRLAErrorDomain code:code userInfo:info];
}

+ (NSError *)errorWithCode:(RLAErrorCode)code localizedDescription:(NSString*)localizedDescription failureReason:(NSString*)failureReason
{
    RLAErrorAssertTrueAndReturnNil(code, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(localizedDescription, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(failureReason, RLAErrorCodeMissingArgument);
    
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey: localizedDescription, NSLocalizedFailureReasonErrorKey : failureReason};
    NSError*error = [NSError errorWithDomain:kRLAErrorDomain code:code userInfo:userInfo];
    return error;
}

@end
