#import "RelayrUser.h"          // Header
@class RLAWebService;           // Relayr.framework (Web)

/*!
 *  @abstract The very basic entity in the relayr platform is the user.
 *	@discussion Every user registers with an email address, a respective name and password and is assigned a unique userId.
 *	A user can be both an application owner (a publisher) and an end user.
 *	A user is required in order to add other entities to the relayr platform.
 */
@interface RelayrUser ()

/*!
 *  @abstract It initialises a <code>RelayrUser</code> with a specific OAuth token. The common initialiser <code>-init:</code> is not accepted.
 *  @discussion If <code>token</code> is <code>nil</code> or not valid, this initialiser returns <code>nil</code>.
 *
 *  @param token OAuth token for the Relayr cloud queries.
 *	@return Fully initialised <code>RelayrUser</code>.
 */
- (instancetype)initWithToken:(NSString*)token;

/*!
 *  @abstract This is the central connection with the Relayr.framework web module.
 *  @discussion It is never <code>nil</code>. When an instance of <code>RelayrUser</code> is created, this property is setup to a valid web service.
 */
@property (readonly,nonatomic) RLAWebService* webService;

/*!
 *  @abstract A unique idenfier of a <code>RelayrUser</code> instance.
 */
@property (readwrite,nonatomic) NSString* uid;

/*!
 *  @abstract A user name for a specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract Relayr user email for a specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSString* email;

/*!
 *  @abstract The relayr applications under the specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* apps;

/*!
 *  @abstract An array of the <code>publisher</code>s listed under the specific user.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* publishers;

/*!
 *  @abstract An array of the Transmitter entities owned by the specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* transmitters;

/*!
 *  @abstract An array of the Device entities owned by the specific <code>RelayrUser</code> instace
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSArray* devices;

/*!
 *  @abstract Devices that the specific <code>RelayrUser</code> instace has bookmarked.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 *	By Bookmarking a device you are indicating that you have a particular interest in this device.
 *	In the relayr context, a bookmarked device will appear on a user's Developer Dashboard.
 */
@property (readwrite,nonatomic) NSArray* devicesBookmarked;

@end
