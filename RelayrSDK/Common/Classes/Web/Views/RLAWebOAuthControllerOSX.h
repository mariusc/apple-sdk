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
 *  @method initWithURLRequest:redirectURI:
 *
 *  @abstract It creates the webview and initialise it with the passed arguments.
 *  @discussion Then it is ready to launch at any time a <i>present</i> method is called.
 *
 *  @param urlRequest <code>NSURLRequest</code> with the URL request for the webView.
 *  @param redirectURI URI used for security measures to test that the answer is coming from the right place.
 *	@return Fully initialised WebView implementing the <code>RLAWebOAuthController</code> or <code>nil</code>.
 *
 *  @see RLAWebViewOAuth
 */
- (instancetype)initWithURLRequest:(NSURLRequest*)urlRequest
                       redirectURI:(NSString*)redirectURI
                        completion:(void (^)(NSError*, NSString*))completion;

#pragma mark WebPolicyDelegate

/*!
 *  @method webView:decidePolicyForNavigationAction:request:frame:decisionListener:
 *
 *  @abstract It routes a navigation action internally or to an external viewer.
 *  @discussion This method will be called before loading starts, and on every redirect.
 *
 *  @param actionInformation Dictionary that describes the action that triggered this navigation.
 *  @param request The request for the proposed navigation
 *  @param frame The WebFrame in which the navigation is happening
 *  @param listener The object to call when the decision is made
 *
 *  @see WebPolicyDelegate
 */
- (void)webView:(WebView*)webView decidePolicyForNavigationAction:(NSDictionary*)actionInformation request:(NSURLRequest*)request frame:(WebFrame*)frame decisionListener:(id<WebPolicyDecisionListener>)listener;

#pragma mark WebFrameLoadDelegate

/*!
 *  @method webView:didFinishLoadForFrame:
 *
 *  @abstract Notifies the delegate that the committed load of a frame has completed
 *  @discussion This method is called after the committed data source of a frame has successfully loaded and will only be called when all subresources such as images and stylesheets are done loading. Plug-In content and JavaScript-requested loads may occur after this method is called.
 *
 *  @param webView The WebView sending the message
 *  @param frame The frame that finished loading
 *
 *  @see WebFrameLoadDelegate
 */
- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame;

/*!
 *  @method webView:didFailLoadWithError:
 *
 *  @abstract Notifies the delegate that the committed load of a frame has failed
 *  @discussion This method is called after a data source has committed but failed to completely load.
 *
 *  @param webView The WebView sending the message
 *  @param error The error that occurred
 *  @param frame The frame that failed to load
 *
 *  @see WebFrameLoadDelegate
 */
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError*)error forFrame:(WebFrame*)frame;

@end
