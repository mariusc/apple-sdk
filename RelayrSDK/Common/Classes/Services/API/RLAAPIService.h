@import Foundation;             // Apple
@class RelayrUser;              // Relayr.framework (Public)
#import "RelayrConnection.h"    // Relayr.framework (Public/IoTs)

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

/*!
 *  @abstract Web connection manager for a <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the web connections (whether HTTP calls, etc.) of a single user.
 *
 *  @see RelayrUser
 */
@interface RLAAPIService : NSObject

/*!
 *  @abstract It is initialised with a <code>RelayrUser</code> token.
 *  @discussion This initialiser can return <code>nil</code> if the data needed is not yet in the user.
 *
 *  @param user <code>RelayrUser</code> that will own this service.
 *	@return Fully initialised <code>RLAService</code> object or <code>nil</code>.
 */
- (instancetype)initWithUser:(RelayrUser*)user;

/*!
 *  @abstract <code>RelayrUser</code> who is associated with this <code>RLAAPIService</code> instance.
 *  @discussion This object will be set at initialisation and never touched again.
 */
@property (readonly,weak,nonatomic) RelayrUser* user;

/*!
 *  @abstract The state of the service connection.
 */
@property (readonly,nonatomic) RelayrConnectionState connectionState;

/*!
 *  @abstract The scope of the service connection.
 *  @discussion For services like Bluetooth, this value will never change; however for services like API or MQTT, the value can fluctuate depending on your network (LAN, WAN, etc.).
 */
@property (readonly,nonatomic) RelayrConnectionScope connectionScope;

/*!
 *  @abstract The base URL that will be used in every apiService instance call.
 *  @discussion It cannot be <code>nil</code>. If <code>nil</code> is passed, the default Relayr host is used.
 */
@property (strong,nonatomic) NSString* hostString;

/*!
 *  @abstract <code>NSURLSession</code> use for routing all API calls.
 */
@property (readonly,nonatomic) NSURLSession* session;

/*!
 *  @abstract It builds an URL path from a host string and a relative string.
 *  @discussion Any of the paths can be "nil" or empty and the final absolute string will still be correctly built.
 *
 *  @param hostString Base path of the absolute URL.
 *  @param relativePath Relative path of the absolute URL.
 */
+ (NSURL*)buildAbsoluteURLFromHost:(NSString*)hostString relativeString:(NSString*)relativePath;

/*!
 *  @abstract It returns a default set <code>NSMutableURL</code> that you can later on modify.
 *  @discussion This mutable URL Request is an ephimeral request, with HTTP Pipelining set on. If the parameters passed are not valid, <code>nil</code> is returned.
 *
 *  @param absoluteURL Address where the request will be sent.
 *  @param httpMode The HTTP request Mode. Whether GET, POST, etc.
 *  @param authorizationToken OAuth token embedded on the URL request. You don't need to pass this value is a request is being performed that doesn't need authorization.
 */
+ (NSMutableURLRequest*)requestForURL:(NSURL*)absoluteURL HTTPMethod:(NSString*)httpMode authorizationToken:(NSString*)authorizationToken;

/*!
 *  @abstract A <code>NSError</code> object is returned with the characteristics of the passed <code>RelayrConnectionState</code>
 *  @discussion The <i>connected</i> and <i>connecting</i> states, return <code>nil</code>.
 */
+ (NSError*)internetErrorForConnectionState:(RelayrConnectionState)connectionState;

@end
