#import "RelayrDeviceModel.h"    // Relayr.framework (Public)

/*!
 *  @abstract An instance of this class represents a Device. A basic relayr entity
 *	@discussion A device is any external entity capable of producing measurements and sending them to a transmitter to be further sent to the relayr cloud,
 *	or one which is capable of receiving information from the relayr platform.
 *	Examples would be a thermometer, a gyroscope or an infrared sensor.
 */
@interface RelayrDeviceModel ()

/*!
 *  @abstract It initialises a Transmitter with a Relayr ID and an MQTT secret/password.
 *  @discussion Both arguments must be valid <code>NSString</code>s.
 *
 *  @param modelID Relayr model identifier. It identifies the device (independently of the firmware version).
 *  @param modelName Name for the Relayr Device-Model.
 *	@return Fully instanciate <code>RelayrDeviceModel</code> or <code>nil</code>
 *
 *  @see RelayrDevice
 */
- (instancetype)initWithModelID:(NSString*)modelID modelName:(NSString*)modelName;

/*!
 *  @abstract The manufacturer of the device.
 */
@property (readwrite,nonatomic) NSString* manufacturer;

/*!
 *  @abstract Indicates firmware attributes of the Device instance being called.
 *  @discussion You can request the current version and other firmware properties.
 */
@property (readwrite,nonatomic) RelayrFirmwareModel* firmware;

/*!
 *  @abstract Returns an array of all possible readings the device can gather.
 *  @discussion Each item in this array is an object of type <code>RelayrInput</code>. Each input represents a different kind of reading. That is, a <code>RelayrDevice</code> can have a luminosity sensor and a gyroscope; thus, this array would have two different inputs.
 *
 *  @see RelayrInput
 */
@property (readwrite,nonatomic) NSSet* inputs;

/*!
 *  @abstract Returns an array of possible Outputs a Device is capable of receiving.
 *  @discussion By 'Output' we refer to an object with commands or configuration settings sent to a Device.
 *	These are usually infrarred commands, ultrasound pulses etc.
 *	Each item in this array is an object of type <code>RelayrOutput</code>.
 *
 *  @see RelayrOutput
 */
@property (readwrite,nonatomic) NSSet* outputs;

@end
