#import "RLALocalUser.h"            // Base class
@class RLACredentialsWunderbar;     // FIXME: Old
@class RLABluetoothService;         // Relayr.framework (Bluetooth)

/*!
 *  @abstract Category that allow a local user to Onboard a device into the Relayr cloud
 *
 *  @see RLALocalUser
 */
@interface RLALocalUser (Onboard)

/*!
 *  @abstract It sets up the first step into the onboarding process: connecting the phone with the master module by Bluetooth.
 *  @discussion It sets up the users phone to act as a peripheral in order to expose a predefined set of credential which are being read by the master module and used by it in order to authenticate to the relayr server.
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
