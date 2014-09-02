@import Foundation;     // Apple

/*!
 *  @class RelayrCloud
 *
 *  @abstract This class object (it doesn't accept instantiation) represents the Relayr cloud.
 *  @discussion It allows you to interact with the Relayr cloud in a higher level manner. Such as check whether the Relayr cloud is available or the connection is broken.
 */
@interface RelayrCloud : NSObject

/*!
 *  @method isReachable:
 *
 *  @abstract It checks whether the Relayr cloud is reachable (needs internet connection) and the service is up.
 *  @discussion The Relayr cloud can be unreachable for several reasons: no internet connection, cannot resolve DNS, Relayr service is temporarily unavailable. It is worth noticing, that you can still work with the SDK even when the Relayr cloud is unavailable (in the unlikely case that that happened).
 *
 *  @param completion Block giving you a Boolean answer about the availability of the service and an error explaining the unreachability (in case that happened).
 */
+ (void)isReachable:(void (^)(NSError* error, NSNumber* isReachable))completion;

/*!
 *  @method isUserWithEmail:registered:
 *
 *  @abstract It checks whether a email is registered into the Relayr cloud.
 *
 *  @param email <code>NSString</code> representing the user's email.
 *  @param completion Block answering the query.
 *
 *  @seea RelayrUser
 */
+ (void)isUserWithEmail:(NSString*)email registered:(void (^)(NSError* error, NSNumber* isUserRegistered))completion;

@end
