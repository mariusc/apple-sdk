#import "RelayrInput.h"     // Relayr.framework (Public)

/*!
 *  @abstract It references a type of writing/output that a Relayr device (sensor) can perform.
 *  @discussion This object have a single meaning, but can take more than one value. For example: luminosity (meaning) reads a single value (in lumens); however, color (meaning) reads three or four values (red, green, blue, and maybe alpha).
 */
@interface RelayrOutput ()

/*!
 *  @abstract Designated initialiser for <code>RelayrOutput</code> objects.
 *
 *  @param meaning Relayr identifier for the type of output you are sending to the device (sensor).
 *	@return Fully initialised <code>RelayrOutput</code> object or <code>nil</code> if there were problems.
 */
- (instancetype)initWithMeaning:(NSString*)meaning;

/*!
 *  @abstract The device that this output/writing is coming from.
 *  @discussion This property will never be <code>nil</code>.
 */
@property (readwrite,weak,nonatomic) RelayrDeviceModel* device;

@end
