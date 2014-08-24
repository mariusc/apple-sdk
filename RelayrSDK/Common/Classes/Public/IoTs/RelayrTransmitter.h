@import Foundation;     // Apple

/*!
 *  @class RelayrTransmitter
 *
 *  @abstract An instance of this class represents a Relayr Transmitter.
 *  @discussion A Relayr transmitter usually represent a connected device that perform the functions of router, gateway, etc.
 */
@interface RelayrTransmitter : NSObject <NSCoding>

/*!
 *  @property uid
 *
 *  @abstract Relyar idenfier for the <code>RelayrTransmitter</code>'s instance.
 */
@property (readonly,nonatomic) NSString* uid;

@property (readonly,nonatomic) NSString* secret;

@property (readonly,nonatomic) NSString* name;

@property (readonly,nonatomic) NSString* owner;

@property (readonly,nonatomic) NSArray* devices;

@end
