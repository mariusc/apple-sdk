@import Foundation;                         // Apple
#import "RLABluetoothPeripheralRequest.h"   // Relayr.framework
@class RLAWunderbarCredentials;             // Relayr.framework

/*!
 *  @class RLABluetoothPeripheralRequestRegistration
 *
 *  @abstract Provide means to setup a new wunderbar registration request.
 */
@interface RLABluetoothPeripheralRequestRegistration : RLABluetoothPeripheralRequest

/**
 * @param credentials Wunderbar credentials as returned by the relayr server
 * @param ssid WiFi SSID (needed by the Wunderbar master module)
 * @param password WiFi password (needed by the Wunderbar master module)
 * @return Newly initialized object or nil if an object could not be created
 */

/*!
 *  @method initWithCredentials:wifiSSID:wifiPassword:
 *
 *  @abstract Called to initialise the peripheral with the data required for the values of the characteristics advertised in the service.
 *
 * @param credentials Wunderbar credentials as returned by the relayr server
 * @param ssid WIFI ssid (need by the wunderbar master module)
 * @param password WIFI password (need by the wunderbar master module)
 * @return Newly initialized object or nil if an object could not be created
 */
- (instancetype)initWithCredentials:(RLAWunderbarCredentials *)credentials
                           wifiSSID:(NSString *)ssid
                       wifiPassword:(NSString *)password;

@end
