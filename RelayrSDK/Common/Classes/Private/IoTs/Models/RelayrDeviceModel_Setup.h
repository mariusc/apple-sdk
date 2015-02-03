#import "RelayrDeviceModel.h"    // Parent class

/*!
 *  @abstract An instance of this class models how a device should look and perform.
 */
@interface RelayrDeviceModel () <NSCoding>

/*!
 *  @abstract User currently "using" this transmitter.
 *  @discussion A public device can be owned by another Relayr user, but being used by your <code>RelayrUser</code> entity.
 */
@property (readwrite,weak,nonatomic) RelayrUser* user;

/*!
 *  @abstract It initialises a Device-model with a Relayr Device-Model ID and a name identifying it.
 *
 *  @param modelID Relayr model identifier. It identifies the device (independently of the firmware version).
 *	@return Fully instanciate <code>RelayrDeviceModel</code> or <code>nil</code>
 *
 *  @see RelayrDeviceModel
 */
- (instancetype)initWithModelID:(NSString*)modelID;

/*!
 *  @abstract Device-Model name.
 */
@property (readwrite,nonatomic) NSString* modelName;

/*!
 *  @abstract The manufacturer of the device.
 */
@property (readwrite,nonatomic) NSString* manufacturer;

/*!
 *  @abstract Array containing all possible firmware models (<code>RelayrFirmwareModel</code>) for this <code>RelayrDeviceModel</code>.
 */
@property (readwrite,nonatomic) NSArray* firmwaresAvailable;

/*!
 *  @abstract Returns an array of all possible readings the device can gather.
 *  @discussion Each item in this array is an object of type <code>RelayrReading</code>. Each input represents a different kind of reading. That is, a <code>RelayrDevice</code> can have a luminosity sensor and a gyroscope; thus, this array would have two different reading.
 *
 *  @see RelayrReading
 */
@property (readwrite,nonatomic) NSSet* readings;

/*!
 *  @abstract Returns an array of possible Writings a Device is capable of receiving.
 *  @discussion By 'Output' we refer to an object with commands or configuration settings sent to a Device.
 *	These are usually infrarred commands, ultrasound pulses etc.
 *	Each item in this array is an object of type <code>RelayrWriting</code>.
 *
 *  @see RelayrWriting
 */
@property (readwrite,nonatomic) NSSet* writings;

/*!
 *  @abstract Sets the instance where this object is being called for, with the properties of the object passed as arguments.
 *  @discussion The objects passed as arguments are considered new and thus have a higher priority.
 *
 *  @param deviceModel The newly <code>RelayrDeviceModel</code> instance.
 */
- (void)setWith:(RelayrDeviceModel*)deviceModel;


@end
