@import Foundation;

/*!
 *  @class RLAWebService
 *
 *  @abstract Web connection manager for a <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the web connections (whether HTTP calls, PUBNUB, etc.) of a single user.
 *
 *  @see RelayrUser
 */
@interface RLAWebService : NSObject

/*!
 *  @method requestOAuthTemporalCodeForAppID:OAuthClientID:OAuthClientSecret:redirectURI:completion:
 *
 *  @abstract It requests the temporal access OAuth code needed to ask for a 100 year token
 
 *  @discussion <#Description with maybe some <code>Code</code> and links to other methods {@link method:name:}#>
 *
 *  @param <#name#> <#Description#>
 *
 *  @see <#Method:to:see:#>
 */
+ (void)requestOAuthTemporalCodeForAppID:(NSString*)appID
                           OAuthClientID:(NSString*)clientID
                       OAuthClientSecret:(NSString*)clientSecret
                             redirectURI:(NSString*)uri
                              completion:(void (^)(NSError* error, NSString* tmpToken))completion;

@end
