@class RelayrUser;      // Relayr.framework (public)
@import Foundation;     // Apple

/*!
 *  @class RelayrApp
 *
 *  @abstract It represents a Relayr Application and through it, you can interact with the Relayr cloud.
 *  @discussion Relayr applications allow your mobile app to access information on the Relayr cloud. They are the starting point on any Relayr information retrieval or information pushing into the cloud.
 */
@interface RelayrApp : NSObject

/*!
 *  @method appWithID:OAuthClientID:OAuthClientSecret:redirectURI:
 *
 *  @abstract It retrieves from the database or create an applicationID and query the server for its authenticity.
 *
 *  @param appID <code>NSString</code> representing the Relayr Application ID. You receive this when creating an app in the Relayr developer platform.
 *  @param clientID <code>NSString</code> representing the Oauth client ID. You receive this when creating an app in the Relayr developer platform.
 *  @param clientSecret <code>NSString</code> representing the Oauth client secret. You receive this when creating an app in the Relayr developer platform.
 *  @param redirectURI <code>NSString</code> representing the redirect URI you chosed when creating an app in the Relayr developer platform.
 *  @param completion Block indicating the result of the initialisation. This method is potentially asynchronous, if it does need to talk to the server. Be aware!
 *
 *  @see RelayrCloud
 */
+ (void)appWithID:(NSString*)appID
    OAuthClientID:(NSString*)clientID
OAuthClientSecret:(NSString*)clientSecret
      redirectURI:(NSString*)redirectURI
       completion:(void (^)(NSError* error, RelayrApp* app))completion;

/*!
 *  @method storeAppInKeyChain:
 *
 *  @abstract It stores a Relayr Application in a permanent storage (KeyChain or iCloud, depending on your application capabilities).
 *  @param app Relayr Application to be removed from the permanent storage.
 *
 *	@return Boolean indicating whether the operation was successful.
 */
+ (BOOL)storeAppInKeyChain:(RelayrApp*)app;

/*!
 *  @method retrieveFromKeyChainAppWithID:
 *
 *  @abstract It retrieves a previously stored Relayr Application from a permanent storage (KeyChain or iCloud, depending on your device capabilities).
 *
 *  @param appID Relayr ID for a Relayr application.
 *
 *	@return Fully initialised <code>RelayrApp</code> or <code>nil</code>.
 */
+ (RelayrApp*)retrieveFromKeyChainAppWithID:(NSString*)appID;

/*!
 *  @method removeFromKeyChainApp:
 *
 *  @abstract It removes a previously stored Relayr Application from a permanent storage (KeyChain or iCloud).
 *
 *  @param app Relayr Application to be removed from the permanent storage.
 *	@return If the object is successfully removed or the object was not there, <code>YES</code> is returned. If the remove operation could not be performed, the method will return <code>NO</code>.
 */
+ (BOOL)removeFromKeyChainApp:(RelayrApp*)app;

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
 *  @property appDescription
 *
 *  @abstract Relayr Application description.
 *  @discussion This value must be first retrieved asynchronously from the Relayr Cloud. If you don't query the server, this property is <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* appDescription;

/*!
 *  @property publisherID
 *
 *  @abstract Creator of the Relayr Application ID.
 *  @discussion This value must be first retrieved asynchronously from the Relayr Cloud. If you don't query the server, this property is <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* publisherID;

/*!
 *  @method queryForAppInfoWithUserCredentials:completion:
 *
 *  @abstract It queries the Relayr Cloud for the lacking application properties. You need a Relayr user with the credentials to look for the application information.
 *  @discussion The method is called asynchronously and it can fail. If the request was successful, the old values will be writen as block arguments, and the new ones will be set in the <code>RelayrApp</code> instance.
 *
 *  @param completion Block handing status of the cloud request.
 */
- (void)queryForAppInfoWithUserCredentials:(RelayrUser*)user completion:(void (^)(NSError* error, NSString* previousName, NSString* previousDescription))completion;

/*!
 *  @property loggedUsers
 *
 *  @abstract Array containing all the currently signed <code>RelayrUser</code>s.
 *  @discussion By logged, it means the user credentials that the application is currently storing. Calling the signing out method, will remove those credential from the application's database.
 */
@property (readonly,nonatomic) NSArray* loggedUsers;

/*!
 *  @method loggedUserWithRelayrID:
 *
 *  @abstract Retrieved a logged user (<code>loggedUsers</code>) with the passed RelayrID. If the user is not logged or it is not valid, <code>nil</code> will be the result.
 *  @discussion This is a convenience method. It does the same as iterating through <code>loggedUsers</code> array and check for the Relayr ID of every user.
 *
 *  @param relayrID The Relayr ID that identifies the Relayr user in the Relayr Cloud.
 *	@return <code>nil</code> or the <code>RelayrUser</code> with that <code>relayrID</code>.
 *
 *  @see RelayrUser
 */
- (RelayrUser*)loggedUserWithRelayrID:(NSString*)relayrID;

/*!
 *  @method signInUser:
 *
 *  @abstract It signs a Relayr User for the current Relayr Application and returns (in the completion block) the object representing the user.
 *  @discussion The user will be confronted by a modal webview asking for his/her Relayr's credentials. If the sign in process is successful, a fully formed <code>RelayrUser</code> object will be returned in the <code>completion</code> block.
        You should first query for loggedUsers. This method is only supposed to be used when you want the credentials of a Relayr User that you don't have or when you want to register a new user to the Relayr Cloud.
        If at the completion of asking for user credentials, the user was already logged in the array <code>loggedUsers</code>, you would received the <code>RelayrUser</code> in that array; not a newly instance.
 *
 *  @param completion Asynchronous block returning the status of the sign in process.
 *
 *  @see RelayrUser
 */
- (void)signInUser:(void (^)(NSError* error, RelayrUser* user))completion;

/*!
 *  @method signOutUser:
 *
 *  @abstract It signs out an user from the Relayr Application.
 *  @discussion What this actually do is to remove the user from the stored users array. Meanwhile you are keeping a <code>RelayrUser</code> reference alive, you can still use the user.
 *
 *  @param user Representaton of a Relayr user, if <code>RelayrUser</code> is not valid or <code>nil</code>, this method won't perform any job.
 *
 *  @see RelayrUser
 */
- (void)signOutUser:(RelayrUser*)user;

@end
