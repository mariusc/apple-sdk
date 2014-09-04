@import Foundation;

/*!
 *  @abstract It represents a WebView Controller that it is presented modally to ask for user credentials.
 */
@protocol RLAWebOAuthController <NSObject>

@required
/*!
 *  @abstract It indicates where the webView will be trying to connect to.
 */
@property (readonly,nonatomic) NSURLRequest* urlRequest;

@required
/*!
 *  @abstract The redirect URI from which Relayr cloud message are arriving.
 *  @discussion It is a security meassure.
 */
@property (readonly,nonatomic) NSString* redirectURI;

@required
/*!
 *  @abstract Block containing what it will be executed once the request fail or success.
 */
@property (copy,nonatomic) void (^completion)(NSError* error, NSString* tmpCode);

@required
/*!
 *  @abstract It presents the called WebView modally in your system.
 *  @discussion If it can't present itself, it will return <code>NO</code>. The completion won't be called with an error.
 *
 *	@return Boolean indicating whether the modal presentation was successful or not.
 */
- (BOOL)presentModally;

@optional
/*!
 *  @abstract It presents the called WebView as a popover of the passed <code>viewController</code>.
 *  @discussion This method also accepts an optional <code>NSValue</code> with the rectangle or point indicating where the tip of the buble should be.
 *
 *  @param viewController <code>UIViewController</code> or <code>NSViewController</code> where the webView will be presented. If <code>nil</code>, this method won't perform any job.
 *	@return Boolean indicating whether the modal presentation was successful or not.
 */
- (BOOL)presentAsPopOverInViewController:(id)viewController
                          witTipLocation:(NSValue*)location;

@end

/*!
 *  @abstract This class only gives you the appropriate webView object for your system.
 *
 *  @see RLAWebOAuthControllerIOS
 *  @see RLAWebOAuthControllerOSX
 */
@interface RLAWebOAuthController : NSObject

/*!
 *  @abstract It gives you the appropriate webview for your system. If the arguments are invalid, <code>nil</code> is returned.
 *
 *  @param clientID OAuth client ID.
 *  @param redirectURI URI that will be tested for when the answer comes back.
 *	@return Fully initialised object that implements the <code>RLAWebOAuthController</code> protocol, or <code>nil</code>.
 *
 *  @see RLAWebOAuthController
 */
+ (id<RLAWebOAuthController>)webOAuthControllerWithClientID:(NSString*)clientID
                                                redirectURI:(NSString*)redirectURI
                                                 completion:(void (^)(NSError* error, NSString* tmpCode))completion;

/*!
 *  @abstract It retrieves the OAuth temporal code from an <code>NSURLRequest</code> coming from the Relayr server.
 *  @discussion This method is usually called from within the <code>RLAWebOAuthController</code> specific from each system.
 *
 *  @param request <code>NSURLRequest</code> coming from the Relayr cloud.
 *  @param redirectURI URI to test whether the <code>NSURLRequest</code> is coming from the appropriate place. It is a security measure.
 *	@return If successful, this method returns the OAUth temporal code as a <code>NSString</code>. If not, it returns <code>nil</code>.
 */
+ (NSString*)OAuthTemporalCodeFromRequest:(NSURLRequest*)request
                          withRedirectURI:(NSString*)redirectURI;

@end
