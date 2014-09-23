#import "RLAWebService.h"
@class RelayrTransmitter;

@interface RLAWebService (Wunderbar)

/*!
 *  @abstract <#Brief intro#>
 *  @discussion <#Description with maybe some <code>Code</code> and links to other methods {@link method:name:}#>
 *
 *  @param completion <#Description#>
 *
 *  @see RLAWebService
 */
- (void)registerWunderbar:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion;

@end
