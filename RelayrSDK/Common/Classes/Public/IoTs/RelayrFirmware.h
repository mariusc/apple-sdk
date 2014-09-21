#import "RelayrFirmwareModel.h" // Relayr.framework (Public)
@import Foundation;             // Apple

/*!
 *  @abstract Represents the firmware running on a <code>RelayrDevice</code> or a <code>RelayrTransmitter</code>.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrFirmware : RelayrFirmwareModel <NSCoding>

/*!
 *  @abstract Sets the instance where this object is being called onto, with the properties of the object passed as the argument.
 *  @discussion The object passed as the argument is considered new and thus the properties have more priority.
 *
 *  @param firmware The newly <code>RelayrFirmware</code> instance.
 */
- (void)setWith:(RelayrFirmware*)firmware;

/*!
 *  @abstract Queries the relayr platform for the current firmware properties.
 *  @discussion Every time this method is called a server query is launched.
 *	Once response is returned successfuly, all the <i>readonly</i> user related properties would be populated with respective values.
 *
 *  @param completion A block indiciating whether the server query was successful or not.
 *
 *  @see queryCloudForIoTs:
 */
- (void)queryCloudForProperties:(void (^)(NSError* error, NSNumber* isThereChanges))completion;

@end
