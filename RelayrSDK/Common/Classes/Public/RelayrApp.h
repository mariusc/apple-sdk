@import Foundation;     // Apple
@class RelayrUser;      // Relayr.framework (public)

/*!
 *  @class RelayrApp
 *
 *  @abstract It represents a Relayr Application and through it, you can interact with the Relayr cloud.
 *  @discussion Relayr applications allow your mobile app to access information on the Relayr cloud. They are the starting point on any Relayr information retrieval or information pushing into the cloud.
 */
@interface RelayrApp : NSObject

/*!
 *  @method initWithID:OAuthClientID:OAuthClientSecret:redirectURI:
 *
 *  @abstract It represents a Relayr application as an object.
 *  @discussion This initialisator will only store the app credentials. If the credentials passed are false/wrong, you will have an useless <code>RelayrApp</code> object. You can check whether an Relayr Application ID actually exists within the <code>RelayrCloud</code> class.
 *
 *  @param appID <code>NSString</code> representing the Relayr Application ID. You receive this when creating an app in the Relayr developer platform.
 *  @param clientID <code>NSString</code> representing the Oauth client ID. You receive this when creating an app in the Relayr developer platform.
 *  @param clientSecret <code>NSString</code> representing the Oauth client secret. You receive this when creating an app in the Relayr developer platform.
 *  @param redirectURI <code>NSString</code> representing the redirect URI you chosed when creating an app in the Relayr developer platform.
 *	@return Object storing the minimum/basic Relayr Application information.
 *
 *  @see RelayrCloud
 */
- (instancetype)initWithID:(NSString*)appID OAuthClientID:(NSString*)clientID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI;

/*!
 *  @property uid
 *
 *  @abstract Relayr Application ID.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @property oauthClientID
 *
 *  @abstract OAuth credential for the client ID.
 */
@property (readonly,nonatomic) NSString* oauthClientID;

/*!
 *  @property oauthClientSecret
 *
 *  @abstract OAuth credential for the client secret.
 */
@property (readonly,nonatomic) NSString* oauthClientSecret;

/*!
 *  @property redirectURI
 *
 *  @abstract This URI is check for security.
 *  @discussion The Relayr related information should arrived from this URI.
 */
@property (readonly,nonatomic) NSString* redirectURI;

/*!
 *  @property name
 *
 *  @abstract Relayr Application name.
 *  @discussion This value must be first retrieved asynchronously from the Relayr Cloud. If you don't query the server, this property is <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @property description
 *
 *  @abstract Relayr Application description.
 *  @discussion This value must be first retrieved asynchronously from the Relayr Cloud. If you don't query the server, this property is <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* description;

/*!
 *  @property publisherID
 *
 *  @abstract Creator of the Relayr Application ID.
 *  @discussion This value must be first retrieved asynchronously from the Relayr Cloud. If you don't query the server, this property is <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* publisherID;

/*!
 *  @method isValid:
 *
 *  @abstract It checks the validity of the current <code>RelayrApplication</code> ID.
 *  @discussion This method performs the same as the one in <code>RelayrCloud</code>.
 *
 *  @param completion Block handing the result of the server query.
 *
 *  @see RelayrCloud
 */
- (void)isValid:(void (^)(NSError* error, BOOL valid))completion;

/*!
 *  @method queryCloudForAppInfo:
 *
 *  @abstract It queries the Relayr Cloud for the lacking application properties.
 *  @discussion The method is called asynchronously and it can fail. If the request was successful, the old values will be writen as block arguments, and the new ones will be set in the <code>RelayrApp</code> instance.
 *
 *  @param completion Block handing status of the cloud request.
 */
- (void)queryCloudForAppInfo:(void (^)(NSError* error, NSString* previousName, NSString* previousDescription, NSString* previousRedirectURI))completion;

/*!
 *  @property loggedUsers
 *
 *  @abstract Array containing all the currently signed <code>RelayrUser</code>s.
 *  @discussion By logged, it means the user credentials that the application is currently storing. Calling the signing out method, will remove those credential from the application database.
 */
@property (readonly,nonatomic) NSArray* loggedUsers;

/*!
 *  @method signInUserStoringCredentialsIniCloud:completion
 *
 *  @abstract It signs a Relayr user for the current Relayr Application and returns (in the completion block) the object representing the user.
 *  @discussion The user will be confronted by a modal webview asking for his/her Relayr's credentials. If the sign in process is successful, a fully formed <code>RelayrUser</code> object will be returned in the <code>completion</code> block.
 *
 *  @param completion Asynchronous block returning the status of the sign in process.
 *
 *  @see RelayrUser
 */
- (void)signInUserStoringCredentialsIniCloud:(BOOL)sendCredentialsToiCloud completion:(void (^)(RelayrUser* user, NSError* error))completion;

/*!
 *  @method signOutUser:
 *
 *  @abstract It signs out an user from the Relayr Application.
 *  @discussion What this actually do is to remove the user from the stored users array (and the iCloud if it was there). Meanwhile you are keeping a <code>RelayrUser</code> reference alive, you can still use the user.
 *
 *  @param user Representaton of a Relayr user, if <code>RelayrUser</code> is not valid or <code>nil</code>, this method won't perform any job.
 *
 *  @see RelayrUser
 */
- (void)signOutUser:(RelayrUser*)user;

@end
