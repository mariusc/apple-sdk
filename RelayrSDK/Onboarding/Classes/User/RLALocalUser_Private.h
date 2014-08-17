#import "RLALocalUser.h"        // Base class
@class RLABluetoothService;     // Relayr.framework

@interface RLALocalUser ()

@property (readonly, nonatomic) RLABluetoothService* bleService;

@end
