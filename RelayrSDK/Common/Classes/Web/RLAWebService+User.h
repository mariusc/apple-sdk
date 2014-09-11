#import "RLAWebService.h"

/*!
 *  @abstract API calls refering to Relayr User (as entities).
 *
 *  @see RLAWebService
 */
@interface RLAWebService (User)

/*!
 *  @param email <code>NSString</code> representing the user's email.
 *  @param completion Block answering the query.
 */
+ (void)isUserWithEmail:(NSString*)email registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion;

/*!
 *  @abstract It queries the Relayr Cloud for data about the user Information.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 */
- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion;

/*!
 *  @abstract It queries the Relayr Cloud for all the apps installed under this user.
 *
 *  @param completion Block indicating the result of the server query.
 */
- (void)requestUserApps:(void (^)(NSError* error, NSArray* apps))completion;

/*!
 *  @abstract It queries the Relayr Cloud for all the publishers that a Relayr user owns.
 *  @discussion A publisher is a Relayr user who is able to publish apps in the Relayr cloud.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 */
- (void)requestUserPublishers:(void (^)(NSError* error, NSArray* publishers))completion;

/*!
 *  @abstract It queries the Relayr Cloud for all the transmitters own by a Relayr user.
 *  @discussion Devices and transmitters are different concepts.
 *
 *  @param completion Block indicating the result of the server query. The <code>transmitter</code> parameter is an <code>NSArray</code> containing fully initialised <code>RelayrTransmitter</code> objects without any device.
 *
 *  @see RelayrUser
 */
- (void)requestUserTransmitters:(void (^)(NSError* error, NSArray* transmitters))completion;

/*!
 *  @abstract It queries the Relayr Cloud for all the devices own by a Realyr user.
 *  @discussion Devices and transmitters are different concepts.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 */
- (void)requestUserDevices:(void (^)(NSError* error, NSArray* devices))completion;

/*!
 *  @abstract It queries the Relayr Cloud for all the bookmarked devices of a specific Relayr user.
 *  @discussion A bookmarked device is a normally own device that the user finds him/herself reading/sending data often.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 */
- (void)requestUserBookmarkedDevices:(void (^)(NSError* error, NSArray* bookDevices))completion;

@end
