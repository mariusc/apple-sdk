#import "RLASensorValueNoise.h"     // Header

@implementation RLASensorValueNoise

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber*)noiseLevel
{
    return @([[self.dictionary valueForKey:@"snd_level"] integerValue]);
}

@end
