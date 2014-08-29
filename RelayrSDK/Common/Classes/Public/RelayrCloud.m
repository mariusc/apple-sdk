#import "RelayrCloud.h"     // Header
#import "RLAWebService.h"   // Relayr.framework (Web)
#import "RLAError.h"        // Relayr.framework (Utilities)
#import "RLALog.h"          // Relayr.framework (Utilities)

@implementation RelayrCloud

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// TODO: Fill up
+ (void)isReachable:(void (^)(NSError* error, BOOL isReachable))completion
{
    if (!completion) { return [RLALog debug:dRLAErrorMessageMissingArgument]; }
    
    
}

// TODO: Fill up
+ (void)isApplicationID:(NSString *)appID valid:(void (^)(NSError* error, BOOL exists))completion
{
    if (!completion) { return [RLALog debug:dRLAErrorMessageMissingArgument]; }
    
    
}

// TODO: Fill up
+ (void)isUserWithEmail:(NSString *)email registered:(void (^)(NSError*, NSNumber*))completion
{
    if (!completion) { return [RLALog debug:dRLAErrorMessageMissingArgument]; }
    [RLAWebService isUserWithEmail:email registeredInRelayrCloud:completion];
}

@end
