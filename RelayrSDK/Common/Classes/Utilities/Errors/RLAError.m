#import "RLAError.h" // Header

@implementation RLAError

#pragma mark - Constants

static NSString* const kRLAErrorDomain = @"io.relayr";

#pragma mark - Public API

#pragma mark Class methods

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
