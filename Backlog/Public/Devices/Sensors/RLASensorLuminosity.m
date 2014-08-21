#import "RLASensorLuminosity.h"         // Header
#import "RLASensor_Setup.h"             // Extension
#import "RLASensorValueLuminosity.h"    // Relayr.framework

@implementation RLASensorLuminosity

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
    return [RLASensorValueLuminosity class];
}

@end
