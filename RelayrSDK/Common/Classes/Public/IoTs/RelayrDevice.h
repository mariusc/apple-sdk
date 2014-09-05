@class RelayrUser;      // Relayr.framework (Public)
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
 */
@property (readonly,nonatomic) NSString* owner;

/*!
 *  @abstract It informs whether the data of this device is being publicly published or the owner is the only one allowed to see it.
 */
@property (readonly,nonatomic) NSNumber* isPublic;

/*!
 *  @abstract It tells you the firmware version of the instance being called onto.
 */
@property (readonly,nonatomic) id firmwareVersion;

/*!
 *  @abstract The model type of the current device.
 *  @discussion The "model" represents the uid of the model within the Relayr Cloud, its name, manufacturer, what inputs and outputs accepts, etc.
 */
@property (readonly,nonatomic) id model;

/*!
 *  @abstract Secret for the MQTT messages.
 *  @discussion Take it as the device's password.
 */
@property (readonly,nonatomic) NSString* secret;

@end
