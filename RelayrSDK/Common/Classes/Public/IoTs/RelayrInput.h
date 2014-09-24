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
 *  @abstract Returns an array with the last 20 or less measurements (including the one in <code>value</code>).
 *  @discussion The array will contain 20  values or less. 
 *	The object type will be the same as the <code>value</code> property. 
 *	If an object could not be measured, but a timestamp was taken, the singleton [NSNull null] is stored in the array.
 */
@property (readonly,nonatomic) NSArray* historicValues;

/*!
 *  @abstract Returns an array with the last 20 measurement times or less (including the current one in <code>date</code>).
 *  @discussion The array will contain 20 or less <code>NSDate</code> objects.
 */
@property (readonly,nonatomic) NSArray* historicDates;

/*!
 *  *  @abstract Subscribes the target object to all data (all readings) sent from the <code>RelayrDevice</code>.
 *  @discussion Regardless of how the device is connected (Web/Cloud, Bluetooth, etc.), 
 *	The action is called as soon as the data is available.
 *
 *  @param target The object where the <code>action</code> is called onto.
 *  @param action The method to be called. It can have two modes:
 *      - No parameters.
 *      - One parameter. The parameter must be a <code>RelayrInput</code> object, otherwise this method will return a subscription error.
 *  @param subscriptionError A Block executed if the subscription cannot be performed (it can be <code>nil</code>. 
 *	If this block is defined, a boolean must be returned, indicating if a subscription retry should be attempted.
 */
- (void)subscribeWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Subscribes a block to the data sent from the <code>RelayrDevice</code>.
 *  @discussion Regardless of how the device is connected (Web/Cloud, Bluetooth, etc.), 
 *	The action is called as soon as the data is available.
 *
 *  @param block This block will be executed everytime data is available. The block contains three parameters:
 *      - <code>device</code>. The device producing the reading.
 *      - <code>input</code>. The reading value received.
 *      - <code>unsubscribe</code>. A Boolean variable, that when set to <code>NO</code>, will stop the subscription.
 *  @param subscriptionError A Block executed if the subscription cannot be performed (it can be <code>nil</code>. 
 *	If this block is defined, a boolean must be returned, indicating if a subscription retry should be attempted.
 */
- (void)subscribeWithBlock:(void (^)(RelayrDevice* device, RelayrInput* input, BOOL* unsubscribe))block error:(BOOL (^)(NSError* error))subscriptionError;

/*!
 *  @abstract Unsubscribes the specific action from the target object.
 *  @discussion If a target object has more than one subscription with different actions, 
 *	this unsubscribe method only affects the actions being passed.
 *
 *  @param target The object where the subscription is being sent to.
 *  @param action The action being executed on the target each time readings arrives.
 */
- (void)unsubscribeTarget:(id)target action:(SEL)action;

/*!
 *  @abstract Removes all subscriptions for this devices.
 *  @discussion All subscriptions, whether blocks or target objects are unsubscribed.
 */
- (void)removeAllSubscriptions;

@end
