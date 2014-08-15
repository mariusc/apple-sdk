#import "RLASensorValueColor.h"

@implementation RLASensorValueColor

#pragma mark - Public API

- (UIColor *)color
{
    NSDictionary* dict = self.dictionary;
    CGFloat const r = [[dict[@"clr"] valueForKey:@"r"] floatValue];
    CGFloat const g = [[dict[@"clr"] valueForKey:@"g"] floatValue];
    CGFloat const b = [[dict[@"clr"] valueForKey:@"b"] floatValue];
    
    float red   = (float)r;
    float green = (float)g;
    float blue  = (float)b;
    
    // See TCS3771 datasheet, TAOS110A − MARCH 2011, pp 7.
    // TODO: Improve this calibration. See Danial M.
    
    // Relative correction
    red *= 0.6;
    
    // Normalize
    float max = MAX(red,MAX(green,blue));
    red   /= max;
    green /= max;
    blue  /= max;
    return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:1.0f];
}

@end
