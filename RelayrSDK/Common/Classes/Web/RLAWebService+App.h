#import "RLAWebService.h"

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
+ (void)requestAppInfoFor:(NSString*)appID completion:(void (^)(NSError* error, NSString* appID, NSString* appName, NSString* appDescription))completion;

@end
