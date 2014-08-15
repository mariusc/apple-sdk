#import "RLADevice.h"           // Header
#import "RLADevice_Setup.h"     // Relayr.framework
//#import "RLASensorDelegate.h"   // Relayr.framework
//#import "RLASensor.h"           // Relayr.framework
//#import "RLAOutput.h"           // Relayr.framework

@interface RLADevice() //<RLASensorDelegate>
@end

@implementation RLADevice

#pragma mark - Public API

- (RLASensor*)sensorOfClass:(Class)class
{
    for (RLASensor* sensor in _sensors)
    {
        if ([sensor isMemberOfClass:class]) { return sensor; }
    }
    
    return nil;
}

- (NSArray*)sensorsOfClass:(Class)class
{
    NSMutableArray* mSensors = [NSMutableArray array];
    for (RLASensor* sensor in _sensors)
    {
        if ([sensor isMemberOfClass:class]) { [mSensors addObject:sensor]; }
    }
    
    return (mSensors.count) ? [mSensors copy] : nil;
}

#pragma mark - Monitoring

- (BOOL)isConnected
{
    return NO;
}

- (void)connectWithSuccessHandler:(void(^)(NSError*))handler
{
    RLAAssertAbstractMethod;
}

- (void)disconnectWithSuccessHandler:(void(^)(NSError*))handler
{
    RLAAssertAbstractMethod;
}

- (void)setErrorHandler:(void(^)(NSError*))handler
{
    RLAAssertAbstractMethod;
}

#pragma mark RLASensorDelegate

- (void)sensorDidAddObserver:(RLASensor *)sensor
{
    // This method is suppposed to be overridden in case further actions are
    // needed when objects subscribe as observers for sensors
}

- (void)sensorDidRemoveObserver:(RLASensor *)sensor
{
    // This method is suppposed to be overridden in case further actions are
    // needed when objects unsubscribe as observers for sensors
}

#pragma mark NSObject

- (NSString*)description
{
    NSMutableString* string = [NSMutableString string];
    [string appendFormat:@"<%@: %p>\n", NSStringFromClass([self class]), self];
    [string appendFormat:@"uid         : %@", _uid];
    [string appendString:@"\n"];
    [string appendFormat:@"name        : %@", _name];
    [string appendString:@"\n"];
    [string appendFormat:@"manufacturer: %@", _manufacturer];
    
    for (RLASensor* sensor in _sensors) { [string appendFormat:@"\nSensor: %@", sensor]; }
    for (RLAOutput* output in _outputs) { [string appendFormat:@"\nOutput: %@", output]; }
    
    [string appendString:@"\n"];
    return [string copy];
}

@end
