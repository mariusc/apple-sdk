#import "RLABluetoothAdapterSensorColor.h"     // Header

@implementation RLABluetoothAdapterSensorColor

#pragma mark - Public API

#warning Color computing code must be changed.
- (NSDictionary*)dictionary
{
    // Fetch super dict
    NSMutableDictionary* superDict = [super.dictionary mutableCopy];
    
    // Convert sensor data
    NSData* data = self.data;
    RLAErrorAssertTrueAndReturnNil((data.length == 10), RLAErrorCodeMissingExpectedValue);
    
    uint8_t const* buf = data.bytes;
    uint16_t r = (buf[3] << 8) | buf[2];
    uint16_t g = (buf[5] << 8) | buf[4];
    uint16_t b = (buf[7] << 8) | buf[6];
    
    float rr = (float)r;
    float gg = (float)g;
    float bb = (float)b;
    
    // Relative correction
    rr *= 2.0/3.0;
    
    // Normalize
    float max = MAX(rr,MAX(gg,bb));
    rr /= max;
    gg /= max;
    bb /= max;
    
    // Append values to super dict
    NSDictionary* dict = @{ @"clr": @{@"r": @(rr), @"g": @(gg), @"b": @(bb)} };
    [superDict addEntriesFromDictionary:dict];
    
    return [superDict copy];
}

@end
