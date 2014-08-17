#import "RLASensorValueHumidity.h"      // Header

@implementation RLASensorValueHumidity

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber*)humidity
{
    return self.dictionary[@"hum"];
}

@end
