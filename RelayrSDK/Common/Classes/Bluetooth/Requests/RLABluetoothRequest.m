#import "RLABluetoothRequest.h"                 // Header
#import "RLABluetoothServiceListenerManager.h"  // Relayr.framework (protocol)

@interface RLABluetoothRequest() <RLABluetoothListenerDelegate>
@end

@implementation RLABluetoothRequest
{
    RLABluetoothServiceListenerManager* _listenerManager;
    void (^_completionHandler)(NSArray*, NSError*);
}

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithListenerManager:(RLABluetoothServiceListenerManager*)manager
{
    RLAErrorAssertTrueAndReturnNil(manager, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self) { _listenerManager = manager; }
    return self;
}

- (RLABluetoothServiceListenerManager*)manager
{
    return _listenerManager;
}

- (void(^)(NSArray*, NSError*))completionHandler
{
    return _completionHandler;
}

- (void)executeWithCompletionHandler:(void(^)(NSArray*, NSError*))completion
{
    _completionHandler = completion;
    [_listenerManager addListener:self];
}

@end
