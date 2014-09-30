@class RelayrDevice;        // Relayr.framework (Public)
@class RelayrDeviceModel;   // Relayr.framework (Public)
@import Foundation;         // Apple

/*!
 *  @abstract Represents a type of writing/output (command or configuration) a relayr device (for example, a sensor) can receive.
 */
@interface RelayrOutput : NSObject <NSCoding>

/*!
 *  @abstract The source of the output/writing. 
 *  @discussion This property will never be <code>nil</code>.
 */
@property (readonly,weak,nonatomic) RelayrDeviceModel* device;

/*!
 *  @abstract The name of the type of writing/output the <code>RelayrDevice</code> can receive.
 *  @discussion It currently only accepts two types of meaning: "led" and <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* meaning;

/*!
 *  @abstract Sends the value to the device containing this <code>RelayrOutput</code>.
 *  @discussion Currently only <code>NSString</code> values are accepted. This will change in future releases.
 *
 *  @param value NSString in UTF8 format to send to the <code>RelayrDevice</code>
 *  @param completion A Block indicating whether the value was received by the server (<code>error</code> is <code>nil</code>) or not.
 */
- (void)sendValue:(NSString*)value withCompletion:(void (^)(NSError* error))completion;

@end
