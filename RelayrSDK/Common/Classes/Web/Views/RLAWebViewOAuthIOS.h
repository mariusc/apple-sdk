@import UIKit;              // Apple
#import "RLAWebViewOAuth.h" // Relayr.framework (Web)

/*!
 *  @class RLAWebViewOAuthIOS
 *
 *  @abstract It creates a viewController hosting a <code>UIWebView</code> that will ask for Relayr user credentials.
 *
 *  @see RLAWebViewOAuth
 */
@interface RLAWebViewOAuthIOS : UIViewController <RLAWebViewOAuth>

/*!
 *  @method initWithURL:completion:
 *
 *  @abstract It initializes the <code>UIViewController</code> with a request URL and a completion block.
 *  @discussion Both arguments must be valid for the method to not return <code>nil</code>.
 *
 *  @param absoluteURL Request URL shown in the WebView.
 *  @param completion Block that will carry out the answer of the request.
 *	@return A fully initialised <code>RLAWebViewOAuth</code> object implementation.
 */
- (instancetype)initWithURL:(NSURL*)absoluteURL
                 completion:(void (^)(NSError*, NSString*))completion;

@end
