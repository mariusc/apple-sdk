@import Foundation;

/*!
 *  @abstract It represents a firmware running into a <code>RelayrDevice</code> or <code>RelayrTransmitter</code>.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrFirmware : NSObject <NSCoding>

/*!
 *  @abstract <code>NSString</code> representing the current version of the firmware.
 *  @discussion It is usually a succession of three numbers separated by " (e.g.: 1.0.4)
 */
@property (readonly,nonatomic) NSString* version;

/*!
 *  @abstract <code>NSDictionary</code> with all the properties of the current firmware.
 *  @discussion This dictionary enumerates all the values the firmware consider important; such as the reading's frequency, etc.
 */
@property (readonly,nonatomic) NSDictionary* configuration;

@end
