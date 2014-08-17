#import "RLAHandlerInfo.h"  // Header

@implementation RLAHandlerInfo

#pragma mark - Template methods

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Designated initializer

- (instancetype)initWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID handler:(void (^)(NSData*, NSError*))handler
{
    RLAErrorAssertTrueAndReturnNil(serviceUUID, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(characteristicUUID, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(handler, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self) {
        _serviceUUID = serviceUUID;
        _characteristicUUID = characteristicUUID;
        _handler = handler;
    }
    return self;
}

@end
