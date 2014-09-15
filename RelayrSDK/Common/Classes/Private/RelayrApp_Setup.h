#import "RelayrApp.h"       // Header

/*!
 *  @abstract Represents a relayr Application which allows interaction with the relayr Cloud.
 *  @discussion An app is a basic entity in the relayr platform.
 *	The relayr platform relates to apps in two manners: Publisher Apps and User Apps.
 *	Publisher apps are apps which are purchasable on an app store and are owned by a publisher.
 *	User apps are apps which have been approved to the data of an end user. This approval has been granted by the user.
 */
@interface RelayrApp () <NSCoding>

/*!
 *  @abstract Designated initialiser for <code>RelayrApp</code>.
 *
 *  @param appID <code>NSString</code> representing the Relayr Application ID.
 *  @param clientSecret <code>NSString</code> with the OAuth client secret.
 *  @param redirectURI <code>NSString</code> with the security address.
 *	@return Fully initialised <code>RelayrApp</code> object.
 */
- (instancetype)initWithID:(NSString*)appID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI;

/*!
 *  @abstract Convenience initialiser for <code>RelayrApp</code>.
 */
- (instancetype)initWithID:(NSString *)appID;

/*!
 *  @abstract The relayr application name.
 *  @discussion This value should first be retrieved asynchronously, from the relayr server.
 *	If the server is not queried, this property is <code>nil</code>.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract The relayr application description.
 *  @discussion This value should first be retrieved asynchronously, from the relayr server.
 *	If the server is not queried, this property is <code>nil</code>.
 */
@property (readwrite,nonatomic) NSString* appDescription;

/*!
 *  @abstract The Id of the app Publisher.
 *  @discussion This value should first be retrieved asynchronously, from the relayr server.
 *	If the server is not queried, this property is <code>nil</code>.
 */
@property (readwrite,nonatomic) NSString* publisherID;

/*!
 *  @abstract OAuth client (app) secret.
 */
@property (readwrite,nonatomic) NSString* oauthClientSecret;

/*!
 *  @abstract The OAuth redirect URI.
 *  @discussion The URI of the page where the user is redirected upon successful login. The URI must include the protocol used e.g. 'http'.
 *	The redirect URI is set when an application is registered on the relayr Platform.
 *	@see <a href="https://developer.relayr.io/documents/Authorization/OAuthAndRelayr">The OAuth on relayr section on the Develooper Dashboard.</a>
 */
@property (readwrite,nonatomic) NSString* redirectURI;

@end
