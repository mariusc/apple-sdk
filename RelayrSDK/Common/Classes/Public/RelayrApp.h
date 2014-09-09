@class RelayrUser;      // Relayr.framework (public)
@import Foundation;     // Apple

/*!
 *  @abstract Represents a relayr Application which allows interaction with the relayr Cloud.
 *  @discussion An app is a basic entity in the relayr platform. 
 *	The relayr platform relates to apps in two manners: Publisher Apps and User Apps.
 *	Publisher apps are apps which are purchasable on an app store and are owned by a publisher.
 *	User apps are apps which have been approved to the data of an end user. This approval has been granted by the user.
 */
@interface RelayrApp : NSObject

/*!
 *  @abstract Retrieves an applicationID from the relayr server or creates one and queries the server for its authenticity.
 *
 *  @param appID <code>NSString</code> representing the relayr Application ID. Generated when creating an app on the relayr developer dashboard.
 *  @param clientSecret <code>NSString</code> representing the OAuth client secret. Generated when creating an app on the relayr developer dashboard.
 *  @param redirectURI <code>NSString</code> representing the redirect URI entered when creating an app on the relayr developer dashboard.
 *  @param completion Block indicating the result of the initialization. Note: This method is potentially asynchronous, if it does need to talk to the server.
 *
 *  @see RelayrCloud
 */
+ (void)appWithID:(NSString*)appID
OAuthClientSecret:(NSString*)clientSecret
      redirectURI:(NSString*)redirectURI
       completion:(void (^)(NSError* error, RelayrApp* app))completion;

/*!
 *  @abstract Stores a Relayr Application in permanent storage (KeyChain or iCloud, depending on your device capabilities).
 *  @param app The relayr application to be stored.
 *
 *	@return Boolean indicating whether the operation was successful or not.
 */
+ (BOOL)storeAppInKeyChain:(RelayrApp*)app;

/*!
 *  @abstract Retrieves a previously stored relayr application from permanent storage (KeyChain or iCloud).
 *
 *  @param appID The Id of the application.
 *
 *	@return A fully initialized <code>RelayrApp</code> or <code>nil</code>.
 */
+ (RelayrApp*)retrieveAppFromKeyChain:(NSString*)appID;

/*!
 *  @abstract Removes a previously stored relayr application from permanent storage (KeyChain or iCloud).
 *
 *  @param app The relayr application to be removed.
 *	@return If the object is successfully removed or not found, <code>YES</code> is returned. If the remove operation could not be performed, the method will return <code>NO</code>.
 */
+ (BOOL)removeAppFromKeyChain:(RelayrApp*)app;

/*!
 *  @abstract The relayr application ID.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract The relayr application name.
 *  @discussion This value should first be retrieved asynchronously, from the relayr server. 
 *	If the server is not queried, this property is <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract The relayr application description.
 *  @discussion This value should first be retrieved asynchronously, from the relayr server. 
 *	If the server is not queried, this property is <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* appDescription;

/*!
 *  @abstract The Id of the app Publisher.
 *  @discussion This value should first be retrieved asynchronously, from the relayr server. 
 *	If the server is not queried, this property is <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* publisherID;

/*!
 *  @abstract OAuth client (app) secret.
 */
@property (readonly,nonatomic) NSString* oauthClientSecret;

/*!
 *  @abstract The OAuth redirect URI.
 *  @discussion The URI of the page where the user is redirected upon successful login. The URI must include the protocol used e.g. 'http'. 
 *	The redirect URI is set when an application is registered on the relayr Platform. 
 *	@see <a href="https://developer.relayr.io/documents/Authorization/OAuthAndRelayr">The OAuth on relayr section on the Develooper Dashboard.</a>
 */
@property (readonly,nonatomic) NSString* redirectURI;

/*!
 *  @abstract Queries the server for missing application properties. A User with credential is required to retrieve this information.
 *  @discussion The method is called asynchronously. 
 *	If the request is successful, old values will be written as block arguments, and new ones will be set in the <code>RelayrApp</code> instance.
 *
 *  @param completion A block with the status of the request.
 */
- (void)queryForAppInfoWithUserCredentials:(RelayrUser*)user completion:(void (^)(NSError* error, NSString* previousName, NSString* previousDescription))completion;

/*!
 *  @abstract An Array containing all logged in <code>RelayrUser</code>s.
 *  @discussion By logged in, we mean that the user's credentials are stored by the application. 
 *	Calling the sign out method, will remove those credential from the application.
 */
@property (readonly,nonatomic) NSArray* loggedUsers;

/*!
 *  @abstract Retrieves a logged in user (<code>loggedUsers</code>) according to their Id. 
 *  @discussion This is a convenience method. It replaces having to iterate through the <code>loggedUsers</code> array searching for the relevant user.
 *	If the user is not logged in or not valid, <code>nil</code> is returned.
 *
 *  @param relayrID The ID that identifies the user on the relayr platform.
 *	@return <code>nil</code> or the <code>RelayrUser</code> with the specific <code>relayrID</code>.
 *
 *  @see RelayrUser
 */
- (RelayrUser*)loggedUserWithRelayrID:(NSString*)relayrID;

/*!
 *  @abstract Signs in a Relayr User to the current relayr application and returns (in the completion block) an object representing the user.
 *  @discussion The user will be prompted with a modal webview asking for their relayr credentials. 
 *	If the sign in process is successful, a fully formed <code>RelayrUser</code> object will be returned in the <code>completion</code> block.
        Start by querying loggedUsers. 
        This method is only supposed to be used when looking for credentials of a relayr User that you don't have or when you want to register a new user on the relayr platform.
        If the user is already logged in and part of the <code>loggedUsers</code> array, you will receive the <code>RelayrUser</code> in that array rather than a new instance.
 *
 *  @param completion An Asynchronous block with the status of the sign in process.
 *
 *  @see RelayrUser
 */
- (void)signInUser:(void (^)(NSError* error, RelayrUser* user))completion;

/*!
 *  @abstract Signs out a user from the application.
 *  @discussion What this method actually does is to remove the user from the stored users array. 
 *	You keep the <code>RelayrUser</code> reference alive, so you can still use it.
 *
 *  @param user A representaton of a relayr user. 
 *	If <code>RelayrUser</code> is not valid or <code>nil</code>, this method will not perform anything.
 *
 *  @see RelayrUser
 */
- (void)signOutUser:(RelayrUser*)user;

@end
