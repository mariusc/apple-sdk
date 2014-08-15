#import "RLASensorColor.h"      // Header
#import "RLASensor_Setup.h"     // Relayr.framework
#import "RLASensorValueColor.h" // Relayr.framework

@implementation RLASensorColor

- (Class)sensorValueClass
{
    return [RLASensorValueColor class];
}

@end
