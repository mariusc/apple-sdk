#import "RelayrTransmitter.h"   // Relayr.framework (Public)
@class RelayrUser;              // Relayr.framework (Public)

/*!
 *  @abstract An instance of this class represents a Relayr Transmitter.
 *  @discussion A Relayr transmitter usually represent a connected device that perform the functions of router, gateway, etc.
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
 *  @abstract The given name of the transmitter.
 *  @discussion It can be changed by server calls.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract Owner ID of this transmitter.
 */
@property (readwrite,nonatomic) NSString* owner;

/*!
 *  @abstract All the devices associated with this transmitter.
 *  @discussion All are weak links to <code>RelayrDevice</code>s owned by the <code>RelayrUser</code>.
 */
@property (readwrite,nonatomic) NSArray* devices;

@end
