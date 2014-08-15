#import "RLASensor.h"       // Relayr.framework
@class RLASensorValue;      // Relayr.framework
@protocol RLASensorDelegate;// Relayr.framework

/*!
 *  @class RLASensor
 *
 *  @abstract It gives the ability to set up values within a <code>RLASensor</code>.
 *
 *  @see RLASensor
 */
@interface RLASensor ()

/**
 * These values are fetched via relayr API for remote devices
 * and hardcoded for local devices
 * @param meaning NSString representation of the sensor meaning
 * @param unit NSString representation of the sensor unit
 */

- (instancetype)initWithMeaning:(NSString*)meaning
                        andUnit:(NSString*)unit;

/*!
 *  @property sensorValueClass
 *
 *  @abstract The value class that wraps the measured sensor data.
 */
@property (readonly,nonatomic) Class sensorValueClass;

/*!
 *  @property value
 *
 *  @abstract It populates the sensor object with measured data.
 */
@property (readwrite,nonatomic) RLASensorValue* value;

/*!
 *  @property delegate
 *
 *  @abstract This sole use of this delegate is to defer subscriptions of characteristics for the RLALocalDevice class until an observer really subscribes to updates
 *  @discussion This makes it possible to connect to a local device that is protected and fetch its services and characteristics without getting an error message.
 */
@property (readwrite,nonatomic) id <RLASensorDelegate> delegate;

@end
