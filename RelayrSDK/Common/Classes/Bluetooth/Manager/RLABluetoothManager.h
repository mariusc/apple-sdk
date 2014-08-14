@import Foundation;                         // Apple
@import CoreBluetooth;                      // Apple
#import "RLABluetoothDelegate.h"             // Relayr.framework

/*!
 *  @class RLABluetoothManager
 *
 *  @abstract It provides clustered callbacks for relevant events to registered devices.
 */
@interface RLABluetoothManager : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

/*!
 *  @method bluetoothCentralManager
 *
 *  @abstract The CBCentralManager that is used to monitor bluetooth state updates
 *
 *	@return The Core Bluetooth Central Manager.
 */
@property (strong, nonatomic) CBCentralManager* centralManager;

/*!
 *  @method connectedPeripherals
 *
 *  @abstract An NSArray of currently connected peripheral objects.
 *
 *	@return It returns an <code>NSArray</code> of connected peripherals.
 */
- (NSArray*)connectedPeripherals;

/*!
 *  @method addListener:
 *
 *  @abstract It adds a generic listener that will be called back in case of every bluetooth update.
 *
 *  @param listener Object conforming to <RLABluetoothDelegate>
 */
- (void)addListener:(id <RLABluetoothDelegate>)listener;

/*!
 *  @method addListener:forPeripheral:
 *
 *  @abstract It adds a listener for the provided peripheral.
 *  @discussion The listener will only receive callbacks when updates for the specified peripheral happens.
 *
 *  @param listener Object conforming to the <RLABluetoothDelegate>.
 *  @param peripheral CBPeripheral for which updates should be received.
 */
- (void)addListener:(id <RLABluetoothDelegate>)listener
      forPeripheral:(CBPeripheral *)peripheral;

/*!
 *  @method removeListener:
 *
 *  @abstract It removes a generic listener.
 *
 *  @param listener Object conforming to <RLABluetoothDelegate>
 */
- (void)removeListener:(id <RLABluetoothDelegate>)listener;

/*!
 *  @method removeListener:forPeripheral:
 *
 *  @abstract It removes a listener for the provided peripheral.
 *
 *  @param listener Object conforming to <RLABluetoothDelegate.
 *  @param peripheral CBPeripheral for which updates should be silenced.
 */
- (void)removeListener:(id <RLABluetoothDelegate>)listener
         forPeripheral:(CBPeripheral *)peripheral;

@end
