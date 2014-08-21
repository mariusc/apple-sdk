@import Foundation;     // Apple
#import "RLADevice.h"   // Realayr.framework

/*!
 *  @class RLACredentialsWunderbar
 *
 *  @abstract ...
 */
@interface RLACredentialsWunderbar : NSObject

/*!
 *  @method initWithWunderbarUID:wunderbarSecret:htu:gyro:light:microphone:bridge:ir:
 *
 *  @abstract ...
 *
 *  @param uid ...
 *  @param secret ...
 *  @param htu ...
 *  @param gyro ...
 *  @param light ...
 *  @param microphone ...
 *  @param bridge ...
 *  @param ir ...
 *	@return ...
 *
 *  @see RLADevice
 */
- (instancetype)initWithWunderbarUID:(NSString*)uid
                     wunderbarSecret:(NSString*)secret
                                 htu:(RLADevice*)htu
                                gyro:(RLADevice*)gyro
                               light:(RLADevice*)light
                          microphone:(RLADevice*)microphone
                              bridge:(RLADevice*)bridge
                                  ir:(RLADevice*)ir;

/*!
 *  @property uid
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @property secret
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSString* secret;

/*!
 *  @property htu
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) RLADevice* htu;

/*!
 *  @property gyro
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) RLADevice* gyro;

/*!
 *  @property light
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) RLADevice* light;

/*!
 *  @property microphone
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) RLADevice* microphone;

/*!
 *  @property bridge
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) RLADevice* bridge;

/*!
 *  @property ir
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) RLADevice* ir;

/*!
 *  @method deviceWithModelID:
 *
 *  @abstract ...
 *
 *  @param modelID ...
 */
- (RLADevice*)deviceWithModelID:(NSString*)modelID;

@end
