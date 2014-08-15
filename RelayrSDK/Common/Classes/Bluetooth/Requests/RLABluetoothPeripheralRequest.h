@import Foundation;     // Apple
@import CoreBluetooth;  // Apple

/*!
 *  @class RLABluetoothPeripheralRequest
 *
 *  @abstract It provides means to execute bluetooth requests of the users phone
 */
@interface RLABluetoothPeripheralRequest : NSObject <CBPeripheralManagerDelegate>

/*!
 *  @property manager
 *
 *  @abstract Core Bluetooth manager for when the device is acting as a peripheral
 */
@property (readonly,nonatomic) CBPeripheralManager* manager;

/*!
 *  @property name
 *
 *  @abstract <code>NSString</code> representing the name that should be advertised for the peripheral.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @property services
 *
 *  @abstract <code>NSArray</code> containing all the services that should be advertised.
 */
@property (readonly,nonatomic) NSArray* services;

/*!
 *  @property completion
 *
 *  @abstract Because Bluetooth requests don't have a defined finish point like web requests <code>RLABluetoothPeripheralRequest</code> subclasses must invoke the completion handler manually based on the specific requirements of the subclass.
 */
@property (readonly,nonatomic) void (^completion)(NSError*);

/*!
 *  @method executeWithCompletionHandler:
 *
 *  @abstract ...
 *
 *  @param completion ...
 *
 *  @see CBPeripheral
 */
- (void)executeWithCompletionHandler:(void(^)(NSError*))completion;

@end
