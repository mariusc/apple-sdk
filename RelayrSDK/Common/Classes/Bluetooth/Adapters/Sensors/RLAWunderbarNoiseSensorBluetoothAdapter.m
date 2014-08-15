// Header
#import "RLAWunderbarNoiseSensorBluetoothAdapter.h"

@implementation RLAWunderbarNoiseSensorBluetoothAdapter

#pragma mark - Conversion

- (NSDictionary *)dictionary
{
  // Fetch super dict
  NSMutableDictionary *mSuperDict = [[super dictionary] mutableCopy];
  
  // Convert sensor data
  NSData *data = [self data];
  RLAErrorAssertTrueAndReturnNil(([data length] == 2), RLAErrorCodeMissingExpectedValue);
  const uint8_t* buf = [data bytes];
  uint16_t l = (buf[1] << 4) | buf[0];
  float ll = (float)l / 100.0f;

  // Append values to super dict
  NSDictionary *dict = @{@"snd_level": @(ll)};
  [mSuperDict addEntriesFromDictionary:dict];
  
  return [mSuperDict copy];
}

@end
