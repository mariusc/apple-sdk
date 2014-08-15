#import "RLABluetoothAdapterSensorNoise.h"     // Header

@implementation RLABluetoothAdapterSensorNoise

#pragma mark - Public API

- (NSDictionary*)dictionary
{
    // Fetch super dict
    NSMutableDictionary* superDict = [[super dictionary] mutableCopy];
    
    // Convert sensor data
    NSData* data = self.data;
    RLAErrorAssertTrueAndReturnNil((data.length == 2), RLAErrorCodeMissingExpectedValue);
    uint8_t const* buf = data.bytes;
    uint16_t l = (buf[1] << 4) | buf[0];
    float ll = (float)l / 100.0f;
    
    // Append values to super dict
    NSDictionary* dict = @{@"snd_level": @(ll)};
    [superDict addEntriesFromDictionary:dict];
    
    return [superDict copy];
}

@end
