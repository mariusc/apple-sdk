#import "RLASensorHumidity.h"       // Header
#import "RLASensor_Setup.h"         // Extension
#import "RLASensorValueHumidity.h"  // Relayr.framework

@implementation RLASensorHumidity

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
    return [RLASensorValueHumidity class];
}

@end
