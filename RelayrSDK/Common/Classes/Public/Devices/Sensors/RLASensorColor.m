#import "RLASensorColor.h"      // Header
#import "RLASensor_Setup.h"     // Extension
#import "RLASensorValueColor.h" // Relayr.framework

@implementation RLASensorColor

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
    return [RLASensorValueColor class];
}

@end
