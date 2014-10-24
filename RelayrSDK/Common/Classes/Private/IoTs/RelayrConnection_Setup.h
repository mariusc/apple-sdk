#import "RelayrConnection.h"    // Relayr.framework (Public)
@class RelayrDevice;            // Relayr.framework (Public)

/*!
 *  @abstract It express the type of connection between the current platform and the device or transmitter.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrConnection ()

/*!
 *  @abstract Designated initialiser for the a <code>RelayrConnection</code> object.
 *  @discussion This initialiser will return <code>nil</code> when the device is not a full-fledge <code>RelayrDevice</code> object.
 *
 *  @param device <code>RelayrDevice</code> <i>owning</i> the connection.
 *  @return Fully initialised <code>RelayrConnection</code> object or <code>nil</code>.
 */
- (instancetype)initWithDevice:(RelayrDevice*)device;

/*!
 *  @abstract Whether the connection is through the cloud or is directly performed with the device.
 */
@property (readwrite,nonatomic) RelayrConnectionType type;

/*!
 *  @abstract Protocol being used by the connection between the device's data source and the system running the SDK.
 */
@property (readwrite,nonatomic) RelayrConnectionProtocol protocol;

/*!
 *  @abstract The state of the current connection type.
 */
@property (readwrite,nonatomic) RelayrConnectionState state;

@end
