#import "RelayrTransmitter.h"   // Relayr.framework (Public)

/*!
 *  @abstract An instance of this class represents a relayr Transmitter. a basic entity on the relayr platform.
 *  @discussion A transmitter contrary to a device does not gather data but is only used to relay the data from the
 *	devices to the relayr platform. The transmitter is also used to authenticate the different devices that transmit data via it.
 */
@interface RelayrTransmitter ()

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
 *  @abstract Transmitter name.
 *  @discussion Can be updated on the server.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract The owner ID of the specific transmitter, a relayr user.
 */
@property (readwrite,nonatomic) NSString* owner;

/*!
 *  @abstract Returns an array with all devices related to the specific Transmitter.
 *  @discussion Links to <code>RelayrDevice</code>s owned by the <code>RelayrUser</code> which owns the Transmitter.
 */
@property (readwrite,nonatomic) NSArray* devices;

@end
