#import "RLAAPIService.h"       // Base class
@class RelayrDevice;            // Relayr (Public)
@class RelayrDeviceModel;       // Relayr (Public)
@class RelayrFirmwareModel;     // Relayr (Public)

@interface RLAAPIService (Device)

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
 *  @discussion All arguments of this call, except <code>deviceID</code>, are optional. Thus, you may choose to just change the name of the device and pass all the other parameters as <code>nil</code>.
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
 *  @abstract Sends a blob of data to a specific device.
 *
 *  @param deviceID Device receiving the blob of data.
 *  @param meaning They type of "command" being sent.
 *  @param value The string value to send to the device.
 *  @param completion Block indicating the result of "command" sent. If the server received the command, this block will return <code>nil</code> as its parameter.
 *
 *  @note That the completion block receives <code>nil</code>, it doesn't assure that the device will receive the blob of data being sent.
 *
 *  @see RelayrWriting
 *  @see RelayrDevice
 */
- (void)sendToDeviceID:(NSString*)deviceID
           withMeaning:(NSString*)meaning
                 value:(NSString*)value
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

/*!
 *  @abstract Retrieves all available firmware models from a specific device model.
 * 
 *  @param deviceModel <code>RelayrDeviceModel</code> with a specific device modelID.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrFirmwareModel
 */
- (void)requestFirmwaresFromDeviceModel:(RelayrDeviceModel*)deviceModel
                             completion:(void (^)(NSError* error, NSArray* firmwares))completion;

/*!
 *  @abstract Retrieves a specific firmware model from a specific device model.
 *
 *  @param versionString <code>NSString</code> representing a device model.
 *  @param deviceModel <code>RelayrDeviceModel</code> with a specific device modelID.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrFirmwareModel
 */
- (void)requestFirmwareWithVersion:(NSString*)versionString
                   fromDeviceModel:(RelayrDeviceModel*)deviceModel
                        completion:(void (^)(NSError* error, RelayrFirmwareModel* firmwareModel))completion;

@end
