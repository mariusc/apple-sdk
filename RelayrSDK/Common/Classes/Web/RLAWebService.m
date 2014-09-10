#import "RLAWebService.h"           // Header
#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrFirmware.h"          // Relayr.framework (Public)
#import "RelayrInput.h"             // Relayr.framework (Public)
#import "RelayrOutput.h"            // Relayr.framework (Public)
#import "RelayrApp_Setup.h"         // Relayr.framework (Private)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrPublisher_Setup.h"   // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h" // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)
#import "RelayrFirmware_Setup.h"    // Relayr.framework (Private)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)

#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RLAWebConstants.h"         // Relayr.framework (Web)
#import "RLAWebOAuthController.h"   // Relayr.framework (Web)

#import "RLAError.h"                // Relayr.framework (Utilities)

// This macro expands into the reiterative process request (Be careful when changing variable names.
#define processRequest(expectedCode, ...)   \
    (!error && responseCode.unsignedIntegerValue==expectedCode && data)                              \
    ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;          \
    if (json.count==0) { return completion( (error) ? error : RLAErrorWebrequestFailure, __VA_ARGS__); }

@implementation RLAWebService

#pragma mark - Public API

+ (void)isRelayrCloudReachable:(void (^)(NSError*, NSNumber*))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:Web_Host]];
    request.relativePath = Web_RequestRelativePath_Reachability;
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_Reachability, nil);
        completion(nil, @YES);
    }];
}

+ (void)requestAppInfoFor:(NSString*)appID completion:(void (^)(NSError*, NSString*, NSString*, NSString*))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RLAErrorMissingArgument, nil, nil, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:Web_Host]];
    request.relativePath = Web_RequestRelativePath_AppInfo(appID);
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppInfo, nil, nil, nil);
        completion(nil, json[Web_RespondKey_AppID], json[Web_RespondKey_AppName], json[Web_RespondKey_AppDescription]);
    }];
}

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

+ (void)requestOAuthCodeWithOAuthClientID:(NSString*)clientID redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* tmpCode))completion
{
    [[RLAWebOAuthController webOAuthControllerWithClientID:clientID redirectURI:redirectURI completion:completion] presentModally];
}

+ (void)requestOAuthTokenWithOAuthCode:(NSString*)code OAuthClientID:(NSString*)clientID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* token))completion
{
    if (!completion) { return; }
    if (!clientID || !clientSecret || !redirectURI) { return completion(RLAErrorMissingArgument, nil); }
    
    RLAWebRequest* tokenRequest = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:Web_Host]];
    tokenRequest.relativePath = Web_RequestRelativePath_OAuthToken;
    tokenRequest.body = Web_RequestBody_OAuthToken(code, redirectURI, clientID, clientSecret);
    
    [tokenRequest executeInHTTPMode:kRLAWebRequestModePOST completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_OAuthToken, nil);
        
        NSString* token = json[Web_RequestResponseKey_OAuthToken_AccessToken];
        if (!token) { return completion(RLAErrorSigningFailure, nil); }
        
        return completion(nil, token);
    }];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUser:(__weak RelayrUser *)user
{
    if (!user) { return nil; }
    
    self = [super init];
    if (self)
    {
        _user = user;
        _hostURL = [NSURL URLWithString:Web_Host];
    }
    return self;
}

- (void)setHostURL:(NSURL*)hostURL
{
    _hostURL = (hostURL) ? hostURL : [NSURL URLWithString:Web_Host];
}

- (void)requestUserInfo:(void (^)(NSError* error, NSString* uid, NSString* name, NSString* email))completion
{
    if (!completion) { return; }
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
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

- (void)requestUserPublishers:(void (^)(NSError* error, NSArray* publishers))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
    request.relativePath = Web_RequestRelativePath_UserPubs(_user.uid);
    
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
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
    request.relativePath = Web_RequestRelativePath_UserTrans(_user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserTrans, nil);
        
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrTransmitter* transmitter = [[RelayrTransmitter alloc] initWithID:dict[Web_RespondKey_TransmitterID] secret:dict[Web_RespondKey_TransmitterSecret]];
            if (!transmitter) { continue; }
            
            transmitter.owner = dict[Web_RespondKey_TransmitterOwner];
            transmitter.name = dict[Web_RespondKey_TransmitterName];
            [result addObject:transmitter];
        }

        return (result.count) ? completion(nil, [NSArray arrayWithArray:result]) : completion(RLAErrorWebrequestFailure, nil);
    }];
}

- (void)requestUserDevices:(void (^)(NSError* error, NSArray* devices))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
    request.relativePath = Web_RequestRelativePath_UserDevices(_user.uid);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_UserDevices, nil);
        
        NSMutableArray* result = [NSMutableArray arrayWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrDevice* device = [[RelayrDevice alloc] initWithID:dict[Web_RespondKey_DeviceID] secret:dict[Web_RespondKey_DeviceSecret]];
            if (!device) { continue; }
            
            device.name = dict[Web_RespondKey_DeviceName];
            device.owner = dict[Web_RespondKey_DeviceOwner];
            device.isPublic = dict[Web_RespondKey_DevicePublic];
            
            NSString* firmVer = dict[Web_RespondKey_DeviceFirmware];
            if (firmVer.length) { device.firmware = [[RelayrFirmware alloc] initWithVersion:firmVer]; }
            
            NSDictionary* model = dict[Web_RespondKey_DeviceModel];
            if (model.count)
            {
                device.manufacturer = dict[Web_RespondKey_ModelManufacturer];
                device.inputs = [self parseDeviceInputs:dict[Web_RespondKey_ModelReadings] ofDevice:device];
                //device.outputs = [self parseDeviceOutputs:dict[<#name#>];
            }
        }
        
        return (result.count) ? completion(nil, [NSArray arrayWithArray:result]) : completion(RLAErrorWebrequestFailure, nil);
    }];
}

- (void)requestUserBookmarkedDevices:(void (^)(NSError* error, NSArray* bookDevices))completion
{
    // TODO: Fill up
    // Create full RelayrDevice objects
}

- (void)requestUserApps:(void (^)(NSError* error, NSArray* apps))completion
{
    // TODO:
//    if (!completion) { return; }
//    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:_hostURL timeout:nil oauthToken:_user.token];
//    request.relativePath = dRLAWebService_Apps_RelativePath(_user.uid);
//    
//    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
//        if (error) { return completion(error, nil); }
//        
//        NSArray* jsonArray = (data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
//        if (error) { return completion(error, nil); }
//        
//        NSMutableArray* apps = [NSMutableArray arrayWithCapacity:jsonArray.count];
//        for (NSDictionary* tmp in jsonArray)
//        {
//            RelayrApp* app = [[RelayrApp alloc] initWithID:tmp[dRLAWebService_Apps_RespondKey_ID] publisherID:tmp[dRLAWebService_Apps_RespondKey_Owner]];
//            if (app) { [apps addObject:app]; }
//        }
//    }];
}

#pragma mark - Private methods

/*******************************************************************************
 * This methods parses the <code>reading</code> property of the device model.
 * It will return a set of <code>RelayrInput</code> objects.
 ******************************************************************************/
- (NSSet*)parseDeviceInputs:(NSArray*)readings ofDevice:(RelayrDevice*)device
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
- (NSSet*)parseDeviceOutputs:(NSArray*)writings ofDevice:(RelayrDevice*)device
{
    return nil;
}

@end
