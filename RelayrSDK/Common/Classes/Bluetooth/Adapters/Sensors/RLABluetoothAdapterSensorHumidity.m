#import "RLABluetoothAdapterSensorHumidity.h"   // Header

@implementation RLABluetoothAdapterSensorHumidity

#pragma mark - Public API

- (NSDictionary *)dictionary
{
    // Fetch super dict
    NSMutableDictionary* superDict = super.dictionary.mutableCopy;
    
    // Convert sensor data
    NSData* data = self.data;
    RLAErrorAssertTrueAndReturnNil((data.length == 4), RLAErrorCodeMissingExpectedValue);
    const uint8_t* buf = [data bytes];
    uint16_t h = (buf[3] << 8) | buf[2];
    float hh = (float)h / 100.0f;
    
    // Append values to super dict
    NSDictionary* dict = @{ @"hum": @(hh) };
    [superDict addEntriesFromDictionary:dict];
    
    return [superDict copy];
}

@end
