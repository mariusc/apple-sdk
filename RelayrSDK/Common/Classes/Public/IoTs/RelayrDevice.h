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
 *  @abstract Secret for the MQTT messages.
 *  @discussion Take it as the device's password.
 */
@property (readonly,nonatomic) NSString* secret;

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

@end
