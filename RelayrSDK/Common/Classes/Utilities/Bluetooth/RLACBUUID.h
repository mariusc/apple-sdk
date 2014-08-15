@import Foundation;    // Apple
@import CoreBluetooth; // Apple

/**
 * This class solely exists for iOS 7.0 compatibility reasons: there is a method available for converting CBUUIDs into NSString objects from iOS 7.1 and onwards but the Relayr.framework needs to support iOS 7.0 on. This method provides the missing functionality.
 */

/*!
 *  @class RLACBUUID
 *
 *  @abstract Convert a CBUUID into an NSString representation of that UUID.
 *  @discussion Since there is only a method available for converting CBUUIDs into NSString objects from iOS 7.1 and upwards but the Relayr.framework works from iOS 7.0 this method provides the missing functionality.
 *
 *  @see CBUUID
 */
@interface RLACBUUID : NSObject

/*!
 *  @method UUIDStringWithCBUUID:
 *
 *  @abstract When called a given <code>CBUUID</code> is converted into an <code>NSString</code> representation of the UUID.
 *
 *  @param uuid <code>CBUUID</code> representing a 128-bit universally unique identifier.
 *	@return String representing the <code>CBUUID</code>.
 */
+ (NSString*)UUIDStringWithCBUUID:(CBUUID*)uuid;

@end
