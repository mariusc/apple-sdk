#import "RLASensorValue.h"      // Base class

/*!
 *  @class RLASensorValueNoise
 *
 *  @abstract It provides the means to wrap raw sensor data in a domain object by defining a fixed set of methods for each sensor type.
 */
@interface RLASensorValueNoise : RLASensorValue

/*!
 *  @property noiseLevel
 *
 *  @abstract <code>NSNumber</code> value for the measured noise level.
 */
@property (readonly,nonatomic) NSNumber* noiseLevel;

@end
