#import "RLAWebService.h"       // Base class
@class RelayrApp;               // Relayr.framework (Public)

/*!
 *  @abstract API calls refering to Relayr Applications (as entities).
 *
 *  @see RLAWebService
 */
@interface RLAWebService (App)

/*!
 *  @abstract It queries the Relayr Cloud for information of a Relayr application.
 *
 *  @param completion Block indicating the result of the server query.
 */
+ (void)requestAppInfoFor:(NSString*)appID
               completion:(void (^)(NSError* error, NSString* appID, NSString* appName, NSString* appDescription))completion;

/*!
 *  @abstract Retrieves all application within the Relayr cloud.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 */
- (void)requestAllRelayrApps:(void (^)(NSError* error, NSArray* apps))completion;

/*!
 *  @abstract Adds a new application to the Relayr cloud.
 *
 *  @param appName The name of the Relayr Application.
 *  @param appDescription An optional description of what the app does.
 *  @param publisher The Relayr publisher entity future owner of this Relayr application.
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
 *  @abstract Retrieves information about a specific publisher's Relayr application.
 *
 *  @param appID The Relayr unique identifier for the searched for Application.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 */
- (void)requestApp:(NSString*)appID
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
    completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Deletes/Removes a Relayr application from the Relayr cloud.
 *
 *  @param appID The Relayr unique identifier for the searched for Application.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrApp
 */
- (void)removeApp:(NSString*)appID
       completion:(void (^)(NSError* error))completion;

@end
