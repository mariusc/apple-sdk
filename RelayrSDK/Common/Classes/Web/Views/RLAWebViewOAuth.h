@import Foundation;

/*!
 *  @def RLAWebViewOAuthTitle
 *
 *  @abstract This is the title that the WebView will display.
 */
#define dRLAWebViewOAuthTitle   @"Relayr"

/*!
 *  @protocol RLAWebViewOAuth
 *
 *  @abstract It represents a WebView Controller that it is presented modally to ask for user credentials.
 */
@protocol RLAWebViewOAuth <NSObject>

@required
/*!
 *  @property url
 *
 *  @abstract It indicates where the webView will be directed to.
 */
@property (readonly,nonatomic) NSURL* url;

@required
/*!
 *  @method completion
 *
 *  @abstract Block containing what it will be executed once the request fail or success.
 */
@property (strong,nonatomic) void (^completion)(NSError* error, NSString* tmpCode);

@required
/*!
 *  @method presentModally
 *
 *  @abstract It presents the called WebView modally in your system.
 *  @discussion If it can't present itself, it will return <code>NO</code>. The completion won't be called with an error.
 *
 *	@return Boolean indicating whether the modal presentation was successful or not.
 */
- (BOOL)presentModally;

@optional
/*!
 *  @method presentAsPopOverInViewController:witTipLocation:
 *
 *  @abstract It presents the called WebView as a popover of the passed <code>viewController.
 *  @discussion This method also accepts an optional <code>NSValue</code> with the rectangle or point indicating where the tip of the buble should be.
 *
 *  @param viewController <code>UIViewController</code> or <code>NSViewController</code> where the webView will be presented. If <code>nil</code>, this method won't perform any job.
 *	@return Boolean indicating whether the modal presentation was successful or not.
 */
- (BOOL)presentAsPopOverInViewController:(id)viewController
                          witTipLocation:(NSValue*)location;

@end

/*!
 *  @class RLAWebViewOAuth
 *
 *  @abstract This class only gives you the appropriate webView object for your system.
 *
 *  @see RLAWebViewOAuthIOS
 *  @see RLAWebViewOAuthOSX
 */
@interface RLAWebViewOAuth : NSObject

/*!
 *  @method webViewWithOAuthClientID:redirectURI:completion:
 *
 *  @abstract It gives you the appropriate webview for your system. If the arguments are invalid, <code>nil</code> is returned.
 *
 *  @param clientID OAuth client ID.
 *  @param redirectURI URI that will be tested for when the answer comes back.
 *  @param completion Completion block given back the answer of the request.
 *	@return Fully initialised object that implements the <code>RLAWebViewOAuth</code> protocol, or <code>nil</code>.
 *
 *  @see RLAWebViewOAuth
 */
+ (id<RLAWebViewOAuth>)webViewWithOAuthClientID:(NSString*)clientID
                                    redirectURI:(NSString*)redirectURI
                                     completion:(void (^)(NSError* error, NSString* tmpCode))completion;

@end
