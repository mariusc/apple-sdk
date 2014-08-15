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

@end
