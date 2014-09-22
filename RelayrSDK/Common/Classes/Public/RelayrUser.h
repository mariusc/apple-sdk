@import Foundation;         // Apple
@class RelayrTransmitter;   // Relayr.framework (Public)
@class RelayrDevice;        // Relayr.framework (Public)

/*!
 *  @abstract The very basic entity in the relayr platform is the user. 
 *	@discussion Every user registers with an email address, a respective name and password and is assigned a unique userId. 
 *	A user can be both an application owner (a publisher) and an end user. 
 *	A user is required in order to add other entities to the relayr platform.
 */
@interface RelayrUser : NSObject <NSCoding>

/*!
 *  @abstract A representation of a relayr user and their relayr application.
 *  @discussion This property does not change during the life cycle of the <code>RelayrUser</code>
 */
@property (readonly,nonatomic) NSString* token;

/*!
 *  @abstract A unique idenfier of a <code>RelayrUser</code> instance.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract A user name for a specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract Relayr user email for a specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSString* email;

/*!
 *  @abstract Relayr applications installed the specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSSet* apps;

/*!
 *  @abstract A set of the <code>publisher</code>s listed under the specific user.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSSet* publishers;

/*!
 *  @abstract A set of the Transmitter entities owned by the specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSSet* transmitters;

/*!
 *  @abstract A set of the Device entities owned by the specific <code>RelayrUser</code> instace
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readonly,nonatomic) NSSet* devices;

/*!
 *  @abstract Devices that the specific <code>RelayrUser</code> instace has bookmarked.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call. 
 *	By Bookmarking a device you are indicating that you have a particular interest in this device. 
 *	In the relayr context, a bookmarked device will appear on a user's Developer Dashboard.
 */
@property (readonly,nonatomic) NSSet* devicesBookmarked;

/*!
 *  @abstract Queries the relayr platform for the user information.
 *  @discussion Every time this method is called a server query is launched. 
 *	Once response is returned successfuly, all the <i>readonly</i> user related properties would be populated with respective values.
 *
 *  @param completion A block indiciating whether the server query was successful or not.
 *
 *  @see queryCloudForIoTs:
 */
- (void)queryCloudForUserInfo:(void (^)(NSError* error, NSString* previousName, NSString* previousEmail))completion;

/*!
 *  @abstract Queries the relayr platform for all devices, transmitters, and bookmarked devices under the specific <code>RelayUser</code> instance.
 *  @discussion Every time this method is called a server query is launched. 
 *	Once the response is returned successfuly, all the <i>readonly</i> device related properties would be populated with the respective values.
 *
 *  @param completion A block indicating whether the server query was successful or not.
 *
 *  @see queryCloudForUserInfo:
 */
- (void)queryCloudForIoTs:(void (^)(NSError* error, NSNumber* isThereChanges))completion;

/*!
 *  @abstract Queries the relayr platform for all the application and publisher entities owned by the user.
 *  @discussion Every time this method is called a server query is launched. 
 *	Once the response is returned successfully, the <i>readonly</i> app and publisher properties would would be populated with the respective values.
 *
 *  @param completion A block indicating whether the server query was successful or not.
 */
- (void)queryCloudForUserAppsAndPublishers:(void (^)(NSError* error, NSNumber* isThereChanges))completion;

/*!
 *  @abstract It creates/register a transmitter entity in the Relayr Cloud.
 *  @discussion If this call is successful a <code>RelayrTransmitter</code> object is created and it is added to the <code>transmitters</code> array.
 *
 *  @param modelID Model representing the newly transmittter instance. Currently, this argument must be <code>nil</code>. Currently, this argument must be <code>nil</code>.
 *  @param firmwareVersion The version of the firmware running on the transmitter. Currently, this argument must be <code>nil</code>.
 *  @param name The given name to identify this transmitter. This parameter is required.
 *  @param completion Block indicating whether the server registration call was successful or not. It can be <code>nil</code>.
 *
 *  @see RelayrTransmitter
 */
- (void)registerTransmitterWithModelID:(NSString*)modelID
                        firmwareVerion:(NSString*)firmwareVersion
                                  name:(NSString*)name
                            completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion;

/*!
 *  @abstract It creates/register a device entity in the Relayr Cloud.
 *  @discussion If this call is successful a <code>RelayrDevice</code> object is created and it is added to the <code>devices</code> array.
 *
 *  @param modelID Model representing the newly model instance. This parameter is required.
 *  @param firmwareVersion The version of the firmware running on the transmitter. This parameter is required.
 *  @param name The given name to identify this transmitter. This parameter is required.
 *  @param completion Block indicating whether the server registration call was successful or not. It can be <code>nil</code>.
 *
 *  @see RelayrDevice
 */
- (void)registerDeviceWithModelID:(NSString*)modelID
                   firmwareVerion:(NSString*)firmwareVersion
                             name:(NSString*)name
                       completion:(void (^)(NSError* error, RelayrDevice* device))completion;

@end
