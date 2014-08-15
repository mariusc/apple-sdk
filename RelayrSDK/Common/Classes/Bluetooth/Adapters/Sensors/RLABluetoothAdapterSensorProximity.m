#import "RLABluetoothAdapterSensorProximity.h" // Header

@implementation RLABluetoothAdapterSensorProximity

#pragma mark - Public API

- (NSDictionary*)dictionary
{
  // Fetch super dict
  NSMutableDictionary *mSuperDict = super.dictionary.mutableCopy;
  
  // Convert sensor data
  NSData* data = self.data;
  RLAErrorAssertTrueAndReturnNil(([data length] == 10), RLAErrorCodeMissingExpectedValue);
  
  uint8_t const* buf = [data bytes];
  uint16_t p = (buf[9] << 8) | buf[8];
  
  // Append values to super dict
  NSDictionary* dict = @{@"prox": @(p)};
  [mSuperDict addEntriesFromDictionary:dict];
  
  return [mSuperDict copy];
}

@end
