@class RelayrUser;      // Relayr.framework (Public)
@import Foundation;     // Apple

/*!
 *  @abstract An instance of this class represents a Relayr Transmitter.
 *  @discussion A Relayr transmitter usually represent a connected device that perform the functions of router, gateway, etc.
 */
@interface RelayrTransmitter : NSObject <NSCoding>

/*!
 *  @abstract Relyar idenfier for the <code>RelayrTransmitter</code>'s instance.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract Secret for the MQTT messages.
 *  @discussion Take it as the transmitter's password.
 */
@property (readonly,nonatomic) NSString* secret;

/*!
 *  @abstract The given name of the transmitter.
 *  @discussion It can be changed by server calls.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract Owner ID of this transmitter.
 */
@property (readonly,nonatomic) NSString* owner;

/*!
 *  @abstract All the devices associated with this transmitter.
 *  @discussion All are weak links to <code>RelayrDevice</code>s owned by the <code>RelayrUser</code>.
 */
@property (readonly,nonatomic) NSArray* devices;

@end
