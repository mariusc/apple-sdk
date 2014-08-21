#import "RLASensorProximity.h"      // Header
#import "RLASensor_Setup.h"         // Extension
#import "RLASensorValueProximity.h" // Relayr.framework

@implementation RLASensorProximity

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Extensions

#pragma mark RLASensor_Setup

- (Class)sensorValueClass
{
    return [RLASensorValueProximity class];
}

@end
