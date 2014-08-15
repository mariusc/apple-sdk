// Header
#import "RLADevice.h"

// Relayr.framework
// Protocols
#import "RLASensorDelegate.h"
#import "RLADevicePrivateAPI.h"
// Classes
#import "RLASensor.h"
#import "RLAOutput.h"

@interface RLADevice() <RLADevicePrivateAPI, RLASensorDelegate>

#pragma mark - Private properties (Readwrite)

@property (nonatomic, copy, readwrite) NSString *RLA_uid;
@property (nonatomic, copy, readwrite) NSString *RLA_modelID;
@property (nonatomic, copy, readwrite) NSString *RLA_secret;
@property (nonatomic, copy, readwrite) NSString *RLA_name;
@property (nonatomic, copy, readwrite) NSString *RLA_manufacturer;
@property (nonatomic, copy, readwrite) NSArray *RLA_sensors;
@property (nonatomic, copy, readwrite) NSArray *RLA_outputs;

@end

@implementation RLADevice

#pragma mark - <RLADevicePrivateAPI>

#pragma mark - Getters

#pragma mark - Credentials

- (NSString *)secret
{
  return self.RLA_secret;
}

#pragma mark - Setters

#pragma mark - Identification

- (void)setUid:(NSString *)uid
{
  self.RLA_uid = uid;
}

- (void)setModelID:(NSString *)modelID
{
  self.RLA_modelID = modelID;
}

#pragma mark - Info

- (void)setName:(NSString *)name
{
  self.RLA_name = name;
}

- (void)setManufacturer:(NSString *)manufacturer
{
  self.RLA_manufacturer = manufacturer;
}

#pragma mark - Credentials

- (void)setSecret:(NSString *)secret
{
  self.RLA_secret = secret;
}

#pragma mark - Sensors

- (void)setSensors:(NSArray *)sensors
{
  self.RLA_sensors = sensors;
}

#pragma mark - Outputs

- (void)setOutputs:(NSArray *)outputs
{
  self.RLA_outputs = outputs;
}

#pragma mark - <RLADeviceAPI>

#pragma mark - Getters

#pragma mark - Identification

- (NSString *)uid
{
  return self.RLA_uid;
}

- (NSString *)modelID
{
  return self.RLA_modelID;
}

#pragma mark - Info

- (NSString *)name
{
  return self.RLA_name;
}

- (NSString *)manufacturer
{
  return self.RLA_manufacturer;
}

#pragma mark - Sensors

- (NSArray *)sensors
{
  return self.RLA_sensors;
}

- (RLASensor *)sensorOfClass:(Class)class
{
  for (RLASensor *sensor in [self sensors]) {
    if ([sensor isMemberOfClass:class]) return sensor;
  }
  return nil;
}

- (NSArray *)sensorsOfClass:(Class)class
{
  NSMutableArray *mSensors = [NSMutableArray array];
  for (RLASensor *sensor in [self sensors]) {
    if ([sensor isMemberOfClass:class]) [mSensors addObject:sensor];
  }
  if ([mSensors count]) {
    return [mSensors copy];
  } else {
    return nil;
  }
}

#pragma mark - Outputs

- (NSArray *)outputs
{
  return self.RLA_outputs;
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

#pragma mark -  <RLASensorDelegate>

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

#pragma mark - <NSObject>

- (NSString *)description
{
  NSMutableString *mStr = [NSMutableString string];
  [mStr appendFormat:@"<%@: %p>\n", NSStringFromClass([self class]), self];
  [mStr appendFormat:@"uid         : %@", self.RLA_uid];
  [mStr appendString:@"\n"];
  [mStr appendFormat:@"name        : %@", self.RLA_name];
  [mStr appendString:@"\n"];
  [mStr appendFormat:@"manufacturer: %@", self.RLA_manufacturer];
  
  for (RLASensor *sensor in self.RLA_sensors) {
    [mStr appendFormat:@"\nSensor: %@", sensor];
  }
  
  for (RLAOutput *output in self.RLA_outputs) {
    [mStr appendFormat:@"\nOutput: %@", output];
  }
  
  [mStr appendString:@"\n"];
  
  return [mStr copy];
}

@end
