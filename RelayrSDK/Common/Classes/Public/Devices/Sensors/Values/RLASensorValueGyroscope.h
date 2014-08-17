#import "RLASensorValue.h"  // Base class

/*!
 *  @class RLASensorValueGyroscope
 *
 *  @abstract ...
 */
@interface RLASensorValueGyroscope : RLASensorValue

/*!
 *  @property rotationX
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSNumber* rotationX;

/*!
 *  @property rotationY
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSNumber* rotationY;

/*!
 *  @property rotationZ
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSNumber* rotationZ;

@end
