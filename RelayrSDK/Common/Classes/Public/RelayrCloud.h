@import Foundation;     // Apple
@class RelayrUser;      // Relayr.framework (Public)

/*!
 *  @abstract This class object represents the relayr <a href="https://developer.relayr.io/documents/Welcome/Platform">Cloud Platform</a> (it does not accept instantiation).
 *  @discussion It allows high level interaction with the relayr platform. 
 *	For example: checking if the platform is available or the connection is broken.
 */
@interface RelayrCloud : NSObject

#pragma mark Cloud information

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
+ (void)isUserWithEmail:(NSString*)email
             registered:(void (^)(NSError* error, NSNumber* isUserRegistered))completion;

/*!
 *  @abstract It returns an array with all public Relayr Applications in the Relayr Cloud.
 *  @discussion Be careful, since this array can be very long. The info returned is not very extended, though.
 *
 *  @param completion Block indicating the result of the query. If there is no error, an <code>NSSet</code> will be returned with all the public Relayr Applications (a short info of them, that is).
 */
+ (void)queryForAllRelayrPublicApps:(void (^)(NSError* error, NSSet* apps))completion;

#pragma mark Logging system

/*!
 *  @abstract It sends a log message to the Relayr Cloud on behalf of a Relayr User.
 *  @discussion Logging messages allows you to have information about how your application is running. You can log anything you want and later on check your adminastrator page and have statistical data from your application usage, or any other interesting metric.
 *
 *  @param message <code>NSString</code> with a looging message of your choosing. The string can be anything except <code>nil</code> or an empty string..
 *  @param user Fully setup <code>RelayrUser</code>. If this parameter is <code>nil</code> or the user was logged in unproperly, this method won't perform any job.
 *  @return Boolean indicating whether the message has been accepted to be sent by the server or not.
 */
+ (BOOL)logMessage:(NSString*)message onBehalfOfUser:(RelayrUser*)user;

#pragma mark System information

/*!
 *  @abstract It returns a <code>NSString</code> identifying the Relayr SDK version and machine.
 *  @discussion It is typically use for adding in an HTTP header.
 */
+ (NSString*)userAgentString;

/*!
 *  @abstract It returns the version number of the Relayr SDK you are currently using.
 */
+ (NSString*)sdkVersionNumber;

/*!
 *  @abstract It returns a <code>NSString</code> with the Operating system name (and version number) currently running on the SDK.
 */
+ (NSString*)operatingSystem;

/*!
 *  @abstract It returns a <code>NSString</code> with the platform name or architecture currently running on the SDK.
 */
+ (NSString*)platform;

@end
