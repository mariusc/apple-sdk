#import "RLABluetoothCentralRequest.h" // Relayr.framework (Base class)

/*!
 *  @class RLABluetoothPeripheralsDiscoveryRequest
 *
 *  @abstract It provides means to detect specific wunderbar sensors.
 *
 *  @see RLABluetoothRequest
 */
@interface RLABluetoothCentralRequestDiscoverPeripherals : RLABluetoothCentralRequest

/*!
 *  @method initWithListenerManager:permittedDeviceClasses:timeout:
 *
 *  @abstract Initialise a Bluetooth request asking for a Relayr device with a specific permitted classes and a specific amount of time that the request can be pending.
 *  @discussion This Bluetooth request must use this initialiser and not any of the parent initialisers.
 *
 *  @param manager Service listener manager in charge of the response of this request.
 *	@return Initialized Bluetooth request.
 *
 *  @see RLABluetoothRequest
 */
- (instancetype)initWithListenerManager:(RLABluetoothManager*)manager
                 permittedDeviceClasses:(NSArray *)classes
                                timeout:(NSTimeInterval)timeout;

@end
