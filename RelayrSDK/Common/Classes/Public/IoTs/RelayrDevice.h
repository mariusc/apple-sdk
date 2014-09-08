@class RelayrUser;      // Relayr.framework (Public)
@class RelayrFirmware;  // Relayr.framework (Public)
@import Foundation;     // Apple

/*!
 *  @abstract An instance of this class represents a Device. A basic relayr entity
 *	@discussion A device is any external entity capable of producing measurements and sending them to a transmitter to be further sent to the relayr cloud, 
 *	or one which is capable of receiving information from the relayr platform. 
 *	Examples would be a thermometer, a gyroscope or an infrared sensor.
 */
@interface RelayrDevice : NSObject <NSCoding>

/*!
 *  @abstract A unique idenfier of the <code>RelayrDevice</code>'s instance.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract Device name.
 *  @discussion Can be updated using a server call.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract The Id of the owner of the Device.
 *  @discussion A relayr User Id.
 */
@property (readonly,nonatomic) NSString* owner;

/*!
 *  @abstract The manufacturer of the device.
 */
@property (readonly,nonatomic) NSString* manufacturer;

/*!
 *  @abstract Indicates wheather the data gathered by the device is public (available to all users) or not (available to the Device owner only). 
 *  @discussion An <code>NSNumber</code> wrapping a boolean value (use <code>.boolValue</code> to unwrap it). 
 */
@property (readonly,nonatomic) NSNumber* isPublic;

/*!
 *  @abstract Indicates firmware attributes of the Device instance being called.
 *  @discussion You can request the current version and other firmware properties.
 */
@property (readonly,nonatomic) RelayrFirmware* firmware;

/*!
 *  @abstract Returns an array of all possible readings the device can gather.
 *  @discussion Each item in this array is an object of type <code>RelayrInput</code>.
 *
 *  @see RelayrInput
 */
@property (readonly,nonatomic) NSArray* inputs;

/*!
 *  @abstract Returns an array of possible Outputs a Device is capable of receiving.
 *  @discussion By 'Output' we refer to an object with commands or configuration settings sent to a Device.
 *	These are usually infrarred commands, ultrasound pulses etc. 
 *	Each item in this array is an object of type <code>RelayrOutput</code>.
 *
 *  @see RelayrOutput
 */
@property (readonly,nonatomic) NSArray* outputs;

/*!
 *  @abstract The secret for MQTT comminucation with the relayr Cloud Platform
 *  @discussion Could be seen as the Device's password.
 */
@property (readonly,nonatomic) NSString* secret;

@end
