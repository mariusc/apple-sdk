@import Foundation;

// Retrieval methods ("safe" methods)
FOUNDATION_EXPORT NSString* const kRLAAPIRequestModeGET;
FOUNDATION_EXPORT NSString* const kRLAAPIRequestModeHEAD;

// Modifying methods ("unsafe" methods)
FOUNDATION_EXPORT NSString* const kRLAAPIRequestModeCOPY;
FOUNDATION_EXPORT NSString* const kRLAAPIRequestModeDELETE;
FOUNDATION_EXPORT NSString* const kRLAAPIRequestModeOPTIONS;
FOUNDATION_EXPORT NSString* const kRLAAPIRequestModePATCH;
FOUNDATION_EXPORT NSString* const kRLAAPIRequestModePOST;
FOUNDATION_EXPORT NSString* const kRLAAPIRequestModePUT;
/* For more info: http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html */

// This macro expands into the reiterative process request (Be careful when changing variable names.
#define processRequest(expectedCode, ...)   \
    (!error && responseCode.unsignedIntegerValue==expectedCode && data) \
    ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil; \
    if (!json) { return completion( (error) ? error : RelayrErrorWebRequestFailure, __VA_ARGS__); }

/*!
 *  @abstract Base class for the Relayr.framework HTTP requests.
 *  @discussion This class specifies the core properties of the Relayr.framework web requests.
 */
@interface RLAAPIRequest : NSObject

/*!
 *  @abstract Convenience method that only sets the <code>hostString</code>.
 *  @discussion Any of the arguments can be <code>nil</code>.
 *
 *  @param hostString Host URL path of the HTTP request.
 *	@return Initialised web HTTP request in a friendly Relayr way.
 *
 *  @see initWithHost:timeout:token:
 */
- (instancetype)initWithHost:(NSString*)hostString;

/*!
 *  @abstract Convenience method that sets the <code>hostURL</code>, <code>timeout</code>, and <code>token</code> in one go.
 *  @discussion Any of the arguments can be <code>nil</code>. Alternatively, you can use the normal <code>init</code> method.
 *
 *  @param hostString Host URL path of the HTTP request.
 *  @param timeout Number of seconds that the request will be waiting for an answer.
 *  @param token Oauth token for a secure HTTP request.
 *	@return Initialized web HTTP request in a friendly Relayr way.
 *
 *  @see initWithHost:
 */
- (instancetype)initWithHost:(NSString*)hostString timeout:(NSNumber*)timeout oauthToken:(NSString*)token;

/*!
 *  @abstract Number of seconds that the request will look for an answer. If in that time the answer hasn't arrived, a fail completion block will be executed.
 */
@property (strong,nonatomic) NSNumber* timeout;

/*!
 *  @abstract Host URL path.
 *  @discussion The request can be executed if any of the <code>hostURL</code> or <code>relativeURL</code> is not <code>nil</code>.
 */
@property (strong,nonatomic) NSString* hostString;

/*!
 *  @abstract <code>NSString</code> representing a relative URL path to be appended to the <code>hostURL</code>.
 *  @discussion The request can be executed if any of the <code>hostURL</code> or <code>relativePath</code> is not <code>nil</code>.
 */
@property (strong,nonatomic) NSString* relativePath;

/*!
 *  @abstract Oauth token to be used in the HTTP request.
 *  @discussion Only needed if the connection needs to be secured.
 */
@property (strong,nonatomic) NSString* oauthToken;

/*!
 *  @abstract Any HTTP header that you want included in the HTTP request.
 *  @discussion It can be <code>nil</code>.
 */
@property (strong,nonatomic) NSDictionary* httpHeaders;

/*!
 *  @abstract Object that will be sent in the HTTP request body. It can be <code>nil</code>.
 *  @discussion This object can currently be a <code>NSString</code>, a <code>NSDictionary</code> or a <code>NSArray</code> (representing a JSON). This will be done automatically.
 */
@property (strong,nonatomic) id body;

/*!
 *  @abstract It enqueues for execution the HTTP request and monitor its result to check if the request was successful.
 *  @discussion If this method returns <code>NO</code>, the <code>completion</code> block is not executed. That block is only executed once a response from the server is received (or a lack of it); but the point is that the request must have been enqueued.
 *
 *  @param mode HTTP request mode (@"GET", @"POST", etc.).
 *  @param completion Block returning the respond of the request
 *	@return Boolean indicating whether the request was enqueued for execution or not.
 */
- (BOOL)executeInHTTPMode:(NSString*)mode completion:(void (^)(NSError* error, NSNumber* responseCode, NSData* data))completion;

@end
