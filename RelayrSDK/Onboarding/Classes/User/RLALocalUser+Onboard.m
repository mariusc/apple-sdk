#import "RLALocalUser+Onboard.h"        // Header
#import "RLALocalUser_Private.h"        // Relayr.framework (extension)

@implementation RLALocalUser (Onboard)

- (void)peripheralWithWunderbarCredentials:(RLACredentialsWunderbar*)credentials wifiSSID:(NSString*)ssid wifiPassword:(NSString*)password andCompletionHandler:(void(^)(NSError*))completion
{
    RLAErrorAssertTrueAndReturn(credentials, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(ssid, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(password, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
    
    [self.bleService peripheralWithWunderbarCredentials:credentials wifiSSID:ssid wifiPassword:password andCompletionHandler:completion];
}

@end
