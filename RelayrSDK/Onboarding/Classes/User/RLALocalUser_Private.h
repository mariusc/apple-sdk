#import "RLALocalUser.h"        // Base class
@class RLABluetoothService;     // FIXME: Old

@interface RLALocalUser ()

@property (readonly, nonatomic) RLABluetoothService* bleService;

@end
