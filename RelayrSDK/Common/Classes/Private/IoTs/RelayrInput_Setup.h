#import "RelayrInput.h"

/*!
 *  @abstract It references a type of reading that a Relayr device (sensor) can perform.
 *  @discussion This object have a single meaning, but can take more than one value. For example: luminosity (meaning) reads a single value (in lumens); however, color (meaning) reads three or four values (red, green, blue, and maybe alpha).
 */
@interface RelayrInput ()

/*!
 *  @abstract Designated initialiser for <code>RelayrInput</code> objects.
 *
 *  @param meaning Relayr identifier for the type of input you are receiving.
 *	@return Fully initialised <code>RelayrInput</code> object or <code>nil</code> if there were problems.
 */
- (instancetype)initWithMeaning:(NSString*)meaning;

/*!
 *  @abstract Array with, at top, the last 20 measurements (including the current one in <code>value</code>).
 *  @discussion The array will contain 20 or less values. The object type will be the same as the <code>value</code> property. If an object could not be measured, but the time was taken, the singleton [NSNull null] will be stored in the array.
 */
@property (readwrite,nonatomic) NSMutableArray* values;

/*!
 *  @abstract Returns an array with, the last 20 or less measurements (including the current one in <code>unit</code>).
 *  @discussion The array will contain 20 units or less <code>NSString</code> objects.
 */
@property (readwrite,nonatomic) NSMutableArray* units;

/*!
 *  @abstract Array with, at top, the last 20 measurement times (including the current one in <code>date</code>).
 *  @discussion The array will contain 20 or less <code>NSDate</code> objects.
 */
@property (readwrite,nonatomic) NSMutableArray* dates;

@end
