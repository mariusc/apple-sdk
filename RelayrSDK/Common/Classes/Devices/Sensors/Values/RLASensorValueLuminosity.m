#import "RLASensorValueLuminosity.h"    // Header

@implementation RLASensorValueLuminosity

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber*)luminosity
{
    return [self.dictionary valueForKey:@"light"];
}

@end
