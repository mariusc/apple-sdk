@import Foundation;     // Apple

/*!
 *  @class RLAHandlerInfo
 *
 *  @abstract ...
 */
@interface RLAHandlerInfo : NSObject

/*!
 *  @method initWithServiceUUID:characteristicUUID:handler:
 *
 *  @abstract ...
 *
 *  @param serviceUUID ...
 *  @param characteristicUUID ...
 *  @param handler ...
 *	@return ...
 */
- (instancetype)initWithServiceUUID:(NSString*)serviceUUID
                 characteristicUUID:(NSString*)characteristicUUID
                            handler:(void (^)(NSData*, NSError*))handler;

/*!
 *  @property serviceUUID
 *
 *  @abstract ...
 */
@property (nonatomic, strong, readonly) NSString* serviceUUID;

/*!
 *  @property characteristicUUID
 *
 *  @abstract ...
 */
@property (nonatomic, strong, readonly) NSString* characteristicUUID;

/*!
 *  @property handler
 *
 *  @abstract ...
 */
@property (nonatomic, strong, readonly) void (^handler)(NSData*, NSError*);

@end
