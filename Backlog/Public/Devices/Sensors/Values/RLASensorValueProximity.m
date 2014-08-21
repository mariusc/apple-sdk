#import "RLASensorValueProximity.h"   // Header

@implementation RLASensorValueProximity

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber*)proximity
{
    return self.dictionary[@"prox"];
}

@end
