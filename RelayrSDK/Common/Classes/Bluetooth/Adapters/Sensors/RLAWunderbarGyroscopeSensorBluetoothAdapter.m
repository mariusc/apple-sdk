#import "RLAWunderbarGyroscopeSensorBluetoothAdapter.h"     // Header

@implementation RLAWunderbarGyroscopeSensorBluetoothAdapter

#pragma mark - Conversion

- (NSDictionary *)dictionary
{
  // Fetch super dict
  NSMutableDictionary *mSuperDict = [[super dictionary] mutableCopy];
  
  // Convert sensor data
  NSData *data = [self data];
  RLAErrorAssertTrueAndReturnNil(([data length] == 18), RLAErrorCodeMissingExpectedValue);
  
  const uint8_t* buf = [data bytes];
  uint16_t x = (buf[0] << 8) | buf[1];
  uint16_t y = (buf[2] << 8) | buf[3];
  uint16_t z = (buf[4] << 8) | buf[5];
  
  if (x > 32768) x = -(x - 32769);
  if (y > 32768) y = -(y - 32769);
  if (z > 32768) z = -(z - 32769);

  float xx = (float)x;
  float yy = (float)y;
  float zz = (float)z;
  
  xx = xx / 131.0f;
  yy = yy / 131.0f;
  zz = zz / 131.0f;
  
  // Append values to super dict
  NSDictionary *dict = @{@"gyro": @{@"x": @(xx), @"y": @(yy), @"z": @(zz)}};
  [mSuperDict addEntriesFromDictionary:dict];
  
  return [mSuperDict copy];
}

@end
