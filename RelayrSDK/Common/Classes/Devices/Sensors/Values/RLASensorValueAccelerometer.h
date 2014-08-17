#import "RLASensorValue.h"  // Base class

@interface RLASensorValueAccelerometer : RLASensorValue

/*!
 *  @property accelerationX
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSNumber* accelerationX;

/*!
 *  @property accelerationY
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSNumber* accelerationY;

/*!
 *  @property accelerationZ
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSNumber* accelerationZ;

@end
