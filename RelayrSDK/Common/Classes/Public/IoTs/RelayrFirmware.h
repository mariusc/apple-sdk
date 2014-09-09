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

/*!
 *  @abstract Queries the relayr platform for the current firmware properties.
 *  @discussion Every time this method is called a server query is launched.
 *	Once response is returned successfuly, all the <i>readonly</i> user related properties would be populated with respective values.
 *
 *  @param completion A block indiciating whether the server query was successful or not.
 *
 *  @see queryCloudForIoTs:
 */
- (void)queryCloudForProperties:(void (^)(NSError* error, BOOL isThereChanges))completion;

@end
