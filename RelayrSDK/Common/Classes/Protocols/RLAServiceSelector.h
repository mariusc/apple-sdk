@import Foundation;     // Apple
@class RelayrDevice;    // Relayr.framework (Public)
@protocol RLAService;   // Relayr.framework (Protocols)

/*!
 *  @abstract Static class that selects services depending on some current values.
 *
 *  @see RLAService
 */
@interface RLAServiceSelector : NSObject

/*!
 *  @abstract It selects the best service for a specific <code>RelayrDevice</code>.
 *  @discussion This method will check first if there is a service running on the passed device through @link serviceCurrentlyInUsedByDevice: @/link.
 *
 *  @param device The device which you are trying to obtain the best service to get its information.
 *  @param completion Block indicating the result of the service search.
 *
 *  @see RLAService
 */
+ (void)selectServiceForDevice:(RelayrDevice*)device completion:(void (^)(id <RLAService> service))completion;

/*!
 *  @abstract It returns the service providing the information of the passed object.
 *  @discussion If no service is provinding any information, the return value is <code>nil</code>.
 *
 *  @param device The device which you are trying to obtain the service from.
 *	@return Object implementing the <code>RLAService</code> protocol that is currently <i>servicing</i> the information to the SDK, or <code>nil</code> if no service is being executed for this device.
 *
 *  @see RLAService
 */
+ (id <RLAService>)serviceCurrentlyInUseByDevice:(RelayrDevice*)device;

@end
