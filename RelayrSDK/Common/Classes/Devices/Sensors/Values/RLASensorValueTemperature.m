#import "RLASensorValueTemperature.h"   // Header

@implementation RLASensorValueTemperature

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber*)temperature
{
    return self.dictionary[@"temp"];
}

@end
