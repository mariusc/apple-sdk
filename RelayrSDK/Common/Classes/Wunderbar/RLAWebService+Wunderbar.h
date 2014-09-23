#import "RLAWebService.h"
@class RelayrTransmitter;

@interface RLAWebService (Wunderbar)

/*!
 *  @abstract Creates/Registers a transmitter entity and six devices on the server.
 *
 *  @param completion Block indicating whether the operation was successful or not.
 *
 *  @see RLAWebService
 */
- (void)registerWunderbar:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion;

@end
