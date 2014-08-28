//#import "RelayrUser.h"          // Header
@class RLAWebService;           // Relayr.framework (Web)

/*!
 *  @class RelayrUser
 *
 *  @abstract Private extension to setup <code>RelayrUser</code> properties.
 *  @discussion These methods and properties are only accessible for the objects that initialises <code>RelayrUser</code>.
 *
 *  @see RelayrUser
 */
@interface RelayrUser ()

/*!
 *  @method initWithToken:
 *
 *  @abstract It initialises a <code>RelayrUser</code> with a specific OAuth token. The common initialiser <code>-init:</code> is not accepted.
 *  @discussion If <code>token</code> is <code>nil</code> or not valid, this initialiser returns <code>nil</code>.
 *
 *  @param token OAuth token for the Relayr cloud queries.
 *	@return Fully initialised <code>RelayrUser</code>.
 */
- (instancetype)initWithToken:(NSString*)token;

/*!
 *  @property webService
 *
 *  @abstract This is the central connection with the Relayr.framework web module.
 *  @discussion It is never <code>nil</code>. When an instance of <code>RelayrUser</code> is created, this property is setup to a valid web service.
 */
@property (readonly,nonatomic) RLAWebService* webService;

/*!
 *  @property uid
 *
 *  @abstract Relyar idenfier for the <code>RelayrUser</code>'s instance.
 */
@property (readwrite,nonatomic) NSString* uid;

/*!
 *  @property name
 *
 *  @abstract Relayr user name for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @property email
 *
 *  @abstract Relayr user email for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSString* email;

/*!
 *  @property apps
 *
 *  @abstract Relayr applications for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* apps;

/*!
 *  @property transmitter
 *
 *  @abstract Transmitter that this <code>RelayrUser</code>'s instace owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* transmitter;

/*!
 *  @property devices
 *
 *  @abstract Devices that this <code>RelayrUser</code>'s instace owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* devices;

/*!
 *  @property devicesBookmarked
 *
 *  @abstract Favorite devices that this <code>RelayrUser</code>'s instace have bookmarked.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* devicesBookmarked;

/*!
 *  @property publishers
 *
 *  @abstract How many <code>publisher</code>s have the Relayr user owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* publishers;

@end
