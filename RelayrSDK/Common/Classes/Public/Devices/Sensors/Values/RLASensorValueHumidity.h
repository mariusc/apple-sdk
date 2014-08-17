#import "RLASensorValue.h"  // Base class

/*!
 *  @class RLASensorValueHumidity
 *
 *  @abstract It provides the means to wrap raw sensor data in a domain object by defining a fixed set of methods for each sensor type.
 */
@interface RLASensorValueHumidity : RLASensorValue

/*!
 *  @property humidity
 *
 *  @abstract <code>NSNumber</code> value for the measured humidity.
 */
@property (readonly,nonatomic) NSNumber* humidity;

@end
