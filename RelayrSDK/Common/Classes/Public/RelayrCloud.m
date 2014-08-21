#import "RelayrCloud.h"     // Header
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
    if (!completion) { return; }
    
    
    
    

}

// TODO: Fill up
+ (void)isApplicationID:(NSString *)appID valid:(void (^)(NSError* error, BOOL exists))completion
{
    if (!completion) { return [RLALog debug:RLAErrorMessageMissingArgument]; }
    
    
    
}

@end
