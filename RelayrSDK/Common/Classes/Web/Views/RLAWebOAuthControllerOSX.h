@import Cocoa;                      // Apple
@import WebKit;                     // Apple
#import "RLAWebOAuthController.h"   // Relayr.framework (Web)

/*!
 *  @class RLAWebOAuthControllerOSX
 *
 *  @abstract It represents a WebController for OS X.
 *  @discussion An instance of this class implements the <code>RLAWebOAuthControllerOSX<code> protocol.
 *
 *  @see RLAWebOAuthControllerOSX
 */
@interface RLAWebOAuthControllerOSX : NSWindowController <RLAWebOAuthController>

/*!
 *  @method initWithURLRequest:redirectURI:completion:
 *
 *  @abstract It creates the webview and initialise it with the passed arguments.
 *  @discussion Then it is ready to launch at any time a <i>present</i> method is called.
 *
 *  @param urlRequest <code>NSURLRequest</code> with the URL request for the webView.
 *  @param redirectURI URI used for security measures to test that the answer is coming from the right place.
 *  @param completion Block that will carry out the answer of the request.
 *	@return Fully initialised WebView implementing the <code>RLAWebOAuthController</code> or <code>nil</code>.
 *
 *  @see RLAWebViewOAuth
 */
- (instancetype)initWithURLRequest:(NSURLRequest*)urlRequest
                       redirectURI:(NSString*)redirectURI
                        completion:(void (^)(NSError* error, NSString* tmpCode))completion;

#pragma mark WebFrameLoadDelegate

/*!
 *  @method webView:didFinishLoadForFrame:
 *
 *  @abstract <#Brief intro#>
 *  @discussion <#Description with maybe some <code>Code</code> and links to other methods {@link method:name:}#>
 *
 *  @param <#name#> <#Description#>
 *	@return <#What it is returned#>
 *
 *  @see <#Method:to:see:#>
 *  @seealso <#ConstantVariable#>
 */
- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame;

/*!
 *  @method webView:didFailLoadWithError:
 *
 *  @abstract <#Brief intro#>
 *  @discussion <#Description with maybe some <code>Code</code> and links to other methods {@link method:name:}#>
 *
 *  @param <#name#> <#Description#>
 *	@return <#What it is returned#>
 *
 *  @see <#Method:to:see:#>
 *  @seealso <#ConstantVariable#>
 */
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame*)frame;

@end
