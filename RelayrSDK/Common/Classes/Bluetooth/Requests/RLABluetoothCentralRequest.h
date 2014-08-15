@import Foundation;                             // Apple
@class RLABluetoothManager;

/*!
 *  @class RLABluetoothRequest
 *
 *  @abstract It provides means to execute bluetooth requests of the users phone.
 *  @discussion This class is not supposed to be used. When you need to make requests, use some more specialized class instead.
 */
@interface RLABluetoothCentralRequest : NSObject

/*!
 *  @method initWithListenerManager:
 *
 *  @abstract It initializes a request with the listener manager in charge of responding.
 *  @discussion <code>-init</code> is disable for this object. You can only use this initializer.
 *
 *  @param manager Service listener manager in charge of the response of this request.
 *	@return Initialize instance of RLABluetoothRequest.
 */
- (instancetype)initWithListenerManager:(RLABluetoothManager*)manager;

/*!
 *  @property manager
 *
 *  @abstract Service listener manager in charge of listening this request.
 */
@property (readonly,nonatomic) RLABluetoothManager* manager;

/*!
 *  @property completionHandler
 *
 *  @abstract Block to be executed once an answer (whether successful or not) is received.
 */
@property (readonly,nonatomic) void (^completionHandler)(NSArray*, NSError*);

/*!
 *  @method executeWithCompletionHandler:
 *
 *  @abstract It executes the already setup Bluetooth request.
 *
 *  @param completion This block will be executed once that an answer for the request is available. That answer can be successful or unsucessful (<code>NSError*</code>).
 */
- (void)executeWithCompletionHandler:(void(^)(NSArray*, NSError*))completion;

@end
