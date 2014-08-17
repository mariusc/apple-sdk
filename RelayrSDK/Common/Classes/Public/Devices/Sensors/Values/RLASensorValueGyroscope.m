#import "RLASensorValueGyroscope.h"   // Header

@implementation RLASensorValueGyroscope

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber*)rotationX
{
    return [[self.dictionary valueForKey:@"gyro"] valueForKey:@"x"];
}

- (NSNumber*)rotationY
{
    return [[self.dictionary valueForKey:@"gyro"] valueForKey:@"y"];
}

- (NSNumber*)rotationZ
{
    return [[self.dictionary valueForKey:@"gyro"] valueForKey:@"z"];
}

@end
