@import Foundation;             // Apple
@class RelayrUser;              // Relayr.framework (Public)
#import "RLAService.h"          // Relayr.framework (Service)
@class RelayrDevice;            // FIXME: Delete

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

/*!
 *  @abstract It is initialised with a <code>RelayrUser</code> token.
 *  @discussion This initialiser can return <code>nil</code> if the data needed is not yet in the user.
 *
 *  @param user <code>RelayrUser</code> that will own this service.
 *	@return Fully initialised <code>RLAService</code> object or <code>nil</code>.
 */ 
- (instancetype)initWithUser:(RelayrUser*)user device:(RelayrDevice*)device;    // FIXME: Delete this method. Only -initWithUser: is supposed to be used.

@end
