@class RelayrUser;      // Relayr.framework (Public)
@import Foundation;     // Apple

/*!
 *  @abstract Web connection manager for a <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the web connections (whether HTTP calls, PUBNUB, etc.) of a single user.
 *
 *  @see RelayrUser
 */
@interface RLAWebService : NSObject

/*!
 *  @abstract It checks whether the Relayr cloud is reachable and the service is up.
 *  @discussion The Relayr cloud can be unreachable for several reasons: no internet connection, cannot resolve DNS, Relayr service is temporarily unavailable. It is worth noticing, that you can still work with the SDK even when the Relayr cloud is unavailable (in the unlikely case that that happened).
 *
 *  @param completion Block giving you a Boolean answer about the availability of the service and an error explaining the unreachability (in case that happened).
 */
+ (void)isRelayrCloudReachable:(void (^)(NSError* error, NSNumber* isReachable))completion;

/*!
 *  @abstract It queries the Relayr Cloud for information of a Relayr application.
 *
 *  @param completion Block indicating the result of the server query.
 */
+ (void)requestAppInfoFor:(NSString*)appID completion:(void (^)(NSError* error, NSString* appID, NSString* appName, NSString* appDescription))completion;

/*!
 *  @param email <code>NSString</code> representing the user's email.
 *  @param completion Block answering the query.
 */
+ (void)isUserWithEmail:(NSString*)email registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion;

/*!
 *  @abstract It requests the temporal access OAuth code needed to ask for a 100 year OAuth access token.
 *
 *  @param clientID <code>NSString</code> representing the Oauth client ID. You receive this when creating an app in the Relayr developer platform.
 *  @param redirectURI <code>NSString</code> representing the redirect URI you chosed when creating an app in the Relayr developer platform.
 *  @param completion Block with the answer to the OAuth code request. If it failed, an error object will be initialized and the
 *
 *  @see requestOAuthTokenWithOAuthCode:OAuthClientSecret:OAuthClientSecret:redirectURI:completion:
 */
+ (void)requestOAuthCodeWithOAuthClientID:(NSString*)clientID
                              redirectURI:(NSString*)redirectURI
                               completion:(void (^)(NSError* error, NSString* tmpCode))completion;

/*!
 *  @abstract It request a valid OAuth token from OAuth code, clientID, clientSecret, and redirectURI.
 *
 *  @param code Temporal OAuth code (usually valid for 5 minutes) that it is required for your
 *  @param clientID <code>NSString</code> representing the Oauth client ID. You receive this when creating an app in the Relayr developer platform.
 *  @param clientSecret <code>NSString</code> representing the Oauth client secret. You receive this when creating an app in the Relayr developer platform.
 *  @param redirectURI <code>NSString</code> representing the redirect URI you chosed when creating an app in the Relayr developer platform.
 *  @param completion Block with the answer to the OAuth code request. If it failed, an error object will be initialized and the
 *
 *  @see requestOAuthCodeWithOAuthClientID:redirectURI:completion:
 */
+ (void)requestOAuthTokenWithOAuthCode:(NSString*)code
                         OAuthClientID:(NSString*)clientID
                     OAuthClientSecret:(NSString*)clientSecret
                           redirectURI:(NSString*)redirectURI
                            completion:(void (^)(NSError* error, NSString* token))completion;

/*!
 *  @abstract It is initialised with a <code>RelayrUser</code> token.
 *  @discussion If <code>userToken</code> is <code>nil</code> or the token is not valid, this initialiser returns <code>nil</code>.
 *
 *  @param user <code>RelayrUser</code> OAuth token.
 *	@return Fully initialised <code>RLAWebService</code>.
 */
- (instancetype)initWithUser:(__weak RelayrUser*)user;

/*!
 *  @abstract <code>RelayrUser</code> who is associated with this <code>RLAWebService</code> instance.
 *  @discussion This object will be set at initialisation and never touched again.
 */
@property (readonly,weak,nonatomic) RelayrUser* user;

/*!
 *  @abstract The base URL that will be used in every webService instance call.
 *  @discussion It cannot be <code>nil</code>. If <code>nil</code> is passed, the default Relayr host is used.
 */
@property (strong,nonatomic) NSURL* hostURL;

/*!
 *  @abstract It queries the Relayr Cloud for data about the user Information.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrUser
 */
- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion;

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

/*!
 *  @abstract It queries the Relayr Cloud for all the apps installed under this user.
 *
 *  @param completion Block indicating the result of the server query.
 */
- (void)requestUserApps:(void (^)(NSError* error, NSArray* apps))completion;

@end
