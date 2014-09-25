#import "RelayrFirmwareModel.h" // Relayr.framework (Public)

/*!
 *  @abstract An instance of this class models how a firmware should look and perform.
 */
@interface RelayrFirmwareModel ()

/*!
 *  @abstract Designated initialiser for the <code>RelayrFirmwareModel</code> objects.
 *
 *  @param version <code>NSString</code> representing the version of the firmware.
 *	@return Fully initialised <code>RelayrFirmwareModel</code> object or <code>nil</code> if there were problems.
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
@property (readwrite,nonatomic) NSMutableDictionary* configuration;

/*!
 *  @abstract Sets the instance where this object is being called for, the properties of the object are passed as the arguments.
 *  @discussion The properties passed as the arguments are considered new and thus have a higher priority.
 *
 *  @param firmwareModel The newly <code>RelayrFirmwareModel</code> instance.
 */
- (void)setWith:(RelayrFirmwareModel*)firmwareModel;

@end
