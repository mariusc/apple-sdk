@import Foundation; // Apple

/*!
 *  @abstract The logging class for relayr.framework.
 */
@interface RLALog : NSObject

/*!
 *  @abstract Called to log a message (when the build settings are set to DEBUG).
 *
 *  @param format A String containing the message format specifiers.
 *  @param ... Variadic argument containing all values in the <code>format</code> string.
 */
+ (void)debug:(NSString *)format, ...;

/*!
 *  @abstract Called to log an error.
 *
 *  @param format A String containing the message format specifiers.
 *  @param ... Variadic argument containing all values in the <code>format</code> string.
 */
+ (void)error:(NSString *)format, ...;

@end
