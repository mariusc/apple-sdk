@import Foundation;             // Apple
@class RelayrUser;              // Relayr (Public)
#import "RLAService.h"          // Relayr (Service)

/*!
 *  @abstract Central BLE service for a specific <code>RelayrUser</code>.
 *  @discussion An instance of this class will manage all the BLE related task for a single user.
 */
@interface RLABLEService : NSObject <RLAService>

@end
