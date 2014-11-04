#import "RelayrCloud.h"         // Header
#import "RLAAPIService.h"       // Relayr.framework (Service/API)
#import "RLAAPIService+Cloud.h" // Relayr.framework (Service/API)
#import "RLAAPIService+User.h"  // Relayr.framework (Service/API)
#import "RelayrErrors.h"        // Relayr.framework (Utilities)
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
    if (!completion) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    [RLAAPIService isRelayrCloudReachable:completion];
}

+ (void)isUserWithEmail:(NSString*)email registered:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    if (!completion) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    [RLAAPIService isUserWithEmail:email registeredInRelayrCloud:completion];
}

@end
