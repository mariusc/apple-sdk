@import Foundation;             // Apple
@class RelayrUser;              // Relayr.framework (Public)
#import "RelayrConnection.h"    // Relayr.framework (Public/IoTs)

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

@end
