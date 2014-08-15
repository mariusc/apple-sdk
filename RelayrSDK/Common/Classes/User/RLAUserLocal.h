@import Foundation;             // Apple
#import "RLAUser.h"             // Relayr.framework (Base class)
//#import "RLAUserDevicesAPI.h"   // Relayr.framework (protocol)

/*!
 *  @class RLAUserLocal
 *
 *  @abstract Relayr user who is purely local and cannot connect to the Relayr cloud.
 *  @discussion This user will connect to devices/sensors through local networks (BLE, etc.)
 */
@interface RLAUserLocal : NSObject <RLAUser> //<RLAUserDevicesAPI>

/*!
 *  @method user
 *
 *  @abstract Class method that returns an already initialized local user without possibility to connect to the Relayr cloud.
 *
 *	@return It returns an already initialized local user to manage devices and sensors without going to the Relayr cloud.
 */
+ (instancetype)user;

@end
