@import Foundation;     // Apple
@import CoreBluetooth;  // Apple

/**
 * This class solely exists for comppatibility reasons with iOS7
 * Since there only is a method available for converting CBUUIDs
 * into NSString objects from iOS 7.1 and upwards but the Relayr.framework
 * works from iOS 7.0 this method provides the missing functionality
 */

/*!
 *  @class RLACBUUID
 *
 *  @abstract This class solely exists for compatibility reasons with iOS7.
 *  @discussion Since there is only a method available for converting CBUUIDs into NSString objects from iOS 7.1 and upwards but the Relayr.framework works from iOS 7.0 this method provides the missing functionality.
 *
 *  @see CBUUID
 */
@interface RLACBUUID : NSObject

/*!
 *  @method UUIDStringWithCBUUID:
 *
 *  @abstract It transform a <code>CBUUID</code> into an <code>NSString</code>
 *
 *  @param uuid <code>CBUUID</code> representing a 128-bit universally unique identifier.
 *	@return String representing the <code>CBUUID</code>.
 */
+ (NSString*)UUIDStringWithCBUUID:(CBUUID*)uuid;

@end
