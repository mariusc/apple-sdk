@class RelayrDevice;        // Relayr.framework (Public)
@class RelayrDeviceModel;   // Relayr.framework (Public)
@import Foundation;         // Apple

/*!
 *  @abstract References the type of reading a relayr Device (sensor) can collect.
 *  @discussion This object has a single 'meaning', however, This meaning could consist of one or more values. 
 *	For example: The Luminosity meaning is represented by a single value  
 *	however, the Color meaning consists of three or four values (red, green, blue, and white).
 */
@interface RelayrInput : NSObject <NSCoding>

/*!
 *  @abstract The device that this input/reading is coming from.
 *  @discussion This property will never be <code>nil</code>.
 */
@property (readonly,weak,nonatomic) RelayrDeviceModel* device;

/*!
 *  @abstract The name of the reading as it is defined on the relayr platform.
 */
@property (readonly,nonatomic) NSString* meaning;

/*!
 *  @abstract The unit in which the reading is measured.
 */
@property (readonly,nonatomic) NSString* unit;

/*!
 *  @abstract The last value received from the sensor. Either queried for or pushed.
 *  @discussion This object can be a single object entity (such as an <code>NSNumber</code> or an <code>NSString</code>) 
 *	or a collection: either a <code>NSArray</code> or an <code>NSDictionary</code>.
 */
@property (readonly,nonatomic) id value;

/*!
 *  @abstract The timestamp of the last value received.
 *  @discussion Can be seen as the 'last update' timestamp. 
 *	When <code>nil</code>, it means that a value has not yet been received or queried for.
 */
@property (readonly,nonatomic) NSDate* date;

/*!
 *  @abstract Returns an array with, the last 20 or less measurements (including the one in <code>value</code>).
 *  @discussion The array will contain 20  values or less. 
 *	The object type will be the same as the <code>value</code> property. 
 *	If an object could not be measured, but a timestamp was taken, the singleton [NSNull null] is stored in the array.
 */
@property (readonly,nonatomic) NSArray* historicValues;

/*!
 *  @abstract Array with, at top, the last 20 measurement times (including the current one in <code>date</code>).
 *  @discussion The array will contain 20 or less <code>NSDate</code> objects.
 */
@property (readonly,nonatomic) NSArray* historicDates;

/*!
 *  @abstract Subscribes the object target to data of the current input/reading sent from the parent <code>RelayrDevice</code>.
 *  @discussion It doesn't matter how the device is connected (Web/Cloud, Bluetooth, etc.), the caller of this method expects that the action is called on the target as soon as the data is available.
 *
 *  @param target The object where the <code>action</code> will be called onto.
 *  @param action The method to be called. It can have two modalities:
 *      - No parameters.
 *      - One parameter. The parameter must be a <code>RelayrInput</code> object, or this method will return a subscription error.
 *  @param subscriptionError Block executed if the subscription could not be performed (it can be <code>nil</code>. If you define this block, you must return a boolean indicating if you want to retry the subscription.
 */
- (void)subscribeWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Subscribes the block to the data of this input/reading sent from the parent <code>RelayrDevice</code>.
 *  @discussion It doesn't matter how the device is connected (Web/Cloud, Bluetooth, etc.), the caller of this method expects that the action is called on the target as soon as the data is available.
 *
 *  @param block This block will be executed everytime data is available. The block contains three parameters:
 *      - <code>device</code>. The device that is reading the information.
 *      - <code>input</code>. The reading value received.
 *      - <code>unsubscribe</code>. Boolean pointer that when set to <code>NO</code>, will stop the subscription.
 *  @param subscriptionError Block executed if the subscription could not be performed (it can be <code>nil</code>. If you define this block, you must return a boolean indicating if you want to retry the subscription.
 */
- (void)subscribeWithBlock:(void (^)(RelayrDevice* device, RelayrInput* input, BOOL* unsubscribe))block error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Unsubscribe the specific action of a target object.
 *  @discussion If a target object has more than one subscription with different actions, this unsubscribe method only affects to the actions being passed.
 *
 *  @param target The object where the subscription was being sent to.
 *  @param action The action being executed on the target every time information arrives.
 */
- (void)unsubscribeTarget:(id)target action:(SEL)action;

/*!
 *  @abstract It removes all the subscriptions for this input.
 *  @discussion All subscription, whether blocks or target objects are unsubscribe.
 */
- (void)removeAllSubscriptions;

@end
