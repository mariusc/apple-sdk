@import Foundation;     // Apple
@class RLAWunderbarCredentials;

/*!
 *  @class RLABluetoothPeripheralRequestRegistration
 *
 *  @abstract It provides means to setup a new wunderbar registration request.
 */
@interface RLABluetoothPeripheralRequestRegistration : NSObject

/**
 * @param credentials Wunderbar credentials as returned by the relayr server
 * @param ssid WIFI ssid (need by the wunderbar master module)
 * @param password WIFI password (need by the wunderbar master module)
 * @return Newly initialized object or nil if an object could not be created
 */

/*!
 *  @method initWithCredentials:wifiSSID:wifiPassword:
 *
 *  @abstract ...
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
