#import "RLAAPIService+Wunderbar.h" // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrTransmitter_Setup.h" // Relayr.framework (Private)
#import "RLAAPIService+Parsing.h"   // Relayr.framework (Service/API)
#import "RLAAPIRequest.h"           // Relayr.framework (Service/API)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)
#import "WunderbarConstants.h"      // Relayr.framework (Wunderbar)

@implementation RLAAPIService (Wunderbar)

#pragma mark - Public API

- (void)registerWunderbar:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_WunderbarRegistration(self.user.uid);
    
    [request executeInHTTPMode:kRLAAPIRequestModePOST completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_WunderbarRegistration, nil);
        
        RelayrTransmitter* result = [RLAAPIService parseWunderbarFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)deleteWunder:(RelayrTransmitter*)trasnmitter completion:(void (^)(NSError* error))completion
{
    RLAAPIRequest* request = [[RLAAPIRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    request.relativePath = Web_RequestRelativePath_WunderbarDeletion(trasnmitter.uid);
    
    [request executeInHTTPMode:kRLAAPIRequestModeDELETE completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return (responseCode.unsignedIntegerValue != Web_RequestResponseCode_WunderbarDeletion) ? completion(RelayrErrorWebRequestFailure) : completion(nil);
    }];
}

#pragma mark - Private methods

+ (RelayrTransmitter*)parseWunderbarFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
    RelayrTransmitter* masterModule = [RLAAPIService parseTransmitterFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarMasterModule]];
    if (!masterModule) { return nil; }
    
    NSMutableSet* devices = [NSMutableSet setWithCapacity:6];
    
    RelayrDevice* gyroscope = [RLAAPIService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarGyroscope]];
    if (gyroscope) { [devices addObject:gyroscope]; }
    
    RelayrDevice* light = [RLAAPIService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarLight]];
    if (light) { [devices addObject:light]; }
    
    RelayrDevice* mic = [RLAAPIService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarMicrophone]];
    if (mic) { [devices addObject:mic]; }
    
    RelayrDevice* thermometer = [RLAAPIService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarThermomether]];
    if (thermometer) { [devices addObject:thermometer]; }
    
    RelayrDevice* infrared = [RLAAPIService parseDeviceFromJSONDictionary:jsonDict[Web_ResopndKey_WunderbarInfrared]];
    if (infrared) { [devices addObject:infrared]; }
    
    RelayrDevice* bridge = [RLAAPIService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarBridge]];
    if (bridge) { [devices addObject:bridge]; }
    
    masterModule.devices = [NSSet setWithSet:devices];
    return masterModule;
}

@end
