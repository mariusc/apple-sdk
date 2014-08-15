// Header
#import "RLAWunderbarProximitySensorBluetoothAdapter.h"

@implementation RLAWunderbarProximitySensorBluetoothAdapter

#pragma mark - Conversion

- (NSDictionary *)dictionary
{
  // Fetch super dict
  NSMutableDictionary *mSuperDict = [[super dictionary] mutableCopy];
  
  // Convert sensor data
  NSData *data = [self data];
  RLAErrorAssertTrueAndReturnNil(([data length] == 10), RLAErrorCodeMissingExpectedValue);
  
  const uint8_t* buf = [data bytes];
  uint16_t p = (buf[9] << 8) | buf[8];
  
  // Append values to super dict
  NSDictionary *dict = @{@"prox": @(p)};
  [mSuperDict addEntriesFromDictionary:dict];
  
  return [mSuperDict copy];
}

@end
