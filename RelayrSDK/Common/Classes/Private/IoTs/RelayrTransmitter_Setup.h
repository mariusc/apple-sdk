#import "RelayrTransmitter.h"   // Relayr.framework (Public)

/*!
 *  @abstract An instance of this class represents a relayr Transmitter. a basic entity on the relayr platform.
 *  @discussion A transmitter contrary to a device does not gather data but is only used to relay the data from the
 *	devices to the relayr platform. The transmitter is also used to authenticate the different devices that transmit data via it.
 */
@interface RelayrTransmitter ()

/*!
 *  @abstract It initialises a Transmitter with a Relayr ID.
 *
 *  @param uid Relayr ID that identifies uniquely the transmitter within the Relayr cloud.
 *	@return Fully instanciate <code>RelayrTransmitter</code> or <code>nil</code>
 *
 *  @see RelayrDevice
 */
- (instancetype)initWithID:(NSString*)uid;

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
 *  @abstract The secret for MQTT comminucation with the relayr <a href="https://developer.relayr.io/documents/Welcome/Platform">Cloud Platform</a>.
 *  @discussion Could be seen as the transmitter's password.
 */
@property (readwrite,nonatomic) NSString* secret;

/*!
 *  @abstract Returns all devices related to the specific Transmitter.
 *  @discussion Links to <code>RelayrDevice</code>s owned by the <code>RelayrUser</code> which owns the Transmitter.
 */
@property (readwrite,nonatomic) NSSet* devices;

/*!
 *  @abstract It sets the instance where this object is being called with the properties of the object passed as the argument.
 *  @discussion The object passed as the argument is considered new and thus the properties have more priority.
 *
 *  @param transmitter The server instance of this object.
 */
- (void)setWith:(RelayrTransmitter*)transmitter;

@end
