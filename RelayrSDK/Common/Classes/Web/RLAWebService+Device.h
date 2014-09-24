#import "RLAWebService.h"       // Base class
@class RelayrDevice;            // Relayr.framework (Public)
@class RelayrDeviceModel;       // Relayr.framework (Public)

@interface RLAWebService (Device)

/*!
 *  @abstract Adds a new device entity to the Relayr Cloud.
 *  @discussion You must provide all arguments.
 *
 *  @param deviceName The device name (identifier).
 *  @param ownerID The Relayr user that will own this device entity.
 *  @param modelID The Relayr unique identifier for the device model.
 *  @param firmwareVersion The version of the firmware running on the device.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)registerDeviceWithName:(NSString*)deviceName
                         owner:(NSString*)ownerID
                         model:(NSString*)modelID
               firmwareVersion:(NSString*)firmwareVersion
                    completion:(void (^)(NSError* error, RelayrDevice* device))completion;

/*!
 *  @abstract Retrieves the device information that the Relayr Cloud has.
 *
 *  @param deviceID Unique identifier within the Relayr Cloud for the device.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)requestDevice:(NSString*)deviceID
           completion:(void (^)(NSError* error, RelayrDevice* device))completion;

/*!
 *  @abstract Updates one or more Relayr application attributes.
 *  @discussion All arguments of this call, except <code>deviceID</code>, are optional.
 *
 *  @param deviceID Unique identifier within the Relayr Cloud for the device.
 *  @param futureModelID The Relayr unique identifier for the device model.
 *  @param isPublic Whether the device will be public or not
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)setDevice:(NSString*)deviceID
             name:(NSString*)deviceName
          modelID:(NSString*)futureModelID
         isPublic:(NSNumber*)isPublic
      description:(NSString*)description
       completion:(void (^)(NSError* error, RelayrDevice* device))completion;

/*!
 *  @abstract Delete a Relayr device entity from the Relayr Cloud.
 *
 *  @param deviceID Unique identifier within the Relayr Cloud for the device.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)deleteDevice:(NSString*)deviceID
          completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Sets in the server an abstract connection between a device and an app.
 *  @discussion After this call, you get some credentials to open a channel between the server and a device.
 *
 *  @param deviceID Unique identifier within the Relayr Cloud for a specific Relayr Device.
 *  @param appID Unique identifier within the Relayr Cloud for a specific Relayr Application.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)setConnectionBetweenDevice:(NSString*)deviceID
                            andApp:(NSString*)appID
                        completion:(void (^)(NSError* error, id credentials))completion;

/*!
 *  @abstract Retrieves all the Relayr Application connected to the passed Relayr Device.
 *
 *  @param deviceID Unique identifier within the Relayr Cloud for a specific Relayr Device.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 *  @see RelayrDevice
 */
- (void)requestAppsConnectedToDevice:(NSString*)deviceID
                          completion:(void (^)(NSError* error, NSSet* apps))completion;

/*!
 *  @abstract Deletes the abstract connection between a device and an app.
 *
 *  @param deviceID Unique identifier within the Relayr Cloud for a specific Relayr Device.
 *  @param appID Unique identifier within the Relayr Cloud for a specific Relayr Application.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)deleteConnectionBetweenDevice:(NSString*)deviceID
                               andApp:(NSString*)appID
                           completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Retrieves all the public Relayr devices entities.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)requestPublicDevices:(void (^)(NSError* error, NSSet* devices))completion;

/*!
 *  @abstract Retrieves all the public Relayr devices entities filtered by meaning.
 *
 *  @param meaning The type of input the device reads.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)requestPublicDevicesFilteredByMeaning:(NSString*)meaning
                                   completion:(void (^)(NSError* error, NSSet* devices))completion;

/*!
 *  @abstract Sets in the server an abstract connection between a public device and an unspecified endpoint. No credentials are needed.
 *  @discussion After this call, you get some credentials to open a channel between the server and a device. There is no need to close/delete this channel, since public devices have open channels.
 *
 *  @param deviceID Unique identifier within the Relayr Cloud for a specific Relayr Device.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
+ (void)setConnectionToPublicDevice:(NSString*)deviceID
                         completion:(void (^)(NSError* error, id credentials))completion;

/*!
 *  @abstract Retrieves all device-models supported by the Relayr Cloud.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)requestAllDeviceModels:(void (^)(NSError* error, NSSet* deviceModels))completion;

/*!
 *  @abstract Retrieves a specific device-model from the Relayr Cloud.
 *
 *  @param deviceModelID Unique identifier within the Relayr Cloud for a specific Relayr Device-Model.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)requestDeviceModel:(NSString*)deviceModelID
                completion:(void (^)(NSError* error, RelayrDeviceModel* deviceModel))completion;

/*!
 *  @abstract Retrieves all meanings within the Relayr Cloud.
 *
 *  @param completion Block indicating the result of the server query. The meaning dictionary contains as keys the values accepted by the server and as values the english naming.
 *
 *  @see RelayrDevice
 */
- (void)requestAllDeviceMeanings:(void (^)(NSError* error, NSDictionary* meanings))completion;

@end
