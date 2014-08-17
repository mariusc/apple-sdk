#import "RLACredentialsWunderbar.h"

@implementation RLACredentialsWunderbar

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithWunderbarUID:(NSString*)uid wunderbarSecret:(NSString*)secret htu:(RLADevice*)htu gyro:(RLADevice*)gyro light:(RLADevice*)light microphone:(RLADevice*)microphone bridge:(RLADevice*)bridge ir:(RLADevice*)ir;
{
    RLAErrorAssertTrueAndReturnNil (uid, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil (secret, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil (htu, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil (gyro, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil (light, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil (microphone, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil (bridge, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil (ir, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self)
    {
        _uid = uid;
        _secret = secret;
        _htu = htu;
        _gyro = gyro;
        _light = light;
        _microphone = microphone;
        _bridge = bridge;
        _ir = ir;
    }
    return self;
}

- (RLADevice*)deviceWithModelID:(NSString*)modelID
{
    NSArray* devices = @[_htu, _gyro, _light, _microphone, _bridge, _ir];
    
    for (RLADevice* device in devices)
    {
        if ([device.modelID isEqualToString:modelID]) { return device; }
    }
    
    return nil;
}

#pragma mark NSObject

- (NSString*)description
{
    NSMutableString* tmpStr = [NSMutableString string];
    [tmpStr appendFormat: @"uid: %@\n", _uid];
    [tmpStr appendFormat: @"secret: %@\n", _secret];
    [tmpStr appendFormat: @"htu: %@\n", _htu.name];
    [tmpStr appendFormat: @"gyro: %@\n", _gyro.name];
    [tmpStr appendFormat: @"light: %@\n", _light.name];
    [tmpStr appendFormat: @"microphone: %@\n", _microphone.name];
    [tmpStr appendFormat: @"bridge: %@\n", _bridge.name];
    [tmpStr appendFormat: @"ir: %@\n", _ir.name];
    
    return [NSString stringWithString:tmpStr];
}

@end
