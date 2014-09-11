#import "RelayrCloud.h"         // Header
#import "RLAWebService.h"       // Relayr.framework (Web)
#import "RLAWebService+Cloud.h" // Relayr.framework (Web)
#import "RLAWebService+User.h"  // Relayr.framework (Web)
#import "RLAError.h"            // Relayr.framework (Utilities)
#import "RLALog.h"              // Relayr.framework (Utilities)

@implementation RelayrCloud

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (void)isReachable:(void (^)(NSError* error, NSNumber* isReachable))completion
{
    if (!completion) { return [RLALog debug:dRLAErrorMessageMissingArgument]; }
    [RLAWebService isRelayrCloudReachable:completion];
}

+ (void)isUserWithEmail:(NSString*)email registered:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    if (!completion) { return [RLALog debug:dRLAErrorMessageMissingArgument]; }
    [RLAWebService isUserWithEmail:email registeredInRelayrCloud:completion];
}

@end
