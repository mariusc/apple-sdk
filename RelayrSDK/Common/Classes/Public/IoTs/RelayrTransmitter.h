@class RelayrUser;      // Relayr.framework (Public)
@import Foundation;     // Apple

/*!
 *  @abstract An instance of this class represents a relayr Transmitter. a basic entity on the relayr platform.
 *  @discussion A transmitter contrary to a device does not gather data but is only used to relay the data from the 
 *	devices to the relayr platform. The transmitter is also used to authenticate the different devices that transmit data via it.
 */
@interface RelayrTransmitter : NSObject <NSCoding>

/*!
 *  @abstract A Unique idenfier for a <code>RelayrTransmitter</code> instance.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract Transmitter name.
 *  @discussion Can be updated on the server.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract The owner ID of the specific transmitter, a relayr user.
 */
@property (readonly,nonatomic) NSString* owner;

/*!
 *  @abstract Returns an array with all devices related to the specific Transmitter.
 *  @discussion Links to <code>RelayrDevice</code>s owned by the <code>RelayrUser</code> which owns the Transmitter.
 */
@property (readonly,nonatomic) NSArray* devices;

/*!
 *  @abstract The secret for MQTT comminucation with the relayr <a href="https://developer.relayr.io/documents/Welcome/Platform">Cloud Platform</a>.
 *  @discussion Could be seen as the transmitter's password.
 */
@property (readonly,nonatomic) NSString* secret;

@end
