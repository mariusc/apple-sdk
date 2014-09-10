#import "RelayrConnection"      // Relayr.framework (Public)

/*!
 *  @abstract It express the type of connection between the current platform and the device or transmitter.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrConnection ()

/*!
 *  @abstract Which device is this connection associated to.
 */
@property (readwrite,weak,nonatomic) RelayrDevice* device;

/*!
 *  @abstract The connection technology we are using right now.
 */
@property (readwrite,nonatomic) RelayrConnectionType type;

@end
