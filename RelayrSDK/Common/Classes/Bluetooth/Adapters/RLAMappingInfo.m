#import "RLAMappingInfo.h"  // Header

@implementation RLAMappingInfo

#pragma mark - Public API

- (instancetype)initWithSensorClass:(Class)sensorClass adapterClass:(Class)adapterClass serviceUUIDs:(NSArray *)serviceUUIDs characteristicUUIDs:(NSArray *)characteristicUUIDs;
{
    RLAErrorAssertTrueAndReturnNil(sensorClass, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(adapterClass, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(serviceUUIDs, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(characteristicUUIDs, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self) {
        _sensorClass = sensorClass;
        _adapterClass = adapterClass;
        _serviceUUIDs = serviceUUIDs;
        _characteristicUUIDs = characteristicUUIDs;
    }
    return self;
}

- (instancetype)initWithOutputClass:(Class)outputClass
{
    RLAErrorAssertTrueAndReturnNil(outputClass, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self) {
        _outputClass = outputClass;
    }
    return self;
}

@end
