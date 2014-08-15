#import "RLASensorValueProximity.h"

@implementation RLASensorValueProximity

#pragma mark - Public API

- (NSNumber*)proximity
{
    return self.dictionary[@"prox"];
}

@end
