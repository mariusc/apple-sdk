@import Foundation;

/*!
 *  @abstract It references a type of reading that a Relayr device (sensor) can perform.
 *  @discussion This object have a single meaning, but can take more than one value. For example: luminosity (meaning) reads a single value (in lumens); however, color (meaning) reads three or four values (red, green, blue, and maybe alpha).
 */
@interface RelayrInput : NSObject <NSCoding>

/*!
 *  @abstract How the "reading"/input is identified in the Relayr Cloud.
 */
@property (readonly,nonatomic) NSString* meaning;

/*!
 *  @abstract How the unit use to scale the input is identified in the Realyr Cloud.
 */
@property (readonly,nonatomic) NSString* unit;

/*!
 *  @abstract The last value received or queried from the sensor.
 *  @discussion This object can be a single object entity (such as <code>NSNumber</code> or <code>NSString</code>) or it can be a collection (whether a <code>NSArray</code> or <code>NSDictionary</code>).
 */
@property (readonly,nonatomic) id value;

/*!
 *  @abstract The time the last value was taken.
 *  @discussion You can see it as the time this instance was updated. When <code>nil</code>, it means this object has been never updated.
 */
@property (readonly,nonatomic) NSDate* date;

/*!
 *  @abstract Array with, at top, the last 20 measurements (including the current one in <code>value</code>).
 *  @discussion The array will contain 20 or less values. The object type will be the same as the <code>value</code> property. If an object could not be measured, but the time was taken, the singleton [NSNull null] will be stored in the array.
 */
@property (readonly,nonatomic) NSArray* historicValues;

/*!
 *  @abstract Array with, at top, the last 20 measurement times (including the current one in <code>date</code>).
 *  @discussion The array will contain 20 or less <code>NSDate</code> objects.
 */
@property (readonly,nonatomic) NSArray* historicDates;

@end
