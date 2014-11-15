@import Foundation;     // Apple
@class RelayrDevice;    // Relayr.framework (Public)

#pragma mark - Definitions

/*!
 *  @abstract The type of connection between a device and the system running the SDK.
 *
 *  @constant RelayrConnectionTypeCloud The device's data is coming via the relayr Cloud.
 *  @constant RelayrConnectionTypeDirect The device's data is coming through a direct connection.
 *  @constant RelayrConnectionTypeUnknown The device's data is not being received or the source is unknown.
 */
typedef NS_ENUM(NSUInteger, RelayrConnectionType) {
    RelayrConnectionTypeUnknown,
    RelayrConnectionTypeCloud,
    RelayrConnectionTypeDirect
};

/*!
 *  @abstract The protocol being used by the connection between the system running the SDK and the device's data source.
 *
 *  @constant RelayrConnectionProtocolMQTT The protocol used is MQTT.
 *  @constant RelayrConnectionProtocolBLE The protocol used is Bluetooth Low Energy.
 *  @constant RelayrConnectionProtocolUnknown The protocol is unknown.
 */
typedef NS_ENUM(NSUInteger, RelayrConnectionProtocol) {
    RelayrConnectionProtocolUnknwon,
    RelayrConnectionProtocolMQTT,
    RelayrConnectionProtocolBLE
};

/*!
 *  @abstract The scope of the connection.
 *  @discussion The scope provide interesting information about the technology being used for the connection.
 *
 *  @constant RelayrConnectionScopeUnknown The scope is unknown at the moment.
 *  @constant RelayrConnectionScopePAN Personal Area Network scope. Technologies included here are BLE, Zigbee, etc.
 *  @constant RelayrConnectionScopeLAN Local Area Network scope. Technologies included here are Ethernet cable connection, WiFi connections, etc.
 *  @constant RelayrConnectionScopeWAN Wide Area Network scope. Many of the current mobile connection technologies are included here: EDGE, 3G, LTE, etc.
 */
typedef NS_ENUM(NSUInteger, RelayrConnectionScope) {
    RelayrConnectionScopeUnknown,
    RelayrConnectionScopePAN,
    RelayrConnectionScopeLAN,
    RelayrConnectionScopeWAN
};

/*!
 *  @abstract The state of the connection.
 *
 *  @constant RelayrConnectionStateUnknonw The state of the connection is unknown.
 *  @constant RelayrConnectionStateUnsupported The machine running the SDK does not support this connection.
 *  @constant RelayrConnectionStateUnauthorized The OS is not authorizing the SDK to use this connection.
 *  @constant RelayrConnectionStateConnecting The connection is being established.
 *  @constant RelayrConnectionStateConnected The connection is on and functions as expected.
 *  @constant RelayrConnectionStateDisconnecting The connection is being disabled.
 */
typedef NS_ENUM(NSUInteger, RelayrConnectionState) {
    RelayrConnectionStateUnknown,
    RelayrConnectionStateUnsupported,
    RelayrConnectionStateUnauthorized,
    RelayrConnectionStateConnecting,
    RelayrConnectionStateConnected,
    RelayrConnectionStateDisconnecting,
    RelayrConnectionStateDisconnected
};

/*!
 *  @abstract Represents the type of connection between the current platform and the device or transmitter.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrConnection : NSObject

#pragma mark - Public API

/*!
 *  @abstract Specifies which device the connection is associated to.
 */
@property (readonly,weak,nonatomic) RelayrDevice* device;

/*!
 *  @abstract Whether the connection is through the cloud or is directly performed with the device.
 */
@property (readonly,nonatomic) RelayrConnectionType type;

/*!
 *  @abstract Protocol being used by the connection between the device's data source and the system running the SDK.
 */
@property (readonly,nonatomic) RelayrConnectionProtocol protocol;

/*!
 *  @abstract The state of the current connection type.
 */
@property (readonly,nonatomic) RelayrConnectionState state;

/*!
 *  @abstract The scope of the current connection.
 */
@property (readonly,nonatomic) RelayrConnectionScope scope;

#pragma mark Subscriptions

/*!
 *  @abstract Virtual property that indicates whether there are ongoing subscriptions for this connection channel.
 *  @discussion Every time this property is called, a calculation is made to check if there are subscriptions running.
 */
@property (readonly,nonatomic) BOOL hasOngoingSubscriptions;

/*!
 *  @abstract Subscribes the block to the state changes of this connection.
 *  @discussion The block will be executed each time the connection state changes.
 *
 *  @param block This block will be executed each time data is available. The block contains three parameters:
 *      - <code>connection</code>. The connection abstraction object.
 *      - <code>currentState</code>. The current state of the connection.
 *      - <code>previousState</code>. The previous state of the connection.
 *      - <code>unsubscribe</code>. A Boolean parameter, that when set to <code>NO</code>, will stop the subscription.
 *	@param subscriptionError A Block executed if the subscription cannot be performed (it can be <code>nil</code>.
 *	If this block is defined, a boolean must be returned, indicating if a subscription retry should be attempted.
 */
- (void)subscribeToStateChangesWithBlock:(void (^)(RelayrConnection* connection, RelayrConnectionState currentState, RelayrConnectionState previousState, BOOL* unsubscribe))block
                                   error:(void (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Subscribes to the state change of the connection.
 *  @discussion Within this method, it is possible to query for the connection type.
 *
 *  @param target The object where the <code>action</code> will be called to.
 *  @param action The method to be called. It can have two modes:
 *      - No parameters.
 *      - One parameter. The parameter must be a <code>RelayrConnection</code> object, otherwise this method will return a subscription error.
 *  @param subscriptionError A Block executed if the subscription cannot be performed (it can be <code>nil</code>. 
 *	If this block is defined, a boolean must be returned, indicating if a subscription retry should be attempted.
 */
- (void)subscribeToStateChangesWithTarget:(id)target
                                   action:(SEL)action
                                    error:(void (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Unsubscribes the specific action from the target object.
 *  @discussion If a target object has more than one subscription with different actions, 
 *	this unsubscribe method only affects the actions being passed.
 *
 *  @param target The object where the subscription is being sent to.
 *  @param action The action being executed on the target each time information arrives.
 */
- (void)unsubscribeTarget:(id)target
                   action:(SEL)action;

/*!
 *  @abstract Removes all subscriptions for this connection.
 *  @discussion All subscriptions, whether blocks or target objects are removed.
 */
- (void)removeAllSubscriptions;

@end
