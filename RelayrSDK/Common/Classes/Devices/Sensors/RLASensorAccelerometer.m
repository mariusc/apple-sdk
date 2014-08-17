#import "RLASensorAccelerometer.h"      // Header
#import "RLASensor_Setup.h"             // Extension
#import "RLASensorValueAccelerometer.h" // Relayr.framework

@implementation RLASensorAccelerometer

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
    return [RLASensorValueAccelerometer class];
}

@end
