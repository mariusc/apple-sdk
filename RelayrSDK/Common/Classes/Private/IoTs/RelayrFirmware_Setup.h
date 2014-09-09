#import "RelayrFirmware.h"      // Relayr.framework (Public)

/*!
 *  @abstract Represents the firmware running on a <code>RelayrDevice</code> or a <code>RelayrTransmitter</code>.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrFirmware ()

/*!
 *  @abstract Designated initialiser for the <code>RelayrFirmware</code> objects.
 *
 *  @param version <code>NSString</code> representing the version of the firmware.
 *	@return Fully initialised <code>RelayrFirmware</code> object or <code>nil</code> if there were problems.
 */
- (instancetype)initWithVersion:(NSString*)version;

/*!
 *  @abstract <code>NSString</code> representing the current version of the firmware.
 */
@property (readwrite,nonatomic) NSString* version;

/*!
 *  @abstract <code>NSDictionary</code> incorporating all the properties of the current firmware.
 *  @discussion This dictionary includes all values considered important such as the Reading frequency.
 */
@property (readwrite,nonatomic) NSMutableDictionary* properties;

@end
