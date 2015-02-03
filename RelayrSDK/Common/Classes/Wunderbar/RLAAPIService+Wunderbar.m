#import "RLAAPIService+Wunderbar.h" // Header

#import "RelayrUser.h"              // Relayr (Public)
#import "RelayrTransmitter.h"       // Relayr (Public)
#import "RelayrTransmitter_Setup.h" // Relayr (Private)
#import "RLAAPIConstants.h"         // Relayr (Service/API)
#import "RLAAPIService+Parsing.h"   // Relayr (Service/API)
#import "RelayrErrors.h"            // Relayr (Utilities)
#import "WunderbarConstants.h"      // Relayr (Wunderbar)

@implementation RLAAPIService (Wunderbar)

#pragma mark - Public API

- (void)registerWunderbar:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:Web_RequestRelativePath_WunderbarRegistration(self.user.uid)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(Web_RequestResponseCode_WunderbarRegistration, nil);
        
        RelayrTransmitter* result = [self parseWunderbarFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)deleteWunder:(RelayrTransmitter*)trasnmitter completion:(void (^)(NSError* error))completion
{
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:Web_RequestRelativePath_WunderbarDeletion(trasnmitter.uid)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeDELETE authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode != Web_RequestResponseCode_WunderbarDeletion) ? RelayrErrorWebRequestFailure : nil );
    }];
    [task resume];
}

#pragma mark - Private methods

- (RelayrTransmitter*)parseWunderbarFromJSONDictionary:(NSDictionary*)jsonDict
{
    if (!jsonDict) { return nil; }
    
    RelayrTransmitter* masterModule = [self parseTransmitterFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarMasterModule]];
    if (!masterModule) { return nil; }
    
    NSMutableSet* devices = [NSMutableSet setWithCapacity:6];
    
    RelayrDevice* gyroscope = [self parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarGyroscope]];
    if (gyroscope) { [devices addObject:gyroscope]; }
    
    RelayrDevice* light = [self parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarLight]];
    if (light) { [devices addObject:light]; }
    
    RelayrDevice* mic = [self parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarMicrophone]];
    if (mic) { [devices addObject:mic]; }
    
    RelayrDevice* thermometer = [self parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarThermomether]];
    if (thermometer) { [devices addObject:thermometer]; }
    
    RelayrDevice* infrared = [self parseDeviceFromJSONDictionary:jsonDict[Web_ResopndKey_WunderbarInfrared]];
    if (infrared) { [devices addObject:infrared]; }
    
    RelayrDevice* bridge = [self parseDeviceFromJSONDictionary:jsonDict[Web_RespondKey_WunderbarBridge]];
    if (bridge) { [devices addObject:bridge]; }
    
    masterModule.devices = [NSSet setWithSet:devices];
    return masterModule;
}

@end
