#import "RLABluetoothAdapterSensorAccelerometer.h" // Header

@implementation RLABluetoothAdapterSensorAccelerometer

#pragma mark - Public API

- (NSDictionary*)dictionary
{
    // Fetch super dict
    NSMutableDictionary* superDict = super.dictionary.mutableCopy;
    
    // Convert sensor data
    NSData* data = self.data;
    RLAErrorAssertTrueAndReturnNil( (data.length == 18), RLAErrorCodeMissingExpectedValue);
    
    uint8_t const* buf = data.bytes;
    uint16_t x =  (buf[6] << 8) | buf[7];
    uint16_t y =  (buf[8] << 8) | buf[9];
    uint16_t z = (buf[10] << 8) | buf[11];
    
    if (x > 32768) x = -(x - 32769);
    if (y > 32768) y = -(y - 32769);
    if (z > 32768) z = -(z - 32769);
    
    float xx = (float)x;
    float yy = (float)y;
    float zz = (float)z;
    
    xx = xx / 16384.0f;
    yy = yy / 16384.0f;
    zz = zz / 16384.0f;
    
    // Append values to super dict
    NSDictionary* dict = @{ @"accel": @{@"x": @(xx), @"y": @(yy), @"z": @(zz)} };
    [superDict addEntriesFromDictionary:dict];
    
    return [superDict copy];
}

@end
