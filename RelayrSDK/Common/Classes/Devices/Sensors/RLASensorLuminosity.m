#import "RLASensorLuminosity.h"         // Header
#import "RLASensor_Setup.h"             // Relayr.framework
#import "RLASensorValueLuminosity.h"    // Relayr.framework

@implementation RLASensorLuminosity

- (Class)sensorValueClass
{
    return [RLASensorValueLuminosity class];
}

@end
