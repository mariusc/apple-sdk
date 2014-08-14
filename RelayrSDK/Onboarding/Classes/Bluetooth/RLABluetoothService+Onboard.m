#import "RLABluetoothService+Onboard.h"

@implementation RLABluetoothService (Onboard)

//- (void)peripheralWithWunderbarCredentials:(RLAWunderbarCredentials *)credentials wifiSSID:(NSString *)ssid wifiPassword:(NSString *)password andCompletionHandler:(void(^)(NSError*))completion
//{
//    RLAErrorAssertTrueAndReturn(ssid, RLAErrorCodeMissingArgument);
//    RLAErrorAssertTrueAndReturn(password, RLAErrorCodeMissingArgument);
//    RLAErrorAssertTrueAndReturn(completion, RLAErrorCodeMissingArgument);
//
//    __autoreleasing NSError* error;
//    if ( ![self isBluetoothAvailable:&error] ) { return completion(error); }
//
//    // The central manager may not habe any connections to peripherals otherwise the peripheral manager used for this request is not usable
//    [_centralManager stopScan];
//    for (CBPeripheral *peripheral in [_serviceListener connectedPeripherals]) {
//        [_centralManager cancelPeripheralConnection:peripheral];
//    }
//
//    // Setup request
//    self.registrationRequest = [[RLAWunderbarRegistrationPeripheralRequest alloc] initWithCredentials:credentials wifiSSID:ssid wifiPassword:password];
//
//    // Execute request
//    [self.registrationRequest executeWithCompletionHandler:^(NSError *error){ completion(error); }];
//}

@end
