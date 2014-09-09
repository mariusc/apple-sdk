@import Foundation;

/*!
 *  @abstract References the type of reading a relayr Device (sensor) can collect.
 *  @discussion This object has a single 'meaning', however, This meaning could consist of one or more values. 
 *	For example: The Luminosity meaning is represented by a single value  
 *	however, the Color meaning consists of three or four values (red, green, blue, and white).
 */
@interface RelayrInput : NSObject <NSCoding>

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

@end
