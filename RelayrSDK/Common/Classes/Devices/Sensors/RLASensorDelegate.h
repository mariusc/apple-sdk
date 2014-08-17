@import Foundation;
@class RLASensor;

/*!
 *  @protocol It provides the means to monitor how many observers are attached to a sensor.
 */
@protocol RLASensorDelegate <NSObject>

@required
/*!
 *  @method sensorDidAddObserver:
 *
 *  @abstract ...
 *
 *  @param sensor <code>RLASensor</code> that the observer don't want to "observe" anymore.
 *
 *  @see RLASensor
 */
- (void)sensorDidAddObserver:(RLASensor*)sensor;

@required
/*!
 *  @method sensorDidRemoveObserver:
 *
 *  @abstract ...
 *
 *  @param sensor <code>RLASensor</code> that the observer don't want to "observe" anymore.
 *
 *  @see RLASensor
 */
- (void)sensorDidRemoveObserver:(RLASensor*)sensor;

@end
