#import "RLALocalUser+Onboard.h"        // Header
#import "RLALocalUser_Private.h"        // FIXME: Old

@implementation RLALocalUser (Onboard)

- (void)peripheralWithWunderbarCredentials:(RLACredentialsWunderbar*)credentials wifiSSID:(NSString*)ssid wifiPassword:(NSString*)password andCompletionHandler:(void(^)(NSError*))completion
{
    RLAErrorAssertTrueAndReturn(credentials, kRLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(ssid, kRLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(password, kRLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(completion, kRLAErrorCodeMissingArgument);
    
    [self.bleService peripheralWithWunderbarCredentials:credentials wifiSSID:ssid wifiPassword:password andCompletionHandler:completion];
}

@end
