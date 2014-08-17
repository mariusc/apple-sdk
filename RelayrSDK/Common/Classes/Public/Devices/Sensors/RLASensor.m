#import "RLASensor.h"
#import "RLASensor_Setup.h"
#import "RLASensorValue.h"
#import "RLASensorDelegate.h"

@implementation RLASensor

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark NSCopying

#warning WTF
//- (instancetype)copyWithZone:(NSZone*)zone
//{
//    typeof(self) copy = [[self.class alloc] init];
//    [copy setSensorValue:[self.value copy]];
//    return copy;
//    return nil;
//}

#pragma mark NSKeyValueObserving

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context
{
    // Order of the two method calls is important here! When calling the delegate before actually forwarding the call to super the delegate is able to check if this is the first subscriber by checking @selector(observationInfo) on the sensor
    if (_delegate) { [_delegate sensorDidAddObserver:self]; }
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)removeObserver:(NSObject*)observer forKeyPath:(NSString*)keyPath
{
    // Order of the two method calls is important here! When calling the delegate before actually forwarding the call to super the delegate is able to check if this is the last subscriber by checking @selector(observationInfo) on the sensor
    [super removeObserver:observer forKeyPath:keyPath];
    if (_delegate) { [_delegate sensorDidRemoveObserver:self]; }
}

#pragma mark - Extensions

#pragma mark RLASensor_Setup

- (instancetype)initWithMeaning:(NSString*)meaning andUnit:(NSString*)unit
{
    RLAErrorAssertTrueAndReturnNil(meaning, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(unit, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self)
    {
        _meaning = meaning;
        _unit = unit;
    }
    return self;
}

- (Class)sensorValueClass
{
    return [RLASensorValue class];
}

- (void)setValue:(RLASensorValue*)value
{
    NSString* key = @"value";
    
    [self willChangeValueForKey:key];
    _value = value;
    [self didChangeValueForKey:key];
}

@end
