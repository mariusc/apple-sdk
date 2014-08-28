@import WebKit;                 // Apple
#import "RLAWebViewOAuth.h"     // Relayr.framework (Web)

/*!
 *  @class RLAWebViewOAuthOSX
 *
 *  @abstract It represents a WebView for OS X.
 *  @discussion An instance of this class implements the <code>RLAWebViewOAuth<code> protocol.
 *
 *  @see RLAWebViewOAuth
 */
@interface RLAWebViewOAuthOSX : WebView <RLAWebViewOAuth>

/*!
 *  @method initWithURL:completion:
 *
 *  @abstract It creates the webview and initialise it with the passed arguments.
 *  @discussion Then it is ready to launch at any time a <i>present</i> method is called.
 *
 *  @param absoluteURL <code>NSURL</code> with the URL request for the webView.
 *	@return Fully initialised WebView implementing the <code>RLAWebViewOAuth</code> or <code>nil</code>.
 *
 *  @see RLAWebViewOAuth
 */
- (instancetype)initWithURL:(NSURL*)absoluteURL
                 completion:(void (^)(NSError* error, NSString* tmpCode))completion;

@end
