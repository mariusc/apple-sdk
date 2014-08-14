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
 *  @method <#Method:name:#>
 *
 *  @abstract <#Brief intro#>
 *  @discussion <#Description with maybe some <code>Code</code> and links to other methods {@link method:name:}#>
 *
 *  @param <#name#> <#Description#>
 *	@return <#What it is returned#>
 *
 *  @see <#Method:to:see:#>
 *  @seealso <#ConstantVariable#>
 */
- (void)manager:(RLABluetoothManager*)manager
 didUpdateState:(CBCentralManagerState)state;

@optional
- (void)manager:(RLABluetoothManager*)manager
didDiscoverPeripheral:(CBPeripheral*)peripheral;

@optional
- (void)manager:(RLABluetoothManager*)manager
didConnectPeripheral:(CBPeripheral*)peripheral;

@optional
- (void)manager:(RLABluetoothManager*)manager
didDisconnectPeripheral:(CBPeripheral*)peripheral;

@optional
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
  didUpdateData:(NSData*)data
forCharacteristic:(CBCharacteristic*)characteristic
          error:(NSError*)error;

@optional
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
 didUpdateValue:(NSDictionary*)value
withSensorClass:(Class)class
forCharacteristic:(CBCharacteristic*)characteristic
error:(NSError*)error;

@optional
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
didDiscoverCharacteristicsForService:(CBService*)service
          error:(NSError*)error;

@optional
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic*)characteristic
          error:(NSError*)error;

@optional
- (void)manager:(RLABluetoothManager*)manager
     peripheral:(CBPeripheral*)peripheral
didWriteValueForCharacteristic:(CBCharacteristic*)characteristic
          error:(NSError*)error;

@end