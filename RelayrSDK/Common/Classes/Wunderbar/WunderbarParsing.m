#import "WunderbarParsing.h"        // Relayr (Wunderbar)

#import "RelayrDevice.h"            // Relayr (Public)
#import "RLAService.h"              // Relayr (Service)
#import "RLAMQTTService.h"          // Relayr (Service/MQTT)
#import "RLABLEService.h"           // Relayr (Service/BLE)

#import "WunderbarConstants.h"      // Relayr (Wunderbar)

@implementation WunderbarParsing

+ (NSDictionary*)parseData:(NSData*)data fromService:(id<RLAService>)service device:(RelayrDevice*)device atDate:(__autoreleasing NSDate**)datePtr
{
    NSString* modelID = device.modelID;
    if (!data || !service || !modelID.length) { return nil; }
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) { return nil; }
    
    NSDictionary* result;
    if ([service isKindOfClass:[RLAMQTTService class]])
    {
        if ([modelID isEqualToString:Wunderbar_devicemodel_gyroscope])
        {
            NSDictionary* acc = json[dWunderbar_parsing_accelerometer];
            NSDictionary* gyr = json[dWunderbar_parsing_gyroscope];
            result = @{ dWunderbar_meaning_acceleration : @[acc[dWunderbar_parsing_x], acc[dWunderbar_parsing_y], acc[dWunderbar_parsing_z]],
                        dWunderbar_meaning_angularSpeed : @[gyr[dWunderbar_parsing_x], gyr[dWunderbar_parsing_y], gyr[dWunderbar_parsing_z]] };
        }
        else if ([modelID isEqualToString:Wunderbar_devicemodel_thermometer])
        {
            result = @{ dWunderbar_meaning_temperature : json[dWunderbar_parsing_temperature],
                        dWunderbar_meaning_humidity : json[dWunderbar_parsing_humidity] };
        }
        else if ([modelID isEqualToString:Wunderbar_devicemodel_light])
        {
            NSDictionary* clr = json[dWunderbar_parsing_color];
            result = @{ dWunderbar_meaning_luminosity : json[dWunderbar_parsing_light],
                        dWunderbar_meaning_color : @[clr[dWunderbar_parsing_r], clr[dWunderbar_parsing_g], clr[dWunderbar_parsing_b]],
                        dWunderbar_meaning_proximity : json[dWunderbar_parsing_proximity] };
        }
        else if ([modelID isEqualToString:Wunderbar_devicemodel_microphone])
        {
            result = @{ dWunderbar_meaning_noiseLevel : json[dWunderbar_parsing_sound] };
        }
        else { return nil; }
        
        if (datePtr != NULL) { *datePtr = [NSDate dateWithTimeIntervalSince1970:((NSNumber*)json[dWunderbar_parsing_timestamp]).doubleValue]; }
    }
    else if ([service isKindOfClass:[RLABLEService class]])
    {
        if ([modelID isEqualToString:Wunderbar_devicemodel_gyroscope])
        {
            
        }
        else if ([modelID isEqualToString:Wunderbar_devicemodel_light])
        {
            
        }
        else if ([modelID isEqualToString:Wunderbar_devicemodel_microphone])
        {
            
        }
        else if ([modelID isEqualToString:Wunderbar_devicemodel_thermometer])
        {
            
        }
        else { return nil; }
    }
    
    return result;
}

@end
