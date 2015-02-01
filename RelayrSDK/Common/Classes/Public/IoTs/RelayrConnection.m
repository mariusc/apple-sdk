#import "RelayrConnection.h"        // Header

#import "RelayrDevice.h"            // Relayr.framework (Public/IoTs)
#import "RelayrConnection_Setup.h"  // Relayr.framework (Private)

@implementation RelayrConnection

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)hasOngoingSubscriptions
{
    return NO;  // TODO: Fill up
}

- (void)subscribeToStateChangesWithTarget:(id)target action:(SEL)action error:(void (^)(NSError* error))subscriptionError
{
    // TODO: Fill up
}

- (void)subscribeToStateChangesWithBlock:(void (^)(RelayrConnection* connection, RelayrConnectionState currentState, RelayrConnectionState previousState, BOOL* unsubscribe))block error:(void (^)(NSError* error))subscriptionError
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

#pragma mark Setup extension

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
        _scope = RelayrConnectionScopeUnknown;
    }
    return self;
}

- (void)setWith:(RelayrConnection*)connection
{
    if (!connection || self==connection) { return; }
    
    // TODO: Fill up
}

#pragma mark NSCopying & NSMutableCopying

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
    return self;
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrConnection\n{\n\t Type:\t%@\n\t Protocol:\t%@\n\t State:\t%@\n\t Scope:\t%@\n}\n",
            [RelayrConnection stringRepresentationOfConnectionType:_type],
            [RelayrConnection stringRepresentationOfConnectionProtocol:_protocol],
            [RelayrConnection stringRepresentationOfConnectionState:_state],
            [RelayrConnection stringRepresentationOfConnectionScope:_scope]];
}

#pragma mark - Private functionality

+ (NSString*)stringRepresentationOfConnectionType:(RelayrConnectionType)type
{
    return  (type == RelayrConnectionTypeUnknown)   ? @"Unknown" :
            (type == RelayrConnectionTypeCloud)     ? @"Cloud"   :
            (type == RelayrConnectionTypeDirect)    ? @"Direct"  : nil;
}

+ (NSString*)stringRepresentationOfConnectionProtocol:(RelayrConnectionProtocol)protocol
{
    return  (protocol == RelayrConnectionProtocolUnknwon)   ? @"Unknown" :
            (protocol == RelayrConnectionProtocolMQTT)      ? @"MQTT"    :
            (protocol == RelayrConnectionProtocolBLE)       ? @"BLE"     : nil;
}

+ (NSString*)stringRepresentationOfConnectionState:(RelayrConnectionState)state
{
    return  (state == RelayrConnectionStateUnknown)         ? @"Unknown"       :
            (state == RelayrConnectionStateUnsupported)     ? @"Unsupported"   :
            (state == RelayrConnectionStateUnauthorized)    ? @"Unauthorized"  :
            (state == RelayrConnectionStateConnecting)      ? @"Connecting"    :
            (state == RelayrConnectionStateConnected)       ? @"Connected"     :
            (state == RelayrConnectionStateDisconnecting)   ? @"Disconneting"  : nil;
}

+ (NSString*)stringRepresentationOfConnectionScope:(RelayrConnectionScope)scope
{
    return  (scope == RelayrConnectionScopeUnknown) ? @"Unknown"             :
            (scope == RelayrConnectionScopePAN)     ? @"Person Area Network" :
            (scope == RelayrConnectionScopeLAN)     ? @"Local Area Network"  :
            (scope == RelayrConnectionScopeWAN)     ? @"Wide Area Network"   : nil;
}

@end
