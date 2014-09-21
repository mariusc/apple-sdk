@import Foundation;     // Apple

/*!
 *  @abstract It specifies the minimum functionality of a device.
 */
@interface RelayrFirmwareModel : NSObject <NSCoding>

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
 *  @abstract Sets the instance where this object is being called onto, with the properties of the object passed as the argument.
 *  @discussion The object passed as the argument is considered new and thus the properties have more priority.
 *
 *  @param firmwareModel The newly <code>RelayrFirmwareModel</code> instance.
 */
- (void)setWith:(RelayrFirmwareModel*)firmwareModel;

@end
