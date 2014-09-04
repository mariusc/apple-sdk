#import "RLABluetoothService+Onboard.h"     // Header
#import "RLACredentialsWunderbar.h"         // FIXME: Old

@implementation RLABluetoothService (Onboard)

- (void)peripheralWithWunderbarCredentials:(RLACredentialsWunderbar*)credentials wifiSSID:(NSString*)ssid wifiPassword:(NSString*)password andCompletionHandler:(void(^)(NSError*))completion
{
    RLAErrorAssertTrueAndReturn(ssid, kRLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(password, kRLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(completion, kRLAErrorCodeMissingArgument);

    __autoreleasing NSError* error;
    if ( ![self isBluetoothAvailable:&error] ) { return completion(error); }

    // The central manager may not habe any connections to peripherals otherwise the peripheral manager used for this request is not usable
    [_centralManager stopScan];
    for (CBPeripheral* peripheral in [_serviceListener connectedPeripherals])
    {
        [_centralManager cancelPeripheralConnection:peripheral];
    }

    // Setup request
    self.registrationRequest = [[RLAWunderbarRegistrationPeripheralRequest alloc] initWithCredentials:credentials wifiSSID:ssid wifiPassword:password];

    // Execute request
    [self.registrationRequest executeWithCompletionHandler:^(NSError* error){ completion(error); }];
}

@end
