@import Foundation; // Apple

/*!
 *  @class RLABluetoothService
 *
 *  @abstract This class is the central manager class for all bluetooth related actions utilising local devices.
 */
@interface RLABluetoothService : NSObject

/*!
 *  @method devicesWithSensorsAndOutputsOfClasses:timeout:completion:
 *
 *  @abstract Called to discover wunderbar devices in range But does not connect to them.
 *
 *  @param classes Sensor and output classes the device should contain.
 *  @param timeout Timeout time in seconds before the request is cancelled.
 *  @param completion Completion block which is called when devices are found or an error has occured.
 */
- (void)devicesWithSensorsAndOutputsOfClasses:(NSArray*)classes
                                      timeout:(NSTimeInterval)timeout
                                   completion:(void(^)(NSArray*, NSError*))completion;

@end
