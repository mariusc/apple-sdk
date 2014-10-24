#import "RelayrConnection.h"        // Header

#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrConnection_Setup.h"  // Relayr.framework (Private)

@implementation RelayrConnection

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithDevice:(RelayrDevice*)device
{
    if (!device.uid) { return nil; }
    
    self = [super init];
    if (self)
    {
        _device = device;
        _type = RelayrConnectionTypeUnknown;
        _protocol = RelayrConnectionProtocolUnknwon;
        _state = RelayrConnectionStateUnknown;
    }
    return self;
}

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

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrConnection\n{\n\t Type:\t%@\n\t Protocol:\t%@\n\t State:\t%@\n}\n", [RelayrConnection stringRepresentationOfConnectionType:_type], [RelayrConnection stringRepresentationOfConnectionProtocol:_protocol], [RelayrConnection stringRepresentationOfConnectionState:_state]];
}

#pragma mark - Private functionality

+ (NSString*)stringRepresentationOfConnectionType:(RelayrConnectionType)type
{
    return  (type == RelayrConnectionTypeUnknown)   ? @"Unknown"    :
            (type == RelayrConnectionTypeCloud)     ? @"Cloud"      :
            (type == RelayrConnectionTypeDirect)    ? @"Direct"     : nil;
}

+ (NSString*)stringRepresentationOfConnectionProtocol:(RelayrConnectionProtocol)protocol
{
    return  (protocol == RelayrConnectionProtocolUnknwon)   ? @"Unknown"    :
            (protocol == RelayrConnectionProtocolMQTT)      ? @"MQTT"       :
            (protocol == RelayrConnectionProtocolBLE)       ? @"BLE"        : nil;
}

+ (NSString*)stringRepresentationOfConnectionState:(RelayrConnectionState)state
{
    return  (state == RelayrConnectionStateUnknown)         ? @"Unknown"        :
            (state == RelayrConnectionStateConnecting)      ? @"Connecting"     :
            (state == RelayrConnectionStateConnected)       ? @"Connected"      :
            (state == RelayrConnectionStateDisconnecting)   ? @"Disconneting"   : nil;
}

@end
