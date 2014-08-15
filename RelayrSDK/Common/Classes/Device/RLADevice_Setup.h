#import "RLADevice.h"

@interface RLADevice ()

#pragma mark Identification

/*!
 *  @property uid
 *
 *  @abstract ID assigned to the device by relayr during registration of the device.
 *  @discussion It returns a <code>NSString</code> explicitlely identifying the device.
 */
@property (readwrite,nonatomic) NSString* uid;

/*!
 *  @property modelID
 *
 *  @abstract ID identifiying a device class with specific capabilities.
 *  @discussion It returns a <code>NSString</code> representation of the model identifier.
 */
@property (readwrite,nonatomic) NSString* modelID;

#pragma mark Info

/*!
 *  @property name
 *
 *  @abstract Name of the device. Typically choosen by the user during registration
 *  @discussion It returns a <code>NSString</code> containing the device name.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @property manufacturer
 *
 *  @abstract Name of the device manufacturer
 *  @discussion It returns an <code>NSString</code> containing the name of the device manufacturer.
 */
@property (readwrite,nonatomic) NSString* manufacturer;

#pragma mark Sensors

/*!
 *  @property sensors
 *
 *  @abstract It returns information about the sensors available on the device.
 */
@property (readwrite,nonatomic) NSArray* sensors;

#pragma mark Credentials

/*!
 *  @property secret
 *
 *  @abstract <code>NSString</code> representation of the device's password.
 */
@property (readwrite,nonatomic) NSString* secret;

#pragma mark Outputs

/*!
 *  @property outputs
 *
 *  @abstract ...
 */
@property (readwrite,nonatomic) NSArray* outputs;

@end
