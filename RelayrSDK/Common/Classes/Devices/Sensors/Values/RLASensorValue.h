@import Foundation;

/*!
 *  @class RLASensorValue
 *
 *  @abstract It provides means to read values measured by a sensor.
 *
 *  @see RLASensor
 */
@interface RLASensorValue : NSObject

/*!
 *  @property timestamp
 *
 *  @abstract <code>NSDate</code> value indicating the time the measurement was taken.
 */
@property (readonly,nonatomic) NSDate* timestamp;

/*!
 *  @property dictionary
 *
 *  @abstract Raw key/value data as returned from remote source.
 */
@property (readonly,nonatomic) NSDictionary* dictionary;

@end
