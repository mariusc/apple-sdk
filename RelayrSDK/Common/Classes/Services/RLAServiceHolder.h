@class RelayrDevice;    // Relayr (Public)
@protocol RLAService;   // Relayr (Service)
@import Foundation;     // Apple

/*!
 *  @abstract It holds weak pointer to variables of interest for the communication services.
 *  @discussion This object is just a generic container that will be signaled everytime a variable is deallocated.
 */
@interface RLAServiceHolder : NSObject

/*!
 *  @abstract It initialises the generic holder with the arguments given.
 *  @discussion The object will be inmmutable later on with the exception of being signaled when an object is deallocated by the system.
 *
 *  @param service Communication service that you want to monitor.
 *	@param device Device that you want to monitor.
 *
 *  @see RLAService
 *  @see RelayrDevice
 */
- (instancetype)initWithService:(id <RLAService>)service device:(RelayrDevice*)device;

/*!
 *  @abstract It returns the monitored service.
 *
 *  @see RLAService
 */
@property (readonly,weak,nonatomic) id <RLAService> service;

/*!
 *  @abstract It returns the monitored <code>RelayrDevice</code>.
 *
 *  @see RelayrDevice
 */
@property (readonly,weak,nonatomic) RelayrDevice* device;

@end
