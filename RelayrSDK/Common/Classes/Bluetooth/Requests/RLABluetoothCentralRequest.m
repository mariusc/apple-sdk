#import "RLABluetoothCentralRequest.h"     // Header
#import "RLABluetoothManager.h"     // Relayr.framework (protocol)

@interface RLABluetoothCentralRequest() <RLABluetoothDelegate>
@end

@implementation RLABluetoothCentralRequest
{
    RLABluetoothManager* _listenerManager;
    void (^_completionHandler)(NSArray*, NSError*);
}

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithListenerManager:(RLABluetoothManager*)manager
{
    RLAErrorAssertTrueAndReturnNil(manager, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self) { _listenerManager = manager; }
    return self;
}

- (RLABluetoothManager*)manager
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
