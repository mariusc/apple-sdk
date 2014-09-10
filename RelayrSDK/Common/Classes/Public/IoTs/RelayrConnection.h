@import Foundation;     // Apple
@class RelayrDevice;    // Relayr.framework (Public)

/*!
 *  @abstract The type of connection of the associated device/transmitter.
 *
 *  @constant RelayrConnectionTypeCloud The device/transmitter is connected through the Relayr Cloud.
 *  @constant RelayrConnectionTypeBluetooth The device/transmitter is connected through the Bluetooth.
 *  @constant RelayrConnectionTypeUnknown The device/transmitter is connected through an unknown channel or not connected at all.
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
 *  @constant RelayrConnectionStateConnecting The connection is being stablished.
 *  @constant RelayrConnectionStateConnected The connection is on and work as expected.
 *  @constant RelayrConnectionStateDisconnecting The connection is being disabled.
 */
typedef NS_ENUM(NSUInteger, RelayrConnectionState) {
    RelayrConnectionStateUnknown,
    RelayrConnectionStateConnecting,
    RelayrConnectionStateConnected,
    RelayrConnectionStateDisconnecting
};

/*!
 *  @abstract It express the type of connection between the current platform and the device or transmitter.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrConnection : NSObject

/*!
 *  @abstract Specifies which device is this connection associated to.
 */
@property (readonly,weak,nonatomic) RelayrDevice* device;

/*!
 *  @abstract The connection technology we are using right now.
 */
@property (readonly,nonatomic) RelayrConnectionType type;

/*!
 *  @abstract The connection state of the current connection type.
 */
@property (readonly,nonatomic) RelayrConnectionState state;

/*!
 *  @abstract Subscribes to the state change on the connection.
 *  @discussion Within this method, you can also query for the connection type.
 *
 *  @param target The object where the <code>action</code> will be called onto.
 *  @param action The method to be called. It can have two modalities:
 *      - No parameters.
 *      - One parameter. The parameter must be a <code>RelayrConnection</code> object, or this method will return a subscription error.
 *  @param subscriptionError Block executed if the subscription could not be performed (it can be <code>nil</code>. If you define this block, you must return a boolean indicating if you want to retry the subscription.
 */
- (void)subscribeToStateChangesWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Subscribes the block to state change of this connection.
 *  @discussion The block will be executed every time the connection state changes.
 *
 *  @param block This block will be executed everytime data is available. The block contains three parameters:
 *      - <code>connection</code>. The connection abstraction object.
 *      - <code>currentState</code>. The current state of the connection.
 *      - <code>previousState</code>. The previous state of the connection.
 *      - <code>unsubscribe</code>. Boolean pointer that when set to <code>NO</code>, will stop the subscription.
 *  @param subscriptionError Block executed if the subscription could not be performed (it can be <code>nil</code>. If you define this block, you must return a boolean indicating if you want to retry the subscription.
 */
- (void)subscribeToStateChangesWithBlock:(void (^)(RelayrConnection* connection, RelayrConnectionState currentState, RelayrConnectionState previousState, BOOL* unsubscribe))block error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Unsubscribe the specific action of a target object.
 *  @discussion If a target object has more than one subscription with different actions, this unsubscribe method only affects to the actions being passed.
 *
 *  @param target The object where the subscription was being sent to.
 *  @param action The action being executed on the target every time information arrives.
 */
- (void)unsubscribeTarget:(id)target action:(SEL)action;

/*!
 *  @abstract It removes all the subscriptions for this connection.
 *  @discussion All subscription, whether blocks or target objects are unsubscribe.
 */
- (void)removeAllSubscriptions;

@end
