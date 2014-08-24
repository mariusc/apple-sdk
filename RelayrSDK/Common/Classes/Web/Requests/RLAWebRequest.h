@import Foundation;

FOUNDATION_EXPORT NSString* const kRLAWebRequestModeGET;
FOUNDATION_EXPORT NSString* const kRLAWebRequestModePOST;

/*!
 *  @class RLAWebRequest
 *
 *  @abstract Base class for the Relayr.framework HTTP requests.
 *  @discussion This class specifies the core properties of the Relayr.framework web requests.
 */
@interface RLAWebRequest : NSObject

/*!
 *  @method initWithHostURL:timeout:token:
 *
 *  @abstract Convenience method that sets the <code>hostURL</code>, <code>timeout</code>, and <code>token</code> in one go.
 *  @discussion Any of the arguments can be <code>nil</code>.
 *
 *  @param hostURL Host URL path of the HTTP request.
 *  @param tiemout Number of seconds that the request will be waiting for an answer.
 *  @param token Oauth token for a secure HTTP request.
 *	@return Initialized web HTTP request in a friendly Relayr way.
 */
- (instancetype)initWithHostURL:(NSURL*)hostURL timeout:(NSNumber*)timeout oauthToken:(NSString*)token;

/*!
 *  @property timeout
 *
 *  @abstract Number of seconds that the request will look for an answer. If in that time the answer hasn't arrived, a fail completion block will be executed.
 */
@property (strong,nonatomic) NSNumber* timeout;

/*!
 *  @property hostURL
 *
 *  @abstract Host URL path.
 *  @discussion The request can be executed if any of the <code>hostURL</code> or <code>relativeURL</code> is not <code>nil</code>.
 */
@property (strong,nonatomic) NSURL* hostURL;

/*!
 *  @property relativePath
 *
 *  @abstract <code>NSString</code> representing a relative URL path to be appended to the <code>hostURL</code>.
 *  @discussion The request can be executed if any of the <code>hostURL</code> or <code>relativePath</code> is not <code>nil</code>.
 */
@property (strong,nonatomic) NSString* relativePath;

/*!
 *  @property oauthToken
 *
 *  @abstract Oauth token to be used in the HTTP request.
 *  @discussion Only needed if the connection needs to be secured.
 */
@property (strong,nonatomic) NSString* oauthToken;

/*!
 *  @property httpHeader
 *
 *  @abstract Any HTTP header that you want included in the HTTP request.
 *  @discussion It can be <code>nil</code>.
 */
@property (strong,nonatomic) NSDictionary* httpHeaders;

/*!
 *  @property body
 *
 *  @abstract Object that will be sent in the HTTP request body. It can be <code>nl</code>.
 *  @discussion This object can currently be a <code>NSString</code> or a <code>NSDictionary</code> (representing a JSON) and it must later be encoded into <code>NSData</code> before sending. This will be done automatically.
 */
@property (readonly,nonatomic) id body;

/*!
 *  @method executeInHTTPMode:withExpectedStatusCode:completion:
 *
 *  @abstract It enqueues for execution the HTTP request and monitor its result to check if the request was successful.
 *
 *  @param mode HTTP request mode (@"GET", @"POST", etc.).
 *	@return Boolean indicating whether the request was enqueued for execution or not.
 */
- (BOOL)executeInHTTPMode:(NSString*)mode withExpectedStatusCode:(NSUInteger const)statusCode completion:(void (^)(NSError* error, NSData* data))completion;

@end
