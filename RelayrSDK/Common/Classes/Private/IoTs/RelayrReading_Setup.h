#import "RelayrReading.h"     // Parent class

/*!
 *  @abstract It references a type of reading that a Relayr device (sensor) can perform.
 *  @discussion This object have a single meaning, but can take more than one value. For example: luminosity (meaning) reads a single value (in lumens); however, color (meaning) reads three or four values (red, green, blue, and maybe alpha).
 */
@interface RelayrReading () <NSCoding>

/*!
 *  @abstract Designated initialiser for <code>RelayrReading</code> objects.
 *
 *  @param meaning Relayr identifier for the type of input you are receiving.
 *	@return Fully initialised <code>RelayrReading</code> object or <code>nil</code> if there were problems.
 */
- (instancetype)initWithMeaning:(NSString*)meaning unit:(NSString*)unit;

/*!
 *  @abstract The device that this input/reading is coming from.
 *  @discussion This property will never be <code>nil</code>.
 */
@property (readwrite,weak,nonatomic) RelayrDeviceModel* deviceModel;

/*!
 *  @abstract Array with, at top, the last 20 measurements (including the current one in <code>value</code>).
 *  @discussion The array will contain 20 or less values. The object type will be the same as the <code>value</code> property. If an object could not be measured, but the time was taken, the singleton [NSNull null] will be stored in the array.
 */
@property (readwrite,nonatomic) NSMutableArray* values;

/*!
 *  @abstract Array with, at top, the last 20 measurement times (including the current one in <code>date</code>).
 *  @discussion The array will contain 20 or less <code>NSDate</code> objects.
 */
@property (readwrite,nonatomic) NSMutableArray* dates;

/*!
 *  @abstract Sets the instance where this object is being called for, with the properties of the object being passed as arguments.
 *  @discussion The properties being passed as the arguments are considered new and thus have a higher priority.
 *
 *  @param input The newly <code>RelayrReading</code> instance.
 */
- (void)setWith:(RelayrReading*)input;

/*!
 *  @abstract Dictionary containing all the subscription blocks.
 *  @discussion The dictionary contains as keys the subscription block, and as values the error blocks.
 */
@property (readwrite,nonatomic) NSMutableDictionary* subscribedBlocks;

/*!
 *  @abstract Dictionary containing all the subscription pairs (target-action).
 *  @discussion The dictionary contains as keys the RLATargetAction objects, and as values the error blocks.
 */
@property (readwrite,nonatomic) NSMutableDictionary* subscribedTargets;

/*!
 *  @abstract If an error is issue in a data subscription mechanism, this method is called with the specific error being passed.
 *  @discussion This method transmit the error to all the subscribers and unsubscribe all of them.
 *
 *  @param error <code>NSError</code> explaining the problem that happened.
 *  @param date Time that the eror happened.
 */
- (void)errorReceived:(NSError*)error atDate:(NSDate*)date;

/*!
 *  @abstract This method is called everytime a value is received from any of the data source services (MQTT, BLE, etc.).
 *  @discussion The <code>value</code> parameter can be any value type that allows the <code>NSCopying</code> protocol. If this parameter is not an error, then a date must be given or the method won't perform any work.
 *
 *  @param value Object defining the value received.
 *  @param date <code>NSDate</code> with the date of arrival of the value received.
 */
- (void)valueReceived:(NSObject <NSCopying> *)value atDate:(NSDate*)date;

@end
