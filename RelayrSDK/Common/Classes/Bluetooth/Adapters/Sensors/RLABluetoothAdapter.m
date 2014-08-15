#import "RLABluetoothAdapter.h"  // Header

@implementation RLABluetoothAdapter

#pragma mark - Public API

- (instancetype)init
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (instancetype)initWithData:(NSData*)data
{
    RLAErrorAssertTrueAndReturnNil(data, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

#pragma mark - Conversion

- (NSDictionary*)dictionary
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* string = [NSString stringWithFormat:@"%@", @(interval)];
    return @{ @"ts" : string };
}

@end
