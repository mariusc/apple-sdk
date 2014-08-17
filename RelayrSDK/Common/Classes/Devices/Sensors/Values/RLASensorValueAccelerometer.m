#import "RLASensorValueAccelerometer.h"     // Header

@implementation RLASensorValueAccelerometer

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber*)accelerationX
{
    return [[self.dictionary valueForKey:@"accel"] valueForKey:@"x"];
}

- (NSNumber*)accelerationY
{
    return [[self.dictionary valueForKey:@"accel"] valueForKey:@"y"];
}

- (NSNumber*)accelerationZ
{
    return [[self.dictionary valueForKey:@"accel"] valueForKey:@"z"];
}

@end
