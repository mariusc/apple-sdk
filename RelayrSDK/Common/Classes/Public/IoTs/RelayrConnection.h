@import Foundation;     // Apple
@class RelayrDevice;    // Relayr.framework (Public)

/*!
 *  @abstract The type of connection between a Device either a transmitter, a MAC, a mobile device etc.
 *
 *  @constant RelayrConnectionTypeCloud The device is connected via the relayr Cloud.
 *  @constant RelayrConnectionTypeBluetooth The device is connected via Bluetooth.
 *  @constant RelayrConnectionTypeUnknown The device is connected via an unknown channel or not connected at all.
 */
typedef NS_ENUM(NSUInteger, RelayrConnectionType) {
    RelayrConnectionTypeUnknown,
    RelayrConnectionTypeCloud,
    RelayrConnectionTypeBluetooth
};

/*!
 *  @abstract The state of the connection.
 *
 *  @constant RelayrConnectionStateUnknonw The state of the connection is unknown.
 *  @constant RelayrConnectionStateConnecting The connection is being established.
 *  @constant RelayrConnectionStateConnected The connection is on and functions as expected.
 *  @constant RelayrConnectionStateDisconnecting The connection is being disabled.
 */
typedef NS_ENUM(NSUInteger, RelayrConnectionState) {
    RelayrConnectionStateUnknown,
    RelayrConnectionStateConnecting,
    RelayrConnectionStateConnected,
    RelayrConnectionStateDisconnecting
};

/*!
 *  @abstract Represents the type of connection between the current platform and the device or transmitter.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrConnection : NSObject

/*!
 *  @abstract Specifies which device the connection is associated to.
 */
@property (readonly,weak,nonatomic) RelayrDevice* device;

/*!
 *  @abstract The connection technology used.
 */
@property (readonly,nonatomic) RelayrConnectionType type;

/*!
 *  @abstract The connection state of the current connection type.
 */
@property (readonly,nonatomic) RelayrConnectionState state;

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
- (void)subscribeToStateChangesWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))subscriptionError;

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
- (void)subscribeToStateChangesWithBlock:(void (^)(RelayrConnection* connection, RelayrConnectionState currentState, RelayrConnectionState previousState, BOOL* unsubscribe))block error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Unsubscribes the specific action from the target object.
 *  @discussion If a target object has more than one subscription with different actions, 
 *	this unsubscribe method only affects the actions being passed.
 *
 *  @param target The object where the subscription is being sent to.
 *  @param action The action being executed on the target each time information arrives.
 */
- (void)unsubscribeTarget:(id)target action:(SEL)action;

/*!
 *  @abstract Removes all subscriptions for this connection.
 *  @discussion All subscriptions, whether blocks or target objects are removed.
 */
- (void)removeAllSubscriptions;

@end
