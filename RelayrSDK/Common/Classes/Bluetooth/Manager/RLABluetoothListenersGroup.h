@import Foundation;                 // Apple
@import CoreBluetooth;              // Apple
#import "RLABluetoothDelegate.h"    // Relayr.framework

/*!
 *  @class RLABluetoothListener
 *
 *  @abstract It groups many RLABluetoothDelegate objects that want to listen for a specific CBPeripheral.
 */
@interface RLABluetoothListenersGroup : NSObject

/*!
 *  @method initWithPeripheral:listener:
 *
 *  @abstract Initialises a channel info object with all required dependencies.
 *  @discussion If any of the arguments are not correctly set, the initiliaser will return <code>nil</code>.
 *
 *  @param peripheral CBPeripheral object for which updates should be received.
 *  @param listener Object that should receive the update callbacks.
 *	@return Initialized <code>RLABluetoothListener</code> object containing a <code>CBPeripheral</code> and a listener.
 *
 *  @see CBPeripheral
 *  @see RLABluetoothDelegate
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                          listener:(id <RLABluetoothDelegate>)listener;

/*!
 *  @property peripheral
 *
 *  @abstract CBPeripheral object for which listeners are registers.
 */
@property (strong, nonatomic) CBPeripheral* peripheral;

/*!
 *  @property listeners
 *
 *  @abstract <code>NSArray</code> of objects adopting <code>RLABluetoothDelegate</code> protocol.
 */
@property (readonly, nonatomic) NSArray* listeners;

/*!
 *  @method addListener:
 *
 *  @abstract Stores a delegate object for the peripheral associated with the object.
 *  @discussion If <code>listener</code> is not correctly set, this method doesn't perform any work.
 *
 *  @param listener Object able to receive Bluetooth delegate methods.
 *
 *  @see RLABluetoothDelegate
 */
- (void)addListener:(NSObject <RLABluetoothDelegate> *)listener;

/*!
 *  @method removeListener:
 *
 *  @abstract Removes a delegate object for the peripheral associated with the object.
 *  @discussion If <code>listener</code> is not correctly set, this method doesn't perform any work.
 *
 *  @param listener Object able to receive Bluetooth delegate methods.
 *
 *  @see RLABluetoothDelegate
 */
- (void)removeListener:(NSObject <RLABluetoothDelegate> *)listener;

@end
