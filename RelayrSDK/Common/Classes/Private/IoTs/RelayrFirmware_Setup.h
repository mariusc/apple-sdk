#import "RelayrFirmware.h"              // Relayr.framework (Public)
#import "RelayrFirmwareModel_Setup.h"   // Relayr.framework (Private)

/*!
 *  @abstract Represents the firmware running on a <code>RelayrDevice</code> or a <code>RelayrTransmitter</code>.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrFirmware ()

/*!
 *  @abstract Sets the instance where this object is being called onto, with the properties of the object passed as the argument.
 *  @discussion The object passed as the argument is considered new and thus the properties have more priority.
 *
 *  @param firmware The newly <code>RelayrFirmware</code> instance.
 */
- (void)setWith:(RelayrFirmware*)firmware;

@end
