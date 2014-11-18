#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrDeviceModel_Setup.h" // Relayr.framework (Private)
@class RelayrUser;                  // Relayr.framework (Public)

/*!
 *  @abstract An instance of this class represents a Device. A basic relayr entity
 *	@discussion A device is any external entity capable of producing measurements and sending them to a transmitter to be further sent to the relayr cloud,
 *	or one which is capable of receiving information from the relayr platform.
 *	Examples would be a thermometer, a gyroscope or an infrared sensor.
 */
@interface RelayrDevice ()

/*!
 *  @abstract It initialises a Device with a Relayr ID and an MQTT secret/password.
 *  @discussion Both arguments must be valid <code>NSString</code>s.
 *
 *  @param uid Relayr ID that identifies uniquely the device within the Relayr cloud.
 *  @param modelID Relayr model identifier. It identifies the device (independently of the firmware version).
 *	@return Fully instanciate <code>RelayrDevice</code> or <code>nil</code>
 *
 *  @see RelayrDevice
 */
- (instancetype)initWithID:(NSString*)uid modelID:(NSString*)modelID;

/*!
 *  @abstract Device name.
 *  @discussion Can be updated using a server call.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract The Id of the owner of the Device.
 *  @discussion A relayr User Id.
 */
@property (readwrite,nonatomic) NSString* owner;

/*!
 *  @abstract Indicates wheather the data gathered by the device is public (available to all users) or not (available to the Device owner only).
 *  @discussion An <code>NSNumber</code> wrapping a boolean value (use <code>.boolValue</code> to unwrap it).
 */
@property (readwrite,nonatomic) NSNumber* isPublic;

/*!
 *  @abstract Indicates firmware attributes of the Device instance being called.
 *  @discussion You can request the current version and other firmware properties.
 */
@property (readwrite,nonatomic) RelayrFirmware* firmware;

/*!
 *  @abstract The secret for MQTT comminucation with the relayr Cloud Platform
 *  @discussion Could be seen as the Device's password.
 */
@property (readwrite,nonatomic) NSString* secret;

/*!
 *  @abstract Sets the instance where this object is being called for, with the properties of the object being passed as arguments.
 *  @discussion The properties being passed as the arguments are considered new and thus have a higher priority.
 *
 *  @param device The newly <code>RelayrDevice</code> instance.
 */
- (void)setWith:(RelayrDevice*)device;

/*!
 *  @abstract This method checks if the receiving device is in any service. If so, it checks whether the service is really being in used by the device. If not, it the device is unsubscribe to the service.
 */
- (void)unsubscribeToCurrentServiceIfNecessary;

/*!
 *  @abstract This method is called everytime a value (or error) is received from any of the data source services (MQTT, BLE, etc.).
 *  @discussion The <code>valueOrError</code> parameter can be an <code>NSError</code> or any other value. If this parameter is not an error, then a date must be given or the method won't perform any work.
 *
 *  @param valueOrError Object defining the value received or the error occurred.
 *  @param date <code>NSDate</code> with the date of arrival of the value received (and optionally, when the error was received).
 */
- (void)valueReceived:(NSObject <NSCopying> *)valueOrError at:(NSDate*)date;

@end
