@import Foundation;     // Apple

/*!
 *  @class RLALog
 *
 *  @abstract It logs any message in a relayr friendly format.
 */
@interface RLALog : NSObject

/*!
 *  @method debug:...
 *
 *  @abstract It logs a message when the build settings are set to DEBUG
 *
 *  @param format <code>NSString</code> containing the message format specifiers.
 *  @param ... Variadic argument containing all values in the <code>format</code> string.
 */
+ (void)debug:(NSString *)format, ...;

/*!
 *  @method error:...
 *
 *  @abstract It logs an error message in a relayr friendly format.
 *
 *  @param format <code>NSString</code> containing the message format specifiers.
 *  @param ... Variadic argument containing all values in the <code>format</code> string.
 */
+ (void)error:(NSString *)format, ...;

@end
