@import Foundation;     // Apple
#import "RLAService.h"  // Relayr.framework (Protocols)
@class RelayrUser;      // Relayr.framework (Public)

/*!
 *  @abstract Central BLE service for a specific <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the BLE related task for a single user.
 */
@interface RLABLEService : NSObject <RLAService>

/*!
 *  @abstract Initialiser for a BLE Service.
 *  @discussion If the user is <code>nil</code>, this initialiser will return <code>nil</code>.
 *
 *  @param user <code>RelayrUser</code> owner of this service.
 *	@return Fully initialised <code>RLABLEService</code>.
 */
- (instancetype)initWithUser:(RelayrUser*)user;

/*!
 *  @abstract <code>RelayrUser</code> who is associated with this <code>RLAMQTTService</code> instance.
 *  @discussion This object will be set at initialisation and never touched again.
 */
@property (readonly,weak,nonatomic) RelayrUser* user;

@end
