@import Foundation;             // Apple
@class RelayrUser;              // Relayr.framework (Public)
#import "RLAService.h"          // Relayr.framework (Protocols)

/*!
 *  @abstract MQTT connection manager for a <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the MQTT related task for a single user.
 *
 *  @see RelayrUser
 */
@interface RLAMQTTService : NSObject <RLAService>

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

@end
