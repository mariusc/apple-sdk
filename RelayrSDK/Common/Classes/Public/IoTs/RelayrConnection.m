//
#import "RelayrConnection.h"

@implementation RelayrConnection

- (void)subscribeToStateChangesWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))subscriptionError
{
    // TODO: Fill up
}

- (void)subscribeToStateChangesWithBlock:(void (^)(RelayrConnection* connection, RelayrConnectionState currentState, RelayrConnectionState previousState, BOOL* unsubscribe))block error:(BOOL (^)(NSError* error))subscriptionError
{
    // TODO: Fill up
}

- (void)unsubscribeTarget:(id)target action:(SEL)action
{
    // TODO: Fill up
}

- (void)removeAllSubscriptions
{
    // TODO: Fill up
}

@end
