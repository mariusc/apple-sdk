#import "RLAWebService+Device.h"    // Header
#import "RLAWebRequest.h"           // Relayr.framework (Web)
#import "RLAWebConstants.h"         // Relayr.framework (Web)
#import "RLAError.h"                // Relayr.framework (Utilities)

@implementation RLAWebService (Device)

- (void)registerDeviceWithName:(NSString*)deviceName owner:(NSString*)ownerID model:(NSString*)modelID firmwareVersion:(NSString*)firmwareVersion completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    
}

- (void)requestDevice:(NSString*)deviceID completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    
}

- (void)setDevice:(NSString*)deviceID modelID:(NSString*)futureModelID isPublic:(NSNumber*)isPublic description:(NSString*)description completion:(void (^)(NSError* error))completion
{
    
}

- (void)deleteDevice:(NSString*)deviceID completion:(void (^)(NSError* error))completion
{
    
}

- (void)setConnectionBetweenDevice:(NSString*)deviceID andApp:(NSString*)appID completion:(void (^)(NSError* error, id credentials))completion
{
    
}

- (void)deleteConnectionBetweenDevice:(NSString*)deviceID andApp:(NSString*)appID completion:(void (^)(NSError* error))completion
{
    
}

- (void)requestPublicDevices:(void (^)(NSError* error, NSArray* devices))completion
{
    
}

- (void)requestPublicDevicesFilteredByMeaning:(NSString*)meaning completion:(void (^)(NSError* error, NSArray* devices))completion
{
    
}

+ (void)setConnectionToPublicDevice:(NSString*)deviceID completion:(void (^)(NSError* error, id credentials))completion
{
    
}

- (void)requestAllDeviceModels:(void (^)(NSError* error, NSArray* deviceModels))completion
{
    
}

- (void)requestDeviceModel:(NSString*)deviceModelID completion:(void (^)(NSError* error, id <RelayrDeviceModel> deviceModel))completion
{
    
}

- (void)requestAllDeviceMeanings:(void (^)(NSError* error, NSArray* meanings))completion
{
    
}

@end
