#import <Relayr/RelayrUser.h>

@interface RelayrUser (Wunderbar)

/*!
 *  @abstract It creates/register a transmitter entity in the Relayr Cloud and six Relayr devices.
 *
 *  @param name The given name to identify this wunderbar (which is a transmitter). This parameter is required.
 *  @param completion Block indicating whether the server registration call was successful or not. It can be <code>nil</code>.
 *
 *  @see RelayrUser
 */
- (void)registerWunderbarWithName:(NSString*)name
                       completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion;

@end
