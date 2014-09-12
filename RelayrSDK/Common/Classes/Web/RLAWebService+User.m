#import "RLAWebService+User.h"      // Header

#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrFirmware.h"          // Relayr.framework (Public)
#import "RelayrInput.h"             // Relayr.framework (Public)
#import "RelayrOutput.h"            // Relayr.framework (Public)

#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RLAWebConstants.h"         // Relayr.framework (Web)

#import "RelayrApp_Setup.h"         // Relayr.framework (Private)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrPublisher_Setup.h"   // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h" // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)
#import "RelayrFirmware_Setup.h"    // Relayr.framework (Private)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)

#import "RLAError.h"                // Relayr.framework (Utilities)

@implementation RLAWebService (User)

#pragma mark - Public API

// TODO: Check how headers should be parse within the GET (relativePath). As in this example
+ (void)isUserWithEmail:(NSString*)email registeredInRelayrCloud:(void (^)(NSError* error, NSNumber* isUserRegistered))completion
{
    if (!completion) { return; }
    if (!email) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:Web_Host]];
    request.relativePath = Web_RequestRelativePath_EmailCheck(email);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_EmailCheck, nil);
        
        NSString* exists = json[Web_RequestResponseKey_EmailCheck_Exists];
        if (!exists) { return completion(RLAErrorWebrequestFailure, nil); }
        
        NSRange const result = [exists rangeOfString:Web_RequestResponseVal_EmailCheck_Exists];
        if (result.location == NSNotFound || result.length == 0) { return completion(nil, @NO); }
        return completion(nil, @YES);
    }];
}

- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion
{
    if (!completion) { return; }
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    request.relativePath = Web_RequestRelativePath_UserInfo;
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_UserInfo, nil, nil, nil);
        
        NSString* futureID = json[Web_RespondKey_UserID];
        NSString* futureName = json[Web_RespondKey_UserName];
        NSString* futureEmail = json[Web_RespondKey_UserEmail];
        if (!futureID || !futureName || !futureEmail) { return completion(RLAErrorMissingExpectedValue, nil, nil, nil); }
        
        completion(nil, futureID, futureName, futureEmail);
    }];
}

- (void)setUserName:(NSString*)name email:(NSString*)email completion:(void (^)(NSError* error))completion
{
    NSMutableDictionary* body = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (name) { body[Web_RespondKey_UserID] = name; }
    if (email) { body[Web_RespondKey_UserName] = email; }
    if (!body.count) { if (completion) { completion(nil); } return; }
    
    __weak RelayrUser* user = self.user;
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:user.token];
    request.relativePath = Web_RequestRelativePath_UserInfoSet;
    request.body = [NSDictionary dictionaryWithDictionary:body];
//    [request executeInHTTPMode:kRLAWebRequestModePATCH completion:if (!completion) ? nil : ^ (NSError* error){
//        
//    }];
}

- (void)requestUserApps:(void (^)(NSError* error, NSArray* apps))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    request.relativePath = Web_RequestRelativePath_UserInstalledApps(self.user.uid);
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserInstalledApps, nil);
        
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrApp* app = [[RelayrApp alloc] initWithID:dict[Web_RespondKey_AppID]];
            app.name = dict[Web_RespondKey_AppName];
            app.appDescription = dict[Web_RespondKey_AppDescription];
            if (app) { [result addObject:app]; }
        }
        
        return completion(nil, (result.count) ? [NSArray arrayWithArray:result] : nil);
    }];
}

- (void)requestUserPublishers:(void (^)(NSError* error, NSArray* publishers))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    request.relativePath = Web_RequestRelativePath_UserPubs(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserPubs, nil);
        
        NSMutableArray* publishers = [NSMutableArray arrayWithCapacity:json.count];
        for (NSDictionary* tmp in json)
        {
            RelayrPublisher* pub = [[RelayrPublisher alloc] initWithPublisherID:tmp[Web_RespondKey_PublisherID] owner:tmp[Web_RespondKey_PublisherOwner]];
            pub.name = tmp[Web_RespondKey_PublisherName];
            if (pub) { [publishers addObject:pub]; }
        }
        
        completion(nil, (publishers.count) ? [NSArray arrayWithArray:publishers] : nil);
    }];
}

- (void)requestUserTransmitters:(void (^)(NSError* error, NSArray* transmitters))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    request.relativePath = Web_RequestRelativePath_UserTrans(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserTrans, nil);
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        
        for (NSDictionary* dict in json)
        {
            RelayrTransmitter* transmitter = [self parseTransmitterFromJSONDictionary:dict];
            if (transmitter) { [result addObject:transmitter]; }
        }
        
        return completion(nil, (result.count) ? [NSArray arrayWithArray:result] : nil);
    }];
}

