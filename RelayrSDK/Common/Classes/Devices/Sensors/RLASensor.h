@import Foundation;
@class RLASensorValue;

#pragma mark Units

static NSString* const kRLASensorUnitCelsius = @"celsius";
static NSString* const kRLASensorUnitFahrenheit = @"fahrenheit";

#pragma mark Meanings

static NSString* const kRLASensorMeaningUndefined    = @"undefined";
static NSString* const kRLASensorMeaningProximity    = @"proximity";
static NSString* const kRLASensorMeaningColor        = @"color";
static NSString* const kRLASensorMeaningLight        = @"light";
static NSString* const kRLASensorMeaningLuminosity   = @"luminosity";
static NSString* const kRLASensorMeaningGyroscope    = @"angular_speed";
static NSString* const kRLASensorMeaningAcceleration = @"acceleration";
static NSString* const kRLASensorMeaningHumidity     = @"humidity";
static NSString* const kRLASensorMeaningTemperature  = @"temperature";
static NSString* const kRLASensorMeaningNoiseLevel   = @"noise_level";

/*!
 *  @class RLASensor
 *
 *  @abstract It provides means to access information about a sensor and its data.
 */
@interface RLASensor : NSObject

/*!
 *  @property meaning
 *
 *  @abstract <code>NSString</code> representing the sensor meaning.
 */
@property (readonly,nonatomic) NSString* meaning;

/*!
 *  @property unit
 *
 *  @abstract <code>NSString</code> representing the sensor unit.
 */
@property (readonly,nonatomic) NSString* unit;

/*!
 *  @property value
 *
 *  @abstract Current measured value of the sensor.
 *  @discussion Each <code>RLASensor</code> subclass is responsible for overriding this method and returning an appropriate value.
 */
@property (readonly,nonatomic) RLASensorValue* value;

@end
