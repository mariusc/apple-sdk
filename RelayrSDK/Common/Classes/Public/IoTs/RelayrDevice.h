@import Foundation;     // Apple

/*!
 *  @class RelayrDevice
 *
 *  @abstract An instance of this class represents a Relayr Device, which can be capable of capting many different measures and/or transmit information (IR, etc.).
 */
@interface RelayrDevice : NSObject <NSCoding>

/*!
 *  @property uid
 *
 *  @abstract Relyar idenfier for the <code>RelayrDevice</code>'s instance.
 */
@property (readonly,nonatomic) NSString* uid;

@property (readonly,nonatomic) NSString* secret;

@property (readonly,nonatomic) NSString* name;

@property (readonly,nonatomic) NSString* owner;

@end
