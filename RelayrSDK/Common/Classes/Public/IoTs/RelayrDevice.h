#import "RelayrDeviceModel.h"   // Relayr.framework (Public)
#import "RelayrFirmware.h"      // Relayr.framework (Public)
@class RelayrUser;              // Relayr.framework (Public)
@class RelayrInput;             // Relayr.framework (Public)
@import Foundation;             // Apple

/*!
 *  @abstract An instance of this class represents a Device. A basic relayr entity
 *	@discussion A device is any external entity capable of producing measurements and sending them to a transmitter to be further sent to the relayr cloud, 
 *	or one which is capable of receiving information from the relayr platform. 
 *	Examples would be a thermometer, a gyroscope or an infrared sensor.
 */
@interface RelayrDevice : RelayrDeviceModel <NSCoding>

/*!
 *  @abstract A unique idenfier of the <code>RelayrDevice</code>'s instance.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract Device name.
 *  @discussion Can be updated using a server call.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract The Id of the owner of the Device.
 *  @discussion A relayr User Id.
 */
@property (readonly,nonatomic) NSString* owner;

/*!
 *  @abstract Indicates wheather the data gathered by the device is public (available to all users) or not (available to the Device owner only).
 *  @discussion An <code>NSNumber</code> wrapping a boolean value (use <code>.boolValue</code> to unwrap it). 
 */
@property (readonly,nonatomic) NSNumber* isPublic;

/*!
 *  @abstract Indicates firmware attributes of the Device instance being called.
 *  @discussion A device can have many different firmware versions. This indicates the firmware in the current device.
 */
@property (readonly,nonatomic) RelayrFirmware* firmware;

/*!
 *  @abstract The secret for MQTT comminucation with the relayr Cloud Platform
 *  @discussion Could be seen as the Device's password.
 */
@property (readonly,nonatomic) NSString* secret;

#pragma mark Subscription

/*!
 *  @abstract Subscribes the object target to all data (all inputs) sent from the <code>RelayrDevice</code>.
 *  @discussion It doesn't matter how the device is connected (Web/Cloud, Bluetooth, etc.), the caller of this method expects that the action is called on the target as soon as the data is available.
 *
 *  @param target The object where the <code>action</code> will be called onto.
 *  @param action The method to be called. It can have two modalities:
 *      - No parameters.
 *      - One parameter. The parameter must be a <code>RelayrInput</code> object, or this method will return a subscription error.
 *  @param subscriptionError Block executed if the subscription could not be performed (it can be <code>nil</code>. If you define this block, you must return a boolean indicating if you want to retry the subscription.
 *
 *  @see RelayrInput
 */
- (void)subscribeToAllInputsWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Subscribes the block to the data sent from the <code>RelayrDevice</code>.
 *  @discussion It doesn't matter how the device is connected (Web/Cloud, Bluetooth, etc.), the caller of this method expects that the action is called on the target as soon as the data is available.
 *
 *  @param block This block will be executed everytime data is available. The block contains three parameters:
 *      - <code>device</code>. The device that is reading the information.
 *      - <code>input</code>. The reading value received.
 *      - <code>unsubscribe</code>. Boolean pointer that when set to <code>NO</code>, will stop the subscription.
 *  @param subscriptionError Block executed if the subscription could not be performed (it can be <code>nil</code>. If you define this block, you must return a boolean indicating if you want to retry the subscription.
 *
 *  @see RelayrInput
 */
- (void)subscribeToAllInputsWithBlock:(void (^)(RelayrDevice* device, RelayrInput* input, BOOL* unsubscribe))block error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Unsubscribe the specific action of a target object.
 *  @discussion If a target object has more than one subscription with different actions, this unsubscribe method only affects to the actions being passed.
 *
 *  @param target The object where the subscription was being sent to.
 *  @param action The action being executed on the target every time information arrives.
 *
 *  @see RelayrInput
 */
- (void)unsubscribeTarget:(id)target action:(SEL)action;

/*!
 *  @abstract It removes all the subscriptions for this devices.
 *  @discussion All subscription, whether blocks or target objects are unsubscribe.
 */
- (void)removeAllSubscriptions;

@end