- (void)requestUserDevices:(void (^)(NSError* error, NSArray* devices))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    request.relativePath = Web_RequestRelativePath_UserDevices(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserDevices, nil);
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [self parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        
        return completion(nil, (result.count) ? [NSArray arrayWithArray:result] : nil);
    }];
}

- (void)requestUserBookmarkedDevices:(void (^)(NSError* error, NSArray* bookDevices))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:self.hostURL timeout:nil oauthToken:self.user.token];
    request.relativePath = Web_RequestRelativePath_UserBookmarkDevices(self.user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserBookmarkDevices, nil);
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [self parseDeviceFromJSONDictionary:dict];
            if (device) { [result addObject:device]; }
        }
        
        return completion(nil, (result.count) ? [NSArray arrayWithArray:result] : nil);
    }];
}

#pragma mark - Private methods

- (RelayrTransmitter*)parseTransmitterFromJSONDictionary:(NSDictionary*)jsonDict
{
    RelayrTransmitter* transmitter = [[RelayrTransmitter alloc] initWithID:jsonDict[Web_RespondKey_TransmitterID] secret:jsonDict[Web_RespondKey_TransmitterSecret]];
    if (!transmitter) { return transmitter; }
    
    transmitter.owner = jsonDict[Web_RespondKey_TransmitterOwner];
    transmitter.name = jsonDict[Web_RespondKey_TransmitterName];
    return transmitter;
}

/*******************************************************************************
 * This method parses a json dictionary representing a Relayr Device.
 ******************************************************************************/
- (RelayrDevice*)parseDeviceFromJSONDictionary:(NSDictionary*)jsonDict
{
    RelayrDevice* device = [[RelayrDevice alloc] initWithID:jsonDict[Web_RespondKey_DeviceID] secret:jsonDict[Web_RespondKey_DeviceSecret]];
    if (!device) { return device; }
    
    device.name = jsonDict[Web_RespondKey_DeviceName];
    device.owner = jsonDict[Web_RespondKey_DeviceOwner];
    device.isPublic = jsonDict[Web_RespondKey_DevicePublic];
    
    NSString* firmVer = jsonDict[Web_RespondKey_DeviceFirmware];
    if (firmVer.length) { device.firmware = [[RelayrFirmware alloc] initWithVersion:firmVer]; }
    
    NSDictionary* model = jsonDict[Web_RespondKey_DeviceModel];
    if (model.count)
    {
        device.manufacturer = jsonDict[Web_RespondKey_ModelManufacturer];
        device.inputs = [self parseDeviceReadingsFromJSONArray:jsonDict[Web_RespondKey_ModelReadings] ofDevice:device];
        //device.outputs = [self parseDeviceWritingsFromJSONArray:dict[<#name#>];
    }
    
    return device;
}

/*******************************************************************************
 * This methods parses the <code>reading</code> property of the device model.
 * It will return a set of <code>RelayrInput</code> objects.
 ******************************************************************************/
- (NSSet*)parseDeviceReadingsFromJSONArray:(NSArray*)readings ofDevice:(RelayrDevice*)device
{
    if (!readings.count) { return nil; }
    
    NSMutableSet* result = [NSMutableSet setWithCapacity:readings.count];
    for (NSDictionary* dict in readings)
    {
        RelayrInput* input = [[RelayrInput alloc] initWithMeaning:dict[Web_RespondKey_ReadingsMeaning] unit:dict[Web_RespondKey_ReadingsUnit]];
        if (!input) { continue; }
        
        input.device = device;
        [result addObject:input];
    }
    
    return (result.count) ? [NSSet setWithSet:result] : nil;
}

/*******************************************************************************
 * This methods parses the <code>...</code> property of the device model.
 * It will return a set of <code>RelayrOutput</code> objects.
 ******************************************************************************/
- (NSSet*)parseDeviceWritingsFromJSONArray:(NSArray*)writings ofDevice:(RelayrDevice*)device
{
    if (!writings.count) { return nil; }
    
    NSMutableSet* result = [NSMutableSet setWithCapacity:writings.count];
    //    for (NSDictionary* dict in writings)
    //    {
    //        // Fill up
    //    }
    
    return (result.count) ? [NSSet setWithSet:result] : nil;
    
    return nil;
}

@end
