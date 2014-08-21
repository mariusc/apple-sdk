#import "RLASensorNoise.h"      // Header
#import "RLASensor_Setup.h"     // Extension
#import "RLASensorValueNoise.h" // Relayr.framework

@implementation RLASensorNoise

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
    return [RLASensorValueNoise class];
}

@end
