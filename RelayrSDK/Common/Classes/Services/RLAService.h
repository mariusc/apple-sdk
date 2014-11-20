@import Foundation;             // Apple
@class RelayrDevice;            // Relayr.framework (Public)
#import "RelayrConnection.h"    // Relayr.framework (Public/IoTs)

/*!
 *  @abstract Block indicating the result of a service query.
 */
typedef void(^RLAServiceBlockQuery)(NSError* error, id value, NSDate* date);

/*!
 *  @abstract Block indicating the result of a service action.
 */
typedef void(^RLAServiceBlockError)(NSError* error);

/*!
 *  @abstract All Relayr SDK services must implement the classes listed on this protocol.
 *  @discussion Services will check if the devices subscribed are still <i>living</i> and whehter the have subscription blocks.
 */
@protocol RLAService <NSObject>

@required
/*!
 *  @abstract It is initialised with a <code>RelayrUser</code> token.
 *  @discussion This initialiser can return <code>nil</code> if the data needed is not yet in the user.
 *
 *  @param user <code>RelayrUser</code> that will own this service.
 *	@return Fully initialised <code>RLAService</code> object or <code>nil</code>.
 */
- (instancetype)initWithUser:(RelayrUser*)user;

@required
/*!
 *  @abstract <code>RelayrUser</code> who is associated with this <code>RLAAPIService</code> instance.
 *  @discussion This object will be set at initialisation and never touched again.
 */
@property (readonly,weak,nonatomic) RelayrUser* user;

@required
/*!
 *  @abstract The state of the service connection.
 */
@property (readonly,nonatomic) RelayrConnectionState connectionState;

@required
/*!
 *  @abstract The scope of the service connection.
 *  @discussion For services like Bluetooth, this value will never change; however for services like API or MQTT, the value can fluctuate depending on your network (LAN, WAN, etc.).
 */
@property (readonly,nonatomic) RelayrConnectionScope connectionScope;

@required
/*!
 *  @abstract This methods query the device's data source for the last piece of data.
 *  @discussion The technology used for the query is dependent on which service is this method called onto.
 *
 *  @param device The device interested on.
 *  @param completion Block indicating the subscription status.
 *
 *  @see RelayrDevice
 */
- (void)queryDataFromDevice:(RelayrDevice*)device
                 completion:(RLAServiceBlockQuery)completion;

@required
/*!
 *  @abstract This method subscribes to all data from a specific device.
 *  @discussion The technology used for the subscription is dependant on which service is this method called onto.
 *
 *  @param device The device interested on.
 *  @param completion Block indicating the subscription status.
 *
 *  @see RelayrDevice
 */
- (void)subscribeToDataFromDevice:(RelayrDevice*)device
                       completion:(RLAServiceBlockError)completion;

@required
/*!
 *  @abstract This method unsubscribes to all data coming from a specific device.
 *  @discussion The technology used for the subscription is dependant on which service is this method called onto.
 *
 *  @param device The device interested on.
 *
 *  @see RelayrDevice
 */
- (void)unsubscribeToDataFromDevice:(RelayrDevice*)device;

@end
