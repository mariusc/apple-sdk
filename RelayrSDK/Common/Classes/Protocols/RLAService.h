@import Foundation;     // Apple
@class RelayrDevice;    // Relayr.framework (Public)

/*!
 *  @abstract All Relayr SDK services must implement the classes listed on this protocol.
 */
@protocol RLAService <NSObject>

@required
/*!
 *  @abstract This methods subscribes to all data from a specific device.
 *  @discussion The technology used for the subscription is dependant on which service is this method called onto.
 *
 *  @param device The device interested on.
 *  @param completion Block indicating the subscription status.
 */
- (void)subscribeToDataFromDevice:(RelayrDevice*)device
                       completion:(void (^)(NSError* error))completion;

@required
/*!
 *  @abstract This methods query the device's data source for the last piece of data.
 *  @discussion The technology used for the query is dependent on which service is this method called onto.
 *
 *  @param device The device interested on.
 *  @param completion Block indicating the subscription status.
 */
- (void)queryDataFromDevice:(RelayrDevice*)device
                 completion:(void (^)(NSError* error, id value, NSDate* date))completion;

@end
