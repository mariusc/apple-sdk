@import Foundation;      // Apple
@class RLAPeripheralnfo; // Relayr.framework

/*!
 *  @class RLABluetoothAdapterController
 *
 *  @abstract A class to control the conversion of data from recognized bluetooth devices into <code>RLASensorValue</code> subclasses.
 */
@interface RLABluetoothAdapterController : NSObject

/*!
 *  @method infoForPeripheralWithName:bleIdentifier:serviceUUID:characteristicUUID:
 *
 *  @abstract ...
 *
 *  @param name <code>NSString</code> representing the peripheral name.
 *  @param identifier <code>NSString</code> representing the peripheral identifier.
 *  @param serviceUUID <code>NSString</code> representing a service that must be advertised by the peripheral.
 *  @param characteristicUUID <code>NSString</code> representing a characteristic that must be advertised by the peripheral.
 *	@return An initialized object or <code>nil</code> if the object could not be created.
 */
- (RLAPeripheralnfo*)infoForPeripheralWithName:(NSString *)name
                                  bleIdentifier:(NSString *)identifier
                                    serviceUUID:(NSString *)serviceUUID
                             characteristicUUID:(NSString *)characteristicUUID;

@end
