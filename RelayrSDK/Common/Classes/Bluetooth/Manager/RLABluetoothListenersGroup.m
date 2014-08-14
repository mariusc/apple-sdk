#import "RLABluetoothListenersGroup.h"

@implementation RLABluetoothListenersGroup
{
    NSPointerArray* _listeners;
}

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral listener:(id<RLABluetoothDelegate>)listener
{
    RLAErrorAssertTrueAndReturnNil(peripheral, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(listener, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _listeners = [NSPointerArray weakObjectsPointerArray];
        [_listeners addPointer:(void*)listener];
    }
    return self;
}

- (NSArray*)listeners
{
    return [_listeners allObjects];
}

- (void)addListener:(NSObject <RLABluetoothDelegate> *)listener
{
    RLAErrorAssertTrueAndReturn(listener, RLAErrorCodeMissingArgument);
    
    // Store listener if it is not already stored
    BOOL isInArray = NO;
    NSArray* listeners = [_listeners allObjects];
    
    for (NSObject* obj in listeners) {
        if (obj == listener) {
            isInArray = YES;
            break;
        }
    }
    
    if (!isInArray) [_listeners addPointer:(void*)listener];
}

- (void)removeListener:(NSObject <RLABluetoothDelegate> *)listener
{
    RLAErrorAssertTrueAndReturn(listener, RLAErrorCodeMissingArgument);
    
    NSInteger foundIndex = NSNotFound;
    NSInteger const count = [_listeners count];
    
    for (NSInteger index = 0; index < count; ++index) {
        NSObject* pointer = [_listeners pointerAtIndex:index];
        if (pointer == listener) { foundIndex = index; }
    }
    
    if (foundIndex != NSNotFound) { [_listeners removePointerAtIndex:foundIndex]; }
}

@end
