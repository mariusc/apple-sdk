@import Foundation; // Apple

/*!
 *  @class RLAOutput
 *
 *  @abstract It provides means to set data on an output.
 */
@interface RLAOutput : NSObject

/*!
 *  @property data
 *
 *  @abstract <code>NSData</code> blob to send to a device.
 *  @discussion If the data has been set, this property is kept set, so you can review what was the last data blob that was sent.
 */
@property (readwrite,nonatomic) NSData* data;

/*!
 *  @property uid
 *
 *  @abstract <code>NSString</code> representing the writable characteristic "uid".
 *  @discussion This method is supposed to be overriden by subclasses.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @property type
 *
 *  @abstract <code>NSString</code> representing the receiver type.
 *  @discussion This method is supposed to be overriden by subclasses.
 */
@property (readonly,nonatomic) NSString* type;

@end
