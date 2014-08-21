#import "RLASensorValue.h"  // Base class

/*!
 *  @class RLASensorValueProximity
 *
 *  @abstract ...
 */
@interface RLASensorValueProximity : RLASensorValue

/*!
 *  @property proximity
 *
 *  @abstract <code>NSNumber</code> representing the proximity to the sensor.
 *  @discussion The bigger the number the closer the object is to the sensor.
 */
@property (readonly,nonatomic) NSNumber* proximity;

@end
