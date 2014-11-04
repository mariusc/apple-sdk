#import "RLAAPIService.h"

/*!
 *  @abstract API calls refering to the Relayr Cloud (as an entity).
 *
 *  @see RLAAPIService
 */
@interface RLAAPIService (Cloud)

/*!
 *  @abstract It checks whether the Relayr cloud is reachable and the service is up.
 *  @discussion The Relayr cloud can be unreachable for several reasons: no internet connection, cannot resolve DNS, Relayr service is temporarily unavailable. It is worth noticing, that you can still work with the SDK even when the Relayr cloud is unavailable (in the unlikely case that that happened).
 *
 *  @param completion Block giving you a Boolean answer about the availability of the service and an error explaining the unreachability (in case that happened).
 */
+ (void)isRelayrCloudReachable:(void (^)(NSError* error, NSNumber* isReachable))completion;

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

@end
