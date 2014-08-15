// Header
#import "RLAWunderbarTemperatureSensorBluetoothAdapter.h"

@implementation RLAWunderbarTemperatureSensorBluetoothAdapter

#pragma mark - Conversion

- (NSDictionary *)dictionary
{
  // Fetch super dict
  NSMutableDictionary *mSuperDict = [[super dictionary] mutableCopy];
  
  // Convert sensor data
  NSData *data = [self data];
  RLAErrorAssertTrueAndReturnNil(([data length] == 4), RLAErrorCodeMissingExpectedValue);
  const uint8_t* buf = [data bytes];
  uint16_t t = (buf[1] << 8) | buf[0];
  float tt = (float)t / 100.0f;

  // Append values to super dict
  NSDictionary *dict = @{@"temp": @(tt)};
  [mSuperDict addEntriesFromDictionary:dict];
  
  return [mSuperDict copy];
}

@end
