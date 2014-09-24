@import Foundation;     // Apple

/*!
 *  @abstract Specifies the basic functionality of a device.
 */
@interface RelayrFirmwareModel : NSObject <NSCoding>

/*!
 *  @abstract <code>NSString</code> representing the current version of the firmware.
 */
@property (readonly,nonatomic) NSString* version;

/*!
 *  @abstract <code>NSDictionary</code> incorporating all the properties of the current firmware.
 *  @discussion This dictionary includes all firmware properties, such as the Reading frequency.
 */
@property (readonly,nonatomic) NSDictionary* configuration;

/*!
 *  @abstract Sets the instance where this object is being called for, the properties of the object are passed as the arguments.
 *  @discussion The properties passed as the arguments are considered new and thus have a higher priority.
 *
 *  @param firmwareModel The newly <code>RelayrFirmwareModel</code> instance.
 */
- (void)setWith:(RelayrFirmwareModel*)firmwareModel;

@end
