@import CoreBluetooth;                                  // Apple
#import "RLABluetoothPeripheralRequestRegistration.h"   // Header
#import "RLACBUUID.h"                                   // Relayr.framework
#import "RLAData.h"                                     // Relayr.framework (Utility)
#import "RLAWunderbarCredentials.h"                     // Relayr.framework (Domain object)

NSString const* serviceName                         = @"WunderbarApp";
NSString const* serviceUUID                         = @"2000";
NSString const* characteristicHtuGyroLightUUID      = @"2010";
NSString const* characteristicMicBridgeIRUUID       = @"2011";
NSString const* characteristicWifiSSIDUUID          = @"2012";
NSString const* characteristicWifiPasswordUUID      = @"2013";
NSString const* characteristicWunderbarIDUUID       = @"2014";
NSString const* characteristicWunderbarSecretUUID   = @"2015";
NSString const* characteristicWUnderbarURLUUID      = @"2016";

@implementation RLABluetoothPeripheralRequestRegistration
{
    RLAWunderbarCredentials* _credentials;
    NSString* _wifiSSID;
    NSString* _wifiPassword;
    NSMutableSet* _readCharacteristicsUUIDs;
}

#pragma mark - Public API

- (instancetype)initWithCredentials:(RLAWunderbarCredentials *)credentials wifiSSID:(NSString *)ssid wifiPassword:(NSString *)password
{
    RLAErrorAssertTrueAndReturnNil(credentials, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(ssid, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(password, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self)
    {
        _readCharacteristicsUUIDs = [NSMutableSet set];     // Setup private vars
        _credentials = credentials;                         // Store arguments
        _wifiSSID = ssid;
        _wifiPassword = password;
    }
    return self;
}

#pragma mark Superclass methods

- (NSString*)name
{
    return serviceName;
}

- (NSArray*)services
{
    // Characteristic values
    NSDictionary *dict = @{
      // Passkey for Humidity, Gyroscope, and light sensors (size: 19 bytes including update mask).
      // It contains the passkeys for the HTU, GYRO, and LIGHT sensors, in ASCII format, and an update mask. The update mask is a bit mask of three update flags: one for each passkey. The lowest three bits of the value determine which passkey should be updated.
      characteristicHtuGyroLightUUID : [self dataWithString:_credentials.htu.secret andString:_credentials.gyro.secret andString:_credentials.light.secret andFlag:0x07], // Update all three sensors
      
      // Passkey for Microphone, bridge, and IR sensor (size: 19 bytes including update mask).
      // It contains the passkeys for the MICROPHONE, BRIDGE, and IR sensors, in ASCII format, and an update mask. Like the HTU_GYRO_LIGHT passkey the update mask is a bit mask of three update flags.
      characteristicMicBridgeIRUUID : [self dataWithString:_credentials.microphone.secret andString:_credentials.bridge.secret andString:_credentials.ir.secret andFlag:0x07], // Update all three sensors
      
      // SSID of WiFi network (size: 20 bytes including update flag).
      // It contains the Wifi SSID in ASCII format and an update flag. The value must be 20 characters long and finish with the update flag, therefore it is padded with zeros until it is the appropriate length.
      characteristicWifiSSIDUUID : [self dataWithString:_wifiSSID andFlag:0x01 paddedToLength:20],
      
      // Password of WiFi network (size: 20 bytes including update flag).
      // Description: Contains the Wifi password in ASCII format and an update flag. The value must be 20 bytes long and finish with the update flag, therefore it is also padded like the SSID.
      characteristicWifiPasswordUUID : [self dataWithString:_wifiPassword andFlag:0x01 paddedToLength:20],
      
      // Wunderbar ID (size: 17 bytes including update flag).
      // Description: Contains the (short) UUID of the WunderBar and an update flag.
      characteristicWunderbarIDUUID : [self dataWithLongUUID:_credentials.uid andFlag:0x01],
      
      // Wunderbar secret (size: 13 bytes including the update flag).
      // Description: Contains the secret to conncet a particular Wunderbar to MQTT.
      characteristicWunderbarSecretUUID : [self dataWithString:_credentials.secret andFlag:0x01 paddedToLength:13],
      
      // Wunderbar URL (size: 20 bytes, terminating character and update_flag included).
      // Description: Contains the url of the MQTT server.
      characteristicWUnderbarURLUUID : [self dataWithString:@"mqtt.relayr.io" andFlag:0x01 paddedToLength:20] };
    
    // Setup characteristics
    NSMutableArray* array = [NSMutableArray array];
    for (NSString* key in [dict allKeys])
    {
        CBUUID* cbuuid = [CBUUID UUIDWithString:key];
        
        NSData* data = dict[key];
        if ([data isKindOfClass:[NSString class]])
        {
            data = [(NSString*)data dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        CBMutableCharacteristic* characterisitc = [[CBMutableCharacteristic alloc] initWithType:cbuuid properties:CBCharacteristicPropertyRead value: data permissions:CBAttributePermissionsReadable];
        [array addObject:characterisitc];
    }
    
    // Setup service
    CBUUID* uuid = [CBUUID UUIDWithString:serviceUUID];
    CBMutableService* service = [[CBMutableService alloc] initWithType:uuid primary:YES];
    service.characteristics = [array copy];
    
    return @[ service ];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager*)peripheral didReceiveReadRequest:(CBATTRequest*)request
{
    [super peripheralManager:peripheral didReceiveReadRequest:request];
    
    // Request is finished when all characteristics have been read.
    // Count characteristics
    NSUInteger count = 0;
    NSArray* services = self.services;
    for (CBService* service in services)
    {
        count += service.characteristics.count;
    }
    
    // Store characteristic UUID
    
    NSString* uuid = [RLACBUUID UUIDStringWithCBUUID:request.characteristic.UUID];
    [_readCharacteristicsUUIDs addObject:uuid];
    
    // Invoke completion handler if finished
    if (_readCharacteristicsUUIDs.count == count)
    {
        [self.manager stopAdvertising];
        self.completion(nil);
    }
}

#pragma mark - Private methods

- (NSData *)dataWithString:(NSString *)str1 andString:(NSString *)str2 andString:(NSString *)str3 andFlag:(int8_t)flag
{
    NSMutableData* data = [NSMutableData data];
    [data appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[str3 dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:&flag length:1];
    return [data copy];
}

- (NSData*)dataWithString:(NSString*)str andFlag:(int8_t)flag paddedToLength:(NSUInteger)length
{
    NSMutableData* data = [NSMutableData data];
    [data appendData:[str dataUsingEncoding:NSASCIIStringEncoding]];
    NSUInteger padding = length - 1 - [str length]; // Remember to subtract 1 byte for the flag
    [data increaseLengthBy:padding];
    [data appendBytes:&flag length:1];
    return [data copy];
}

- (NSData*)dataWithLongUUID:(NSString*)longUUID andFlag:(int8_t)flag
{
    NSMutableData* data = [NSMutableData data];
    [mData appendData:[RLAData shortUidWithLongUidString:longUUID]];
    [data appendBytes:&flag length:1];
    return [data copy];
}

@end
