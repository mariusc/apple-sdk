@import Foundation;         // Apple
#import "RLADevice.h"       // Base class

@interface RLADeviceLocal : RLADevice

/*!
 *  @property RSSI
 *
 *  @abstract <code>NSNumber</code> represenation of the RSSI, in decibels, of the device.
 */
@property (readonly,nonatomic) NSNumber* RSSI;

/*!
 *  @property peripheral
 *
 *  @abstract Underlying CBPeripheral object for the local device.
 */
@property (readonly,nonatomic) CBPeripheral* peripheral;

/*!
 *  @method setData:forServiceWithUUID:forCharacteristicWithUUID:completion:
 *
 *  @abstract It stores the given data for a characteristic if the characteristic exists.
 *
 *  @param data <code>NSData</code> representing the data stored.
 *  @param serviceUUID <code>NSString</code> representing the service UUID.
 *  @param characteristicUUID <code>NSString</code> representing the characteristic UUID.
 *  @param completion When the attempt to save the data succeeded the <code>NSData</code> return value is not <code>nil</code>.
 *
 *  @see CBPeripheral
 *  @see CBCharacteristic
 */
- (void)setData:(NSData *)data
forServiceWithUUID:(NSString *)serviceUUID
forCharacteristicWithUUID:(NSString *)characteristicUUID
     completion:(void(^)(CBPeripheral*, CBCharacteristic*, NSError*))completion;

@end
