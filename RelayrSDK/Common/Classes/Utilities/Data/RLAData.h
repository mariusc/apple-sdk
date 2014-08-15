// Apple
@import Foundation;

/*!
 *  @class RLAData
 *
 *  @abstract It provides the means to convert data values
 */
@interface RLAData : NSData

#pragma mark - Conversion

/*!
 *  @method shortUidWithLongUidString:
 *
 *  @abstract The string representation of a long UUID and returns the short UUID package into an <code>NSData</code>.
 *
 *  @param uid <code>NSString</code> representation of the long uid.
 *	@return <code>NSData</code> representation of the short uid.
 */
+ (NSData *)shortUidWithLongUidString:(NSString *)uid;

@end
