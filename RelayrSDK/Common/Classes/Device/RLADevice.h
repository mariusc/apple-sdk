// Apple
@import Foundation;

// Relayr.framework
// Protocols
#import "RLADeviceAPI.h"
#import "RLADeviceConnectionAPI.h"

@interface RLADevice : NSObject <RLADeviceAPI, RLADeviceConnectionAPI>

@end
