#import <Relayr/RelayrUser.h>   // Header
@class RLAAPIService;           // Relayr.framework (Service/API)
@class RLAMQTTService;          // Relayr.framework (Service/MQTT)
@class RLABLEService;           // Relayr.framework (Service/BLE)

/*!
 *  @abstract The very basic entity in the relayr platform is the user.
 *	@discussion Every user registers with an email address, a respective name and password and is assigned a unique userId.
 *	A user can be both an application owner (a publisher) and an end user.
 *	A user is required in order to add other entities to the relayr platform.
 */
@interface RelayrUser ()

/*!
 *  @abstract It initialises a <code>RelayrUser</code> with a specific OAuth token. The common initialiser <code>-init:</code> is not accepted.
 *  @discussion If <code>token</code> is <code>nil</code> or not valid, this initialiser returns <code>nil</code>.
 *
 *  @param token OAuth token for the Relayr cloud queries.
 *	@return Fully initialised <code>RelayrUser</code>.
 */
- (instancetype)initWithToken:(NSString*)token;

/*!
 *  @abstract It initialises a <code>RelayrUser</code> with a ID. However this object is not intended to be used to query the API or any other service.
 *  @discussion Only use this object to query the most basic data.
 *
 *  @param userID <code>NSString</code> representing the userID.
 *  @return Object holding the basic data of an user.
 */
- (instancetype)initWithID:(NSString*)userID;

/*!
 *  @abstract Relayr application that the user has signed in.
 */
@property (readwrite,weak,nonatomic) RelayrApp* app;

/*!
 *  @abstract This is the central connection with the Relayr.framework web module.
 *  @discussion It is never <code>nil</code>. When an instance of <code>RelayrUser</code> is created, this property is setup to a valid web service.
 */
@property (readonly,nonatomic) RLAAPIService* apiService;

/*!
 *  @abstract This is the central connection with the Relayr.framework MQTT module.
 *  @discussion It is never <code>nil</code>. When an instance of <code>RelayrUser</code> is created, this property is setup to a valid MQTT service.
 */
@property (readwrite,nonatomic) RLAMQTTService* mqttService;

/*!
 *  @abstract This is the central connection with the Relayr.framework BLE module.
 *  @discussion It is never <code>nil</code>. When an instance of <code>RelayrUser</code> is created, this property is setup to a valid BLE service.
 */
@property (readwrite,nonatomic) RLABLEService* bleService;

/*!
 *  @abstract A unique idenfier of a <code>RelayrUser</code> instance.
 */
@property (readwrite,nonatomic) NSString* uid;

/*!
 *  @abstract A user name for a specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract Relayr user email for a specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSString* email;

/*!
 *  @abstract The relayr applications under the specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSSet* apps;

/*!
 *  @abstract An array of the <code>publisher</code>s listed under the specific user.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSSet* publishers;

/*!
 *  @abstract An array of the Transmitter entities owned by the specific <code>RelayrUser</code> instace.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSSet* transmitters;

/*!
 *  @abstract An array of the Device entities owned by the specific <code>RelayrUser</code> instace
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 */
@property (readwrite,nonatomic) NSSet* devices;

/*!
 *  @abstract Devices that the specific <code>RelayrUser</code> instace has bookmarked.
 *  @discussion It can can be changed in a successful <code>queryCloudForUserInfo:</code> call.
 *	By Bookmarking a device you are indicating that you have a particular interest in this device.
 *	In the relayr context, a bookmarked device will appear on a user's Developer Dashboard.
 */
@property (readwrite,nonatomic) NSSet* devicesBookmarked;

/*!
 *  @abstract Adds a transmitter to the transmitters own by the user (and all the devices children of that transmitter).
 *  @discussion If a transmitter with the same uid is already there, no transmitter is added, but the previous transmitter is updated with the info of the new transmitter.
 *
 *  @param transmitter Transmitter to add to the user.
 *  @return <code>RelayrTransmitter</code> that will represent the transmitter passed as argument from now on. It could be the same, or it could not.
 *
 *  @see RelayrTransmitter
 */
- (RelayrTransmitter*)addTransmitter:(RelayrTransmitter*)transmitter;

/*!
 *  @abstract Removes a transmitter in the internal tree.
 *  @discussion This method doesn't make any connection to the server; it is purely local.
 *
 *  @param transmitter Transmitter to add to the user
 *
 *  @see RelayrTransmitter
 */
- (void)removeTransmitter:(RelayrTransmitter*)transmitter;

/*!
 *  @abstract Adds a device to the devices own by the user.
 *  @discussion If a device with the same uid is already there, no device is added, but the previous device is updated with the info of the new device.
 *
 *  @param device <code>RelayrDevice</code> entity to add to the user.
 *  @return <code>RelayrDevice</code> that will represent the device passed as parameter from now on. It could be the same, or it could not.
 *
 *  @see RelayrDevice
 */
- (RelayrDevice*)addDevice:(RelayrDevice*)device;

/*!
 *  @abstract Removes a device in the internal tree.
 *  @discussion This method doesn't make any connection to the server; it is purely local.
 *
 *  @param device <code>RelayrDevice</code> entity to remove locally.
 *
 *  @see RelayrDevice
 */
- (void)removeDevice:(RelayrDevice*)device;

@end
