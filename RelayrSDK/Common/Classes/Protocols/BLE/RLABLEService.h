@import Foundation;             // Apple
@class RelayrUser;              // Relayr.framework (Public)
#import "RLAService.h"          // Relayr.framework (Protocols)

/*!
 *  @abstract Central BLE service for a specific <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the BLE related task for a single user.
 */
@interface RLABLEService : NSObject <RLAService>

@end
