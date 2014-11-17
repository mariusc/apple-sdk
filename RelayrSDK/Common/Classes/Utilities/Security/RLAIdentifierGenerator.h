@import Foundation;     // Apple

/*!
 *  @abstract Group of methods to generate identifiers.
 */
@interface RLAIdentifierGenerator : NSObject

/*!
 *  @abstract It generates an identifier compose of the <code>RelayrUser</code> ID plus an underbar plus a random number of a given maximum.
 *
 *  @param userID String with the Relayr Unique Identifier of a <code>RelayrUser</code>. If <code>nil</code> or its length is zero, <code>nil</code> is returned.
 *  @param max Maxium number allowed for the random generator.
 *	@return <code>NSString</code> with a the Relayr unique identifier and an underbar and a random number appended.
 *
 *  @see RelayrUser
 */
+ (NSString*)generateIDFromBaseString:(NSString*)userID withMaximumRandomNumber:(NSUInteger)max;

/*!
 *  @abstract Unique identifier for the current device and the current app.
 *  @discussion This identifier will be the same for the same app bundle identifier and the same device.
 *
 *	@return <code>NSString</code> uniquely identifiying your device+app.
 *
 *  @see UIDevice
 */
+ (NSString*)identifierForVendor;

/*!
 *  @abstract It generates a <code>NSString</code> with a random number between 0 and the maximum random number given.
 *
 *  @return <code>NSString</code> with a random generated number.
 */
+ (NSString*)randomIDWithMaximumRandomNumber:(NSUInteger)max;

@end
