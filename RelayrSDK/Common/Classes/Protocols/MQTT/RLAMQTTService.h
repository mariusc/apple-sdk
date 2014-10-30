@import Foundation;     // Apple
@class RelayrUser;      // Relayr.framework (Public)
#import "RLAService.h"  // Relayr.framework (Protocols)
#import "RelayrConnection.h"

/*!
 *  @abstract MQTT connection manager for a <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the MQTT related task for a single user.
 *
 *  @see RelayrUser
 */
@interface RLAMQTTService : NSObject <RLAService>

/*!
 *  @abstract It is initialised with a <code>RelayrUser</code> and its corresponding <code>RLAWebService</code>.
 *  @discussion If the user is <code>nil</code> or its <code>RLAWebService</code> hasn't been initialised yet, this initialiser will return <code>nil</code>.
 *
 *  @param user <code>RelayrUser</code> owner of this service.
 *	@return Fully initialised <code>RLAMQTTService</code>.
 */
- (instancetype)initWithUser:(RelayrUser*)user;

/*!
 *  @abstract <code>RelayrUser</code> who is associated with this <code>RLAMQTTService</code> instance.
 *  @discussion This object will be set at initialisation and never touched again.
 */
@property (readonly,weak,nonatomic) RelayrUser* user;

/*!
 *  @abstract The base URL (host) that will be used in every MQTT method.
 *  @discussion It cannot be <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* hostString;

/*!
 *  @abstract Port being used for the MQTT data.
 *  @discussion It cannot be <code>nil</code>.
 */
@property (readonly,nonatomic) NSNumber* port;

/*!
 *  @abstract The state of the MQTT connection.
 */
@property (readonly,nonatomic) RelayrConnectionState connectionState;

@end
