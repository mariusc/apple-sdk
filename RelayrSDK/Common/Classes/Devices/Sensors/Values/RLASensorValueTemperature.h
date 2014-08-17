#import "RLASensorValue.h"  // Base class

/*!
 *  @class RLASensorValue
 *
 *  @abstract It provides the means to wrap raw sensor data in a domain object by defining a fixed set of methods for each sensor type.
 */
@interface RLASensorValueTemperature : RLASensorValue

/*!
 *  @property temperature
 *
 *  @abstract <code>NSNumber</code> value for the measured temperature.
 */
@property (readonly,nonatomic) NSNumber* temperature;

@end
