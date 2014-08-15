#import "RLASensorValueLuminosity.h"    // Header

@implementation RLASensorValueLuminosity

- (NSNumber*)luminosity
{
    return self.dictionary[@"light"];
}

@end
