@import Foundation;

/*!
 *  @abstract Each instance of this class represent a Relayr User that is associated with the Relayr Application that created.
 */
@interface RelayrUser : NSObject <NSCoding>

/*!
 *  @abstract The representation of a Relayr User and its Relayr Application.
 *  @discussion It doesn't change along the lifetime of the <code>RelayrUser</code>
 */
@property (readonly,nonatomic) NSString* token;

/*!
 *  @abstract Relyar idenfier for the <code>RelayrUser</code>'s instance.
 *  @discussion This identifier is unique for the Relayr Cloud and never changes.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract Relayr user name for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract Relayr user email for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSString* email;

/*!
 *  @abstract Transmitter that this <code>RelayrUser</code>'s instace owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* transmitter;

/*!
 *  @abstract Devices that this <code>RelayrUser</code>'s instace owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* devices;

/*!
 *  @abstract Favorite devices that this <code>RelayrUser</code>'s instace have bookmarked.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* devicesBookmarked;

/*!
 *  @abstract Relayr applications for this <code>RelayrUser</code>'s instace.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* apps;

/*!
 *  @abstract How many <code>publisher</code>s have the Relayr user owns.
 *  @discussion It can change after a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSArray* publishers;

/*!
 *  @abstract It queries the Relayr servers for the user information.
 *  @discussion Every time this method is call a server query is launched. Once that request is returned successfuly, all the <i>readonly</i>-user related properties would have changed to accomodate the new values.
 *
 *  @param completion Block indiciating whether the server query was successful or not.
 *
 *  @see queryCloudForIoTs:
 */
- (void)queryCloudForUserInfo:(void (^)(NSError* error, NSString* previousName, NSString* previousEmail))completion;

/*!
 *  @abstract It queries the Relayr servers for all devices, transmitters, and bookmarked devices of this <code>RelayUser</code> instance.
 *  @discussion Every time this method is called a server query is launched. Once that request is returned successfuly, all the <i>readonly</i>-devices related properties would have changed to accomodate the new values.
 *
 *  @param completion Block indicating whether the server query was successful or not.
 *
 *  @see queryCloudForUserInfo:
 */
- (void)queryCloudForIoTs:(void (^)(NSError* error, NSNumber* isThereChanges))completion;

/*!
 *  @abstract It queries the Relayr servers for all the applications, and publishers entities own by the user.
 *  @discussion Every time this method is called a server query is launched. Once that request is returned successfully, the <i>readonly</i> apps and publishers properties would have changed to accomodate the new values.
 *
 *  @param completion Block indicating whether the server query was successful or not.
 */
- (void)queryCloudForUserAppsAndPublishers:(void (^)(NSError* error, NSNumber* isThereChanges))completion;

@end
