@import Foundation;

/*!
 *  @class RelayrUser
 *
 *  @abstract Each instance of this class represent a Relayr User that is associated with the Relayr Application that created.
 */
@interface RelayrUser : NSObject <NSCoding>

/*!
 *  @property token
 *
 *  @abstract The representation of a Relayr User and its Relayr Application.
 *  @discussion It doesn't change along the lifetime of the <code>RelayrUser</code>
 */
@property (readonly,nonatomic) NSString* token;

/*!
 *  @property uid
 *
 *  @abstract Relyar idenfier for the <code>RelayrUser</code>'s instance.
 *  @discussion This identifier is unique for the Relayr Cloud and never changes.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @property name
 *
 *  @abstract Relayr user name for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @property email
 *
 *  @abstract Relayr user email for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSString* email;

/*!
 *  @property apps
 *
 *  @abstract Relayr applications for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* apps;

/*!
 *  @property transmitter
 *
 *  @abstract Transmitter that this <code>RelayrUser</code>'s instace owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* transmitter;

/*!
 *  @property devices
 *
 *  @abstract Devices that this <code>RelayrUser</code>'s instace owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* devices;

/*!
 *  @property devicesBookmarked
 *
 *  @abstract Favorite devices that this <code>RelayrUser</code>'s instace have bookmarked.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* devicesBookmarked;

/*!
 *  @property publishers
 *
 *  @abstract How many <code>publisher</code>s have the Relayr user owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* publishers;

/*!
 *  @method queryCloudForUserInfo:
 *
 *  @abstract It queries the Relayr servers for the user information.
 *  @discussion Every time this method is call a server query is launched. Once that request is returned successfuly, all the <i>readonly</i>-user related properties would have changed to accomodate the new values.
 *
 *  @param completion Block indiciating whether the server query was successful or not.
 *
 *  @see queryCloudForIoTs:
 */
- (void)queryCloudForUserInfo:(void (^)(NSError* error, NSString* previousName, NSString* previousEmail))completion;

/*!
 *  @method queryCloudForIoTs:
 *
 *  @abstract It queries the Relayr servers for all devices, transmitters, and bookmarked devices of this <code>RelayUser</code> instance.
 *  @discussion Every time this method is call a server query is launched. Once that request is returned successfuly, all the <i>readonly</i>-devices related properties would have changed to accomodate the new values.
 *
 *  @param completion Block indicating whether the server query was successful or not.
 *
 *  @see queryCloudForUserInfo:
 */
- (void)queryCloudForIoTs:(void (^)(NSError* error, BOOL isThereChanges))completion;

@end
