@import Foundation;

/*!
 *  @protocol RLAUser
 *
 *  @abstract Protocol for all the user types within the Relayr framework.
 */
@protocol RLAUser <NSObject>

/*!
 *  @method devicesWithCompletionHandler:
 *
 *  @abstract It list all the available devices associated with the user where this call is being made.
 *  @discussion This method will execute a <i>completion</i> block containing the result of the check. If this method is successful an <code>NSArray</code> will be passed containing specific instances of <code>RLADevice</code>s.
 *
 *  @param completion It can provide a successful result as an <code>NSArray</code> instance containing <code>RLADevice</code>s or an error specifying the problem.
 *
 *  @see devicesWithSensorsAndOutputsOfClasses:completion:
 */
- (void)devicesWithCompletionHandler:(void(^)(NSArray*, NSError*))completion;

/*!
 *  @method devicesWithSensorsAndOutputsOfClasses:completion:
 *
 *  @abstract It lists all the available devices associated with the user where this call is being made that satisfy the given criteria.
 *  @discussion The method chooses all the devices that are of any of the types given in the <code>classes</code> or that contains any of the sensors of the class given also in the <code>classes</code> array.
 *
 *  @param classes Array listing all possible <code>RLADevice</code>s, or enumerating sensors (<code>RLASensor</code>) that the device should support.
 *  @param completion Block executed once the check has been performed. The block can provide a successful result as an NSArray instance containing <code>RLADevice</code>s and <code>nil</code> as an error; or return <code>nil</code> and a specific error.
 *
 *  @see devicesWithCompletionHandler:
 */
- (void)devicesWithSensorsAndOutputsOfClasses:(NSArray *)classes
                                   completion:(void(^)(NSArray*, NSError*))completion;

@end
