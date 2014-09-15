#import "RelayrDevice.h"    // Relayr.framework (Public)

/*!
 *  @abstract An instance of this class represents a Device. A basic relayr entity
 *	@discussion A device is any external entity capable of producing measurements and sending them to a transmitter to be further sent to the relayr cloud,
 *	or one which is capable of receiving information from the relayr platform.
 *	Examples would be a thermometer, a gyroscope or an infrared sensor.
 */
@interface RelayrDevice ()

/*!
 *  @abstract It initialises a Transmitter with a Relayr ID and an MQTT secret/password.
 *  @discussion Both arguments must be valid <code>NSString</code>s.
 *
 *  @param uid Relayr ID that identifies uniquely the transmitter within the Relayr cloud.
 *  @param secret MQTT password.
 *  @param modelID Relayr model identifier. It identifies the device (independently of the firmware version).
 *	@return Fully instanciate <code>RelayrTransmitter</code> or <code>nil</code>
 *
 *  @see RelayrDevice
 */
- (instancetype)initWithID:(NSString*)uid secret:(NSString*)secret modelID:(NSString*)modelID;

/*!
 *  @abstract Device name.
 *  @discussion Can be updated using a server call.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract The Id of the owner of the Device.
 *  @discussion A relayr User Id.
 */
@property (readwrite,nonatomic) NSString* owner;

/*!
 *  @abstract The manufacturer of the device.
 */
@property (readwrite,nonatomic) NSString* manufacturer;

/*!
 *  @abstract Indicates wheather the data gathered by the device is public (available to all users) or not (available to the Device owner only).
 *  @discussion An <code>NSNumber</code> wrapping a boolean value (use <code>.boolValue</code> to unwrap it).
 */
@property (readwrite,nonatomic) NSNumber* isPublic;

/*!
 *  @abstract Indicates firmware attributes of the Device instance being called.
 *  @discussion You can request the current version and other firmware properties.
 */
@property (readwrite,nonatomic) RelayrFirmware* firmware;

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
