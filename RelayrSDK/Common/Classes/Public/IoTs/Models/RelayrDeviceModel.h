@import Foundation;             // Apple
@class RelayrFirmwareModel;     // Relayr.firmware (Public)

/*!
 *  @abstract Specifies the basic functionality of a device.
 */
@interface RelayrDeviceModel : NSObject <NSCoding>

/*!
 *  @abstract The identifier of the device model within the Relayr Cloud.
 *  @discussion Inmutable
 */
@property (readonly,nonatomic) NSString* modelID;

/*!
 *  @abstract Device-Model name.
 *  @discussion Inmutable
 */
@property (readonly,nonatomic) NSString* modelName;

/*!
 *  @abstract The manufacturer of the device.
 */
@property (readonly,nonatomic) NSString* manufacturer;

/*!
 *  @abstract An array containing all possible firmware models (<code>RelayrFirmwareModel</code>) for the current <code>RelayrDeviceModel</code>.
 */
@property (readonly,nonatomic) NSArray* firmwaresAvailable;

/*!
 *  @abstract Returns an array of all possible readings the device can gather.
 *  @discussion Each item in this array is an object of type <code>RelayrInput</code>. 
 *	Each input represents a different kind of reading. 
 *	That is, a <code>RelayrDevice</code> can have a luminosity sensor and a gyroscope; thus, this array would have two different inputs.
 *
 *  @see RelayrInput
 */
@property (readonly,nonatomic) NSSet* inputs;

/*!
 *  @abstract Returns an array of possible Outputs a Device is capable of receiving.
 *  @discussion By 'Output' we refer to an object with commands or configuration settings sent to a Device.
 *	These are usually infrarred commands, ultrasound pulses etc.
 *	Each item in this array is an object of type <code>RelayrOutput</code>.
 *
 *  @see RelayrOutput
 */
@property (readonly,nonatomic) NSSet* outputs;

@end
