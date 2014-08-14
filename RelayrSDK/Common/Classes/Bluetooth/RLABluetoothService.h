@import Foundation;     // Apple

/*!
 *  @class RLABluetoothService
 *
 *  @abstract The Bluetooth service is the central manager class for all bluetooth related actions utilising local devices.
 */
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

@end
