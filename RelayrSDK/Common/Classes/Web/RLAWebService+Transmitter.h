#import "RLAWebService.h"   // Base class
@class RelayrTransmitter;   // Relayr.framework (Public)

@interface RLAWebService (Transmitter)

/*!
 *  @abstract Registers a transmitter in the Relayr Cloud.
 *  @discussion After the successful call of this method, a <i>transmitter</i> entity is created in the Relayr Cloud.
 *
 *  @param transmitterName The given name of the transmitter
 *  @param ownerID <code>NSString</code> representing a transmitter Relayr identifier.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrTransmitter
 */
- (void)registerTransmitterWithName:(NSString*)transmitterName
                            ownerID:(NSString*)ownerID
                         completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion;

/*!
 *  @abstract Returns the information of a specific transmitter.
 *
 *  @param transmitterID <code>NSString</code> representing the unique Relayr identifier for the searched for transmitter.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrTransmitter
 */
- (void)requestTransmitter:(NSString*)transmitterID
                completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion;

/*!
 *  @abstract Sets the information stored in the server.
 *
 *  @param transmitterID <code>NSString</code> representing the unique Relayr identifier for the searched for transmitter.
 *  @param futureTransmitterName The name given to the transmitter.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrTransmitter
 */
- (void)setTransmitter:(NSString*)transmitterID
              withName:(NSString*)futureTransmitterName
            completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Sets in the server an abstract connection between a transmitter and a device.
 *  @discussion After the successful call of this method, the device will be listed under the children devices of the given transmitter.
 *
 *  @param transmitterID <code>NSString</code> representing the unique Relayr identifier for the searched for transmitter.
 *  @param deviceID <code>NSString</code> representing the unique Relayr identifier for the given device.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrTransmitter
 *  @see RelayrDevice
 */
- (void)setConnectionBetweenTransmitter:(NSString*)transmitterID
                              andDevice:(NSString*)deviceID
                             completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Requests the devices that are associated with the transmitter argument.
 *
 *  @param transmitterID <code>NSString</code> identifying the transmitter in the Relayr Cloud.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrTransmitter
 *  @see RelayrDevice
 */
- (void)requestDevicesFromTransmitter:(NSString*)transmitterID
                           completion:(void (^)(NSError* error, NSArray* devices))completion;

@end
