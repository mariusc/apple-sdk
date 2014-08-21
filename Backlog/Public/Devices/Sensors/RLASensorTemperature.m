#import "RLASensorTemperature.h"        // Header
#import "RLASensor_Setup.h"             // Extension
#import "RLASensorValueTemperature.h"   // Relayr.framework


@implementation RLASensorTemperature

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
    return [RLASensorValueTemperature class];
}

@end
