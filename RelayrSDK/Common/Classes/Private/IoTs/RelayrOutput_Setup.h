#import "RelayrOutput.h"    // Parent class

/*!
 *  @abstract It references a type of writing/output that a Relayr device (sensor) can perform.
 *  @discussion This object have a single meaning, but can take more than one value. For example: luminosity (meaning) reads a single value (in lumens); however, color (meaning) reads three or four values (red, green, blue, and maybe alpha).
 */
@interface RelayrOutput () <NSCoding>

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
@property (readwrite,weak,nonatomic) RelayrDeviceModel* deviceModel;

/*!
 *  @abstract Sets the instance where this object is being called for, with the properties of the object being passed as arguments.
 *  @discussion The properties being passed as the arguments are considered new and thus have a higher priority.
 *
 *  @param output The newly <code>RelayrOutput</code> instance.
 */
- (void)setWith:(RelayrOutput*)output;

@end
