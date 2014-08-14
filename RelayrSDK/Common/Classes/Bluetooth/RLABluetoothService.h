@import Foundation;                 // Apple
@class RLAWunderbarCredentials;     // Relayr.framework

@interface RLABluetoothService : NSObject

/*!
 *  @method devicesWithSensorsAndOutputsOfClasses:timeout:completion:
 *
 *  @abstract It discovers wunderbar devices in range and DOES NOT YET connect to them.
 *
 *  @param classes Sensor and output classes the device should contain.
 *  @param timeout Tiemout in seconds before the request is being cancelled.
 *  @param completion This block will be called once the devices are found or an error has been produced.
 */
- (void)devicesWithSensorsAndOutputsOfClasses:(NSArray*)classes
                                      timeout:(NSTimeInterval)timeout
                                   completion:(void(^)(NSArray*, NSError*))completion;

#pragma mark Onboarding

/*!
 *  @method peripheralWithWunderbarCredentials:wifiSSID:wifiPassword:andCompletionHandler:
 *
 *  @abstract This request is meant to be used for the onboarding of a new wunderbar
 *  @discussion It sets up the users phone to act as a peripheral in order to expose a predefined set of credentials which are beeing read by the master module and used by it in order to authenticate to the relayr server.
 *
 *  @param credentials It contains credentials returned by the relayr server.
 *  @param ssid <code>NSString</code> representing the WIFI SSID that the device will use.
 *  @param password <code>NSString</code> with the password of the previously given WIFI SSID.
 *  @param completion Block given the asychronous result of the operation. In case of error check @selector(localizedDescription) or @selector(localizedErrorReason) for a detailed error description
 */
//- (void)peripheralWithWunderbarCredentials:(RLAWunderbarCredentials *)credentials
//                                  wifiSSID:(NSString *)ssid
//                              wifiPassword:(NSString *)password
//                      andCompletionHandler:(void(^)(NSError*))completion;

@end
