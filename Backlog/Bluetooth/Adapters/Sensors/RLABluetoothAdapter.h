@import Foundation; // Apple

@interface RLABluetoothAdapter : NSObject

/*!
 *  @method initWithData:
 *
 *  @abstract Designated initialiser for <code>RLABluetoothAdapter</code> base class.
 *
 *  @param data <code>NSData</code> representation of the data fetched from the device
 *	@return Newly initialized object or <code>nil</code> if an object could not be created.
 */
- (instancetype)initWithData:(NSData*)data;

/*!
 *  @property dictionary
 *
 *  @abstract Dictionary representiation of the sensor data
 */
@property (readonly, nonatomic) NSDictionary* dictionary;

/*!
 *  @property data
 *
 *  @abstract <code>NSData</code> as provided during initilization
 */
@property (readonly, nonatomic) NSData* data;

@end
