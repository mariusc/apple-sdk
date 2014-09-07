@class RelayrUser;      // Relayr.framework (Public)
@class RelayrFirmware;  // Relayr.framework (Public)
@import Foundation;     // Apple

/*!
 *  @abstract An instance of this class represents a Relayr Device, which can be capable of capting many different measures and/or transmit information (IR, etc.).
 */
@interface RelayrDevice : NSObject <NSCoding>

/*!
 *  @abstract Relyar idenfier for the <code>RelayrDevice</code>'s instance.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract The given name of the device.
 *  @discussion It can be changed by server calls.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract Owner ID of this device.
 *  @discussion It is a Relayr ID.
 */
@property (readonly,nonatomic) NSString* owner;

/*!
 *  @abstract Manufacturer of the device.
 */
@property (readonly,nonatomic) NSString* manufacturer;

/*!
 *  @abstract It informs whether the data of this device is being publicly published or the owner is the only one allowed to see it.
 *  @discussion It is a <code>NSNumber</code> wrapping a boolean value (use <code>.boolValue</code> to unwrap it). An object is used instead of <code>BOOL</code> to express the absence of knowing whether the device is public or not. Meaning, that the server hasn't been queried yet.
 */
@property (readonly,nonatomic) NSNumber* isPublic;

/*!
 *  @abstract It informs you about the firmware of the instance being called onto.
 *  @discussion You can query the firmware about the current version and its properties.
 */
@property (readonly,nonatomic) RelayrFirmware* firmware;

/*!
 *  @abstract All possible "readings" that the device can perform.
 *  @discussion Each member of this array (if any) is an object of type <code>RelayrInput</code>.
 *
 *  @see RelayrInput
 */
@property (readonly,nonatomic) NSArray* inputs;

/*!
 *  @abstract All possible "outputs" signals from the device to the outside world.
 *  @discussion These are usually "infrarred commands", ultrasound pulses, etc. Each member of this array (if any) is an object of type <code>RelayrOutput</code>.
 *
 *  @see RelayrOutput
 */
@property (readonly,nonatomic) NSArray* outputs;

/*!
 *  @abstract Secret for the MQTT messages.
 *  @discussion Take it as the device's password.
 */
@property (readonly,nonatomic) NSString* secret;

@end
