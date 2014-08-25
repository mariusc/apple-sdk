@import Foundation;         // Header
@class RLAWebRequest;       // Relayr.framework (Web)

@interface RLAWebModal : NSObject

/*!
 *  @method initWithRequest:
 *
 *  @abstract It initializes a modal webview and presents it modally in a window.
 *
 *  @param request <code>RLAWebRequest</code> with the address that the webView should show.
 *	@return A fully initialised <code>RLAWebModel</code> or <code>nil</code>.
 *
 *  @see RLAWebRequest
 */
- (instancetype)initWithRequest:(RLAWebRequest*)request;

/*!
 *  @property request
 *
 *  @abstract It returns the web request use by this <code>RLAWebModal</code>.
 *  @discussion It cannot be changed during the lifetime of this <code>RLAWebModal</code> instance.
 */
@property (readonly,nonatomic) RLAWebRequest* request;

/*!
 *  @property completion
 *
 *  @abstract Block that will be executed once the request fail or success.
 *  @discussion It can be <code>nil</code>.
 */
@property (strong,nonatomic) void (^completion)(NSError* error, id obj);

/*!
 *  @method presentModally
 *
 *  @abstract It presents the initialized webModal and request modally to the user.
 *  @discussion The user will be presented with a webview and all other user interactions with the app will be halted till the request is completed or the webView is canceled.
 *
 *	@return Boolean indicating whether the webview could be presented modally.
 */
- (BOOL)presentModally;

@end
