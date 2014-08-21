#import "RLABluetoothAdapterSensorTemperature.h" // Header

@implementation RLABluetoothAdapterSensorTemperature

#pragma mark - Public API

- (NSDictionary*)dictionary
{
  // Fetch super dict
  NSMutableDictionary *mSuperDict = super.dictionary.mutableCopy;
  
  // Convert sensor data
  NSData* data = self.data;
  RLAErrorAssertTrueAndReturnNil(([data length] == 4), RLAErrorCodeMissingExpectedValue);
  
  uint8_t const* buf = data.bytes;
  uint16_t t = (buf[1] << 8) | buf[0];
  float tt = (float)t / 100.0f;

  // Append values to super dict
  NSDictionary *dict = @{@"temp": @(tt)};
  [mSuperDict addEntriesFromDictionary:dict];
  
  return [mSuperDict copy];
}

@end
