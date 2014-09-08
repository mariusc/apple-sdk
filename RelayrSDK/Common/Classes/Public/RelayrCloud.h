@import Foundation;     // Apple

/*!
 *  @abstract This class object represents the relayr <a href="https://developer.relayr.io/documents/Welcome/Platform">Cloud Platform</a> (it does not accept instantiation).
 *  @discussion It allows high level interaction with the relayr platform. 
 *	For example: checking if the platform is available or the connection is broken.
 */
@interface RelayrCloud : NSObject

/*!
 *  @abstract Checks if the relayr cloud platform is reachable and whether the service is up or not.
 *  @discussion The Relayr cloud may be unreachable for various reasons such as no internet connection, inability to resolve DNS, temporary unavailability of the relayr service. 
 *	Please note that you can still work with the SDK even when the relayr cloud is unavailable (in the unlikely case that this happens).
 *
 *  @param completion A block with a Boolean with the availability status of the service or an error in case of unavailibility
 */
+ (void)isReachable:(void (^)(NSError* error, NSNumber* isReachable))completion;

/*!
 *  @abstract Checks whether an email is registered on the relayr platform.
 *
 *  @param email <code>NSString</code> representing the user's email address.
 *  @param completion A Block with the respective response.
 *
 *  @see RelayrUser
 */
+ (void)isUserWithEmail:(NSString*)email registered:(void (^)(NSError* error, NSNumber* isUserRegistered))completion;

@end
