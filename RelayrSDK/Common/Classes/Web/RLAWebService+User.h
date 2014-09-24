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
+ (void)isUserWithEmail:(NSString*)email
registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion;

/*!
 *  @abstract It queries the Relayr Cloud for data about the user Information.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 */
- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion;

/*!
 *  @abstract It sets some properties of the called Relayr User (both arguments are optional).
 *  @discussion If the method succees, <code>nil</code> is returned in the completion block.
 *
 *  @param name The future name of the current user. If <code>nil</code>, the name is not modified.
 *  @param email The future email string of the current user. If <code>nil</code>, the email is not modified.
 *  @param completion Block indicationg the result of the operation. If you want to risk it and not check for the result of the operation; you can pass <code>nil</code> here.
 *
 *  @see RelayrUser
 */
- (void)setUserName:(NSString*)name
              email:(NSString*)email
         completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Install an app under a specific user.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrApp
 */
- (void)authoriseApp:(NSString*)appID
      forCurrentUser:(void (^)(NSError* error))completion;

/*!
 *  @abstract It queries the Relayr Cloud for all the apps installed under this user.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrApp
 */
- (void)requestUserAuthorisedApps:(void (^)(NSError* error, NSArray* apps))completion;

/*!
 *  @abstract Uninstall an app under a specific user.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrApp
 */
- (void)unauthoriseApp:(NSString*)appID
      forCurrentUser:(void (^)(NSError* error))completion;

/*!
 *  @abstract It queries the Relayr Cloud for all the publishers that a Relayr user owns.
 *  @discussion A publisher is a Relayr user who is able to publish apps in the Relayr cloud.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrPublisher
 */
- (void)requestUserPublishers:(void (^)(NSError* error, NSArray* publishers))completion;

/*!
 *  @abstract It queries the Relayr Cloud for all the transmitters own by a Relayr user.
 *  @discussion Devices and transmitters are different concepts.
 *
 *  @param completion Block indicating the result of the server query. The <code>transmitter</code> parameter is an <code>NSArray</code> containing fully initialised <code>RelayrTransmitter</code> objects without any device.
 *
 *  @see RelayrUser
 *  @see RelayrTransmitter
 */
- (void)requestUserTransmitters:(void (^)(NSError* error, NSArray* transmitters))completion;

/*!
 *  @abstract Retrieves the <code>RelayrDevice</code>s the user owns.
 *  @discussion Devices and transmitters are different concepts.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrDevice
 */
- (void)requestUserDevices:(void (^)(NSError* error, NSArray* devices))completion;

/*!
 *  @abstract Retrieves the user devices entities filtered by meaning.
 *
 *  @param meaning The type of input the device reads.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrDevice
 */
- (void)requestUserDevicesFilteredByMeaning:(NSString*)meaning
                                 completion:(void (^)(NSError* error, NSArray* devices))completion;

/*!
 *  @abstract Creates a link/bookmark in the server, giving quick access to a favourite <code>RelayrDevice</code>.
 *
 *  @param deviceID The device that wanted to be bookmarked.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrDevice
 */
- (void)registerUserBookmarkToDevice:(NSString*)deviceID
                          completion:(void (^) (NSError* error))completion;

/*!
 *  @abstract Retrieves all the bookmarked devices of a specific Relayr user.
 *  @discussion A bookmarked device is a normally own device that the user finds him/herself reading/sending data often.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrDevice
 */
- (void)requestUserBookmarkedDevices:(void (^)(NSError* error, NSArray* bookDevices))completion;

/*!
 *  @abstract Deletes a bookmark that a user had to a specific device.
 *
 *  @param deviceID The device that wanted to be bookmarked.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 *  @see RelayrDevice
 */
- (void)deleteUserBookmarkToDevice:(NSString*)deviceID
                        completion:(void (^) (NSError* error))completion;

@end
