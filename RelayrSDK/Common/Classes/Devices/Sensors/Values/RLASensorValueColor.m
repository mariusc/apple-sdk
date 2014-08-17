#import "RLASensorValueColor.h"   // Header

@implementation RLASensorValueColor

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#warning Improve this calibration. See Danial M.
- (UIColor *)color
{
    NSDictionary* dict = self.dictionary;
    CGFloat r = [[[dict valueForKey:@"clr"] valueForKey:@"r"] floatValue];
    CGFloat g = [[[dict valueForKey:@"clr"] valueForKey:@"g"] floatValue];
    CGFloat b = [[[dict valueForKey:@"clr"] valueForKey:@"b"] floatValue];
    
    float red   = (float)r;
    float green = (float)g;
    float blue  = (float)b;
    
    // See TCS3771 datasheet, TAOS110A − MARCH 2011, pp 7.
    
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
