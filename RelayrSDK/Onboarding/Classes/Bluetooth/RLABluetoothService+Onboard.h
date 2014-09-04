#import "RLABluetoothService.h"     // Base class
@class RLACredentialsWunderbar;     // FIXME: Old class

@interface RLABluetoothService (Onboard)

/*!
 *  @abstract This request is meant to be used for the onboarding of a new wunderbar
 *  @discussion It sets up the users phone to act as a peripheral in order to expose a predefined set of credentials which are beeing read by the master module and used by it in order to authenticate to the relayr server.
 *
 *  @param credentials It contains credentials returned by the relayr server.
 *  @param ssid <code>NSString</code> representing the WIFI SSID that the device will use.
 *  @param password <code>NSString</code> with the password of the previously given WIFI SSID.
 *  @param completion Block given the asychronous result of the operation. In case of error check @selector(localizedDescription) or @selector(localizedErrorReason) for a detailed error description
 */
- (void)peripheralWithWunderbarCredentials:(RLACredentialsWunderbar*)credentials
                                  wifiSSID:(NSString*)ssid
                              wifiPassword:(NSString*)password
                      andCompletionHandler:(void(^)(NSError*))completion;

@end
