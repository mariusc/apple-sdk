@import Foundation;

/*!
 *  @abstract Represents the firmware running on a <code>RelayrDevice</code> or a <code>RelayrTransmitter</code>.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrFirmware : NSObject <NSCoding>

/*!
 *  @abstract <code>NSString</code> representing the current version of the firmware.
 */
@property (readonly,nonatomic) NSString* version;

/*!
 *  @abstract <code>NSDictionary</code> incorporating all the properties of the current firmware.
 *  @discussion This dictionary includes all values considered important such as the Reading frequency.
 */
@property (readonly,nonatomic) NSDictionary* configuration;

@end
