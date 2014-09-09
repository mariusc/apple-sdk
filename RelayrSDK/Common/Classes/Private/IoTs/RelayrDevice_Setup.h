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
 *	@return Fully instanciate <code>RelayrTransmitter</code> or <code>nil</code>
 *
 *  @see RelayrDevice
 */
- (instancetype)initWithID:(NSString*)uid secret:(NSString*)secret;

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
 *  @abstract Indicates wheather the data gathered by the device is public (available to all users) or not (available to the Device owner only).
 *  @discussion An <code>NSNumber</code> wrapping a boolean value (use <code>.boolValue</code> to unwrap it).
 */
@property (readwrite,nonatomic) NSNumber* isPublic;

@end
