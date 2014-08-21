@import Foundation;         // Apple
@class UIViewController;    // Apple

/*!
 *  @class RLAWebService
 *
 *  @abstract Central hub for the web related Relayr calls.
 */
@interface RLAWebService : NSObject

/*!
 *  @method serviceWithClientID:appID:appSecret:redirectURI:presentingViewController:withCompletionHandler:
 *
 *  @abstract It presents a login form that enables the user to login to the relayr server via OAuth.
 *  @discussion ...
 *
 *  @param clientID An <code>NSString</code> representation of the OAuth client identifier.
 *  @param appID An <code>NSString</code> representation of a Relayr app ID.
 *  @param secret <code>NSString</code> representation of the Relayr app secret.
 *  @param uri <code>NSString</code> representing the OAuth redirect URI. This is being assigned by the developer via relayr's developer dashboard.
 *  @param presenting The view controller object that represents the current context for presentation.
 *  @param completion When the attempt to send the request is finished, the completion block is called with a valid OAuth access token upon success or an error object describing the error upon failure.
 */
//+ (void)serviceWithClientID:(NSString*)clientID
//                      appID:(NSString*)appID
//                  appSecret:(NSString*)secret
//                redirectURI:(NSString*)uri
//   presentingViewController:(UIViewController*)presenting
//      withCompletionHandler:(void(^)(RLAWebService*, NSError*))completion;

#pragma mark Devices requests

/*!
 *  @method devicesWithCompletionHandler:
 *
 *  @abstract It fetches a list of devices that have been registered to the user from the server.
 *
 *  @param completion When the attempt to send the request is finished, the completion block is called with the appropriate objects.
 */
//- (void)devicesWithCompletionHandler:(void(^)(NSArray*, NSError*))completion;

/*!
 *  @method registerDeviceWithModelID:firmwareVersion:name:description:completion:
 *
 *  @abstract It registers a device for the currently logged in user via relayrAPI.
 *
 *  @param modelID <code>NSString</code> representation of the device bluetooth id
 *  @param firmwareVersion NSString representation of the firmware version
 *  @param name User defined NSString representation of the device name
 *  @param description User defined NSString representation device description
 * (this may be nil)
 *  @param completion When the attempt to send the request is finished the completion block is beeing called with the appropriate objects.
 */
//- (void)registerDeviceWithModelID:(NSString*)modelID
//                  firmwareVersion:(NSString*)firmwareVersion
//                             name:(NSString*)name
//                      description:(NSString*)description
//                       completion:(void(^)(RLARemoteDevice*, NSError*))completion;

/*!
 *  @method registerWunderbarCompletion:
 *
 *  @abstract Registers a complete Wunderbar including all sensors and outputs for the currently logged in user via relayrAPI.
 *
 *  @param completion When the attempt to send the request is finished the completion block is beeing called with a nil error object on success otherwise it contains information about the error
 */
//- (void)registerWunderbarCompletion:(void(^)(RLACredentialsWunderbar*, NSError*))completion;

@end
