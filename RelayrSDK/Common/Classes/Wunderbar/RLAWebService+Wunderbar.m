#import "RLAWebService+Wunderbar.h" // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrTransmitter_Setup.h" // Relayr.framework (Private)
#import "RLAWebService+Parsing.h"   // Relayr.framework (Web)
#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)
#import "WunderbarConstants.h"      // Relayr.framework (Wunderbar)

@implementation RLAWebService (Wunderbar)

#pragma mark - Public API

- (void)registerWunderbar:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_WunderbarRegistration(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_WunderbarRegistration, nil);
        
        RelayrTransmitter* result = [RLAWebService parseWunderbarFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

#pragma mark - Private methods

+ (RelayrTransmitter*)parseWunderbarFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
    RelayrTransmitter* masterModule = [RLAWebService parseTransmitterFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarMasterModule]];
    if (!masterModule) { return nil; }
    
    NSMutableSet* devices = [NSMutableSet setWithCapacity:6];
    
    RelayrDevice* gyroscope = [RLAWebService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarGyroscope]];
    if (gyroscope) { [devices addObject:gyroscope]; }
    
    RelayrDevice* light = [RLAWebService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarLight]];
    if (light) { [devices addObject:light]; }
    
    RelayrDevice* mic = [RLAWebService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarMicrophone]];
    if (mic) { [devices addObject:mic]; }
    
    RelayrDevice* thermometer = [RLAWebService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarThermomether]];
    if (thermometer) { [devices addObject:thermometer]; }
    
    RelayrDevice* infrared = [RLAWebService parseDeviceFromJSONDictionary:jsonDict[Web_ResopndKey_WunderbarInfrared]];
    if (infrared) { [devices addObject:infrared]; }
    
    RelayrDevice* bridge = [RLAWebService parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarBridge]];
    if (bridge) { [devices addObject:bridge]; }
    
    masterModule.devices = [NSSet setWithSet:devices];
    return masterModule;
}

@end
