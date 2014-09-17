@import Foundation;     // Apple
@class RelayrFirmware;  // Relayr.framework (Public)

/*!
 *  @abstract It specifies the minimum functionality of a device.
 */
@protocol RelayrDeviceModel <NSObject>

/*!
 *  @abstract Identifies the device model within the Relayr Cloud.
 */
@property (readonly,nonatomic) NSString* modelID;

/*!
 *  @abstract The manufacturer of the device.
 */
@property (readonly,nonatomic) NSString* manufacturer;

/*!
 *  @abstract Indicates firmware attributes of the Device instance being called.
 *  @discussion You can request the current version and other firmware properties.
 */
@property (readonly,nonatomic) RelayrFirmware* firmware;

/*!
 *  @abstract Returns an array of all possible readings the device can gather.
 *  @discussion Each item in this array is an object of type <code>RelayrInput</code>. Each input represents a different kind of reading. That is, a <code>RelayrDevice</code> can have a luminosity sensor and a gyroscope; thus, this array would have two different inputs.
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
