#import "RLASensorProximity.h"      // Header
#import "RLASensor_Setup.h"         // Relayr.framework
#import "RLASensorValueProximity.h" // Relayr.framework

@implementation RLASensorProximity

- (Class)sensorValueClass
{
    return [RLASensorValueProximity class];
}

@end
