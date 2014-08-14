@import Foundation;             // Apple
@import CoreBluetooth;          // Apple
@class RLABluetoothManager;     // Relayr.framework

/*!
 *  @protocol RLABluetoothDelegate
 *
 *  @abstract Provides means to forward delegate callbacks of these delegates in a unified way:
 */
@protocol RLABluetoothDelegate <NSObject>

@optional
/*!
 *  @method manager:didUpdateState:
 *
 *  @abstract Called when the state of the bluetooth central manager updates.
 *
 *  @param manager The <code>RLABluetoothManager</code> which has changed state.
 *  @param state The new <code>CBCentralManagerState</code>.
 */
- (void)manager:(RLABluetoothManager*)manager
 didUpdateState:(CBCentralManagerState)state;

@optional
/*!
 *  @method manager:didDiscoverPeripheral:
 *
 *  @abstract Called when the bluetooth central manager discovers a peripheral.
 *
 *  @param manager The <code>RLABluetoothManager</code> which has dicovered a peripheral.
 *  @param peripheral The <code>CBPeripheral</code> which was discovered.
 */
- (void)manager:(RLABluetoothManager*)manager
didDiscoverPeripheral:(CBPeripheral*)peripheral;

@optional
/*!
 *  @method manager:didConnectPeripheral:
 *
 *  @abstract Called when the bluetooth central manager connects to a peripheral.
 *
 *  @param manager The <code>RLABluetoothManager</code> which has connected to a peripheral.
 *  @param peripheral The <code>CBPeripheral</code> which was connected to.
 */
- (void)manager:(RLABluetoothManager*)manager
didConnectPeripheral:(CBPeripheral*)peripheral;

@optional
/*!
 *  @method manager:didDisconnectPeripheral:
 *
 *  @abstract Called when the bluetooth central manager disconnects from a peripheral.
 *
 *  @param  manager The <code>RLABluetoothManager</code> which has disconnected from a peripheral.
 *  @param peripheral The <code>CBPeripheral</code> which was disconnected from.
 */
- (void)manager:(RLABluetoothManager*)manager
didDisconnectPeripheral:(CBPeripheral*)peripheral;

@optional
/*!
 *  @method manager:peripheral:didUpdateData:forCharacteristic:error:
 *
 *  @abstract Called when the bluetooth central manager has updated data for a specific characteristic.
 *
 *  @param manager The <code>RLABluetoothManager</code> which has advertising the peripheral.
 *  @param peripheral The <code>CBPeripheral</code> which has updated the characteristic data.
 *  @param data The <code>NSData</code> which has been updated.
 *  @param characteristic The <code>CBCharacteristic</code> which has been updated.
 *  @param error The <code>NSError</code> which will be thrown if the call was unsuccessful.
 */
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
  didUpdateData:(NSData*)data
forCharacteristic:(CBCharacteristic*)characteristic
          error:(NSError*)error;

@optional
/*!
 *  @method manager:peripheral:didUpdateValue:withSensorClass:forCharacteristic:error:
 *
 *  @abstract Called when the bluetooth central manager has updated a value of a characteristic for a specific relayr sensor class.
 *
 *  @param manager The <code>RLABluetoothManager</code> which has advertising the peripheral.
 *  @param peripheral The <code>CBPeripheral</code> which has updated the value of a characteristic.
 *  @param value The <code>NSDictionary</code> which contains the values of the characteristic
 *  @param class The <code>RLASensor</code> which is connected as a peripheral
 *  @param characteristic The <code>CBCharacteristic</code> which has been updated.
 *  @param error The <code>NSError</code> which will be thrown if the call was unsuccessful.
 */
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
 didUpdateValue:(NSDictionary*)value
withSensorClass:(Class)class
forCharacteristic:(CBCharacteristic*)characteristic
          error:(NSError*)error;

@optional
/*!
 *  @method manager:peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @abstract Called when the bluetooth central manager discovered charectateristics being advertised by a peripheral for a given service.
 *
 *  @param manager The <code>RLABluetoothManager</code> which discovered the peripheral.
 *  @param peripheral The <code>CBPeripheral</code> which is advertising the service.
 *  @param service The <code>CBService</code> which is being advertised.
 *  @param error The <code>NSError</code> which will be thrown if the call was unsuccessful.
 */
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
didDiscoverCharacteristicsForService:(CBService*)service
          error:(NSError*)error;

@optional
/*!
 *  @method manager:peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @abstract Called when the bluetooth central manager detected a change in notification state of a characteristic advertised by a connected peripheral.
 *
 *  @param manager The <code>RLABluetoothManager</code> which is connected to the peripheral.
 *  @param peripheral The <code>CBPeripheral</code> which has changed the state of the characteristic.
 *  @param characteristic The <code>CBCharacteristic</code> which is being advertised.
 *  @param error The <code>NSError</code> which will be thrown if the call was unsuccessful.
 */
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic*)characteristic
          error:(NSError*)error;

@optional
/*!
 *  @method manager:peripheral:didWriteValueForCharacteristic:error
 *
 *  @abstract Called when the bluetooth central manager writes the value of a characteristic to a connected peripheral
 *
 *  @param manager The <code>RLABluetoothManager</code> which is connected to the peripheral.
 *  @param peripheral The <code>CBPeripheral</code> which is advertising the characteristic.
 *  @param characteristic The <code>CBCharacteristic</code> which the new value has been written to.
 *  @param error The <code>NSError</code> which will be thrown if the call was unsuccessful.
 */
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
didWriteValueForCharacteristic:(CBCharacteristic*)characteristic
          error:(NSError*)error;

@end