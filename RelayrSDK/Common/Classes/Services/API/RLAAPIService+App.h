#import "RLAAPIService.h"       // Base class
@class RelayrApp;               // Relayr (Public)

/*!
 *  @abstract API calls refering to Relayr Applications (as entities).
 *
 *  @see RLAAPIService
 */
@interface RLAAPIService (App)

/*!
 *  @abstract Retrieves all application within the Relayr cloud.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 */
+ (void)requestAllRelayrApps:(void (^)(NSError* error, NSSet* apps))completion;

/*!
 *  @abstract Adds a new application to the Relayr cloud.
 *
 *  @param appName The name of the Relayr Application.
 *  @param appDescription An optional description of what the app does.
 *  @param publisher The Relayr publisher entity future owner of this Relayr applicatºion.
 *  @param redirectURI Security mechanism to certified from where the messages are coming from.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 */
- (void)registerAppWithName:(NSString*)appName
                description:(NSString*)appDescription
                  publisher:(NSString*)publisher
                redirectURI:(NSString*)redirectURI
                 completion:(void (^)(NSError* error, RelayrApp* app))completion;

/*!
 *  @abstract It queries the Relayr Cloud for information of a Relayr application.
 *  @discussion There are two API call for retrieving Relayr Application information. This one is the more limited. You don't need authorization and all information retrieved is very basic.
 *
 *  @param completion Block indicating the result of the server query.
 */
+ (void)requestAppInfoFor:(NSString*)appID
               completion:(void (^)(NSError* error, NSString* appID, NSString* appName, NSString* appDescription))completion;

/*!
 *  @abstract Retrieves information about a specific publisher's Relayr application.
 *  @discussion This request needs the token of a Relayr user. It provides more information that the static class call.
 *
 *  @param appID The Relayr unique identifier for the searched for Application.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 */
- (void)requestAppInfoExtendedFor:(NSString*)appID
        completion:(void (^)(NSError* error, RelayrApp* app))completion;

/*!
 *  @abstract Updates one or more Relayr application attributes.
 *  @discussion Some of the arguments are optional.
 *
 *  @param appID The Relayr unique identifier for the searched for Application.
 *  @param appName The name of the Relayr Application.
 *  @param appDescription An optional description of what the app does.
 *  @param redirectURI Security mechanism to certified from where the messages are coming from.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 */
- (void)setApp:(NSString*)appID
          name:(NSString*)appName
   description:(NSString*)appDescription
   redirectURI:(NSString*)redirectURI
    completion:(void (^)(NSError* error, RelayrApp* app))completion;

/*!
 *  @abstract Sets in the server an abstract connection between an app and a device.
 *  @discussion After this call, you get some credentials to open a channel between the server and a device.
 *
 *  @param appID Unique identifier within the Relayr Cloud for a specific Relayr Application.
 *  @param deviceID Unique identifier within the Relayr Cloud for a specific Relayr Device.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)setConnectionBetweenApp:(NSString*)appID
                      andDevice:(NSString*)deviceID
                     completion:(void (^)(NSError* error, id credentials))completion;

/*!
 *  @abstract Deletes the abstract connection between an app and a device.
 *
 *  @param appID Unique identifier within the Relayr Cloud for a specific Relayr Application.
 *  @param deviceID Unique identifier within the Relayr Cloud for a specific Relayr Device.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrDevice
 */
- (void)deleteConnectionBetweenApp:(NSString*)appID
                         andDevice:(NSString*)deviceID
                        completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Deletes/Removes a Relayr application from the Relayr cloud.
 *
 *  @param appID The Relayr unique identifier for the searched for Application.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 */
- (void)deleteApp:(NSString*)appID
       completion:(void (^)(NSError* error))completion;

@end
