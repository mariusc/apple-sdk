#import "RLASensorGyroscope.h"      // Header
#import "RLASensor_Setup.h"         // Extension
#import "RLASensorValueGyroscope.h" // Relayr.framework

@implementation RLASensorGyroscope

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
    return [RLASensorValueGyroscope class];
}

@end
