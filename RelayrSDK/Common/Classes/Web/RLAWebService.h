@import Foundation;     // Apple
@class RelayrUser;      // Relayr.framework (Public)

/*!
 *  @abstract Web connection manager for a <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the web connections (whether HTTP calls, PUBNUB, etc.) of a single user.
 *
 *  @see RelayrUser
 */
@interface RLAWebService : NSObject

/*!
 *  @abstract It is initialised with a <code>RelayrUser</code> token.
 *  @discussion If <code>userToken</code> is <code>nil</code> or the token is not valid, this initialiser returns <code>nil</code>.
 *
 *  @param user <code>RelayrUser</code> OAuth token.
 *	@return Fully initialised <code>RLAWebService</code>.
 */
- (instancetype)initWithUser:(RelayrUser*)user;

/*!
 *  @abstract <code>RelayrUser</code> who is associated with this <code>RLAWebService</code> instance.
 *  @discussion This object will be set at initialisation and never touched again.
 */
@property (readonly,weak,nonatomic) RelayrUser* user;

/*!
 *  @abstract The base URL that will be used in every webService instance call.
 *  @discussion It cannot be <code>nil</code>. If <code>nil</code> is passed, the default Relayr host is used.
 */
@property (strong,nonatomic) NSString* hostString;

@end
