@import Foundation;     // Apple
@class RLASensor;       // Relayr.framework

/*!
 *  @class RLADevice
 *
 *  @abstract A <code>RLADevice</code> object defines a common set of methods for all device classes that suffice for performing common tasks like getting values and finding and identifiying devices.
 */
@interface RLADevice : NSObject

#pragma mark Identification

/*!
 *  @property uid
 *
 *  @abstract ID assigned to the device by relayr during registration of the device.
 *  @discussion It returns a <code>NSString</code> explicitlely identifying the device.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @property modelID
 *
 *  @abstract ID identifiying a device class with specific capabilities.
 *  @discussion It returns a <code>NSString</code> representation of the model identifier.
 */
@property (readonly,nonatomic) NSString* modelID;

#pragma mark Info

/*!
 *  @property name
 *
 *  @abstract Name of the device. Typically choosen by the user during registration
 *  @discussion It returns a <code>NSString</code> containing the device name.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @property manufacturer
 *
 *  @abstract Name of the device manufacturer
 *  @discussion It returns an <code>NSString</code> containing the name of the device manufacturer.
 */
@property (readonly,nonatomic) NSString* manufacturer;

#pragma mark Sensors

/*!
 *  @property sensors
 *
 *  @abstract It returns information about the sensors available on the device.
 */
@property (readonly,nonatomic) NSArray* sensors;

/**
 * Returns one sensor matching the specified class
 * @param class RLASensor subclass
 * @return Found RLASensor subclass or nil if none was found
 */

/*!
 *  @method sensorOfClass:
 *
 *  @abstract Returns one sensor matching the specified class.
 *
 *  @param class RLASensor subclass.
 *  @return Found RLASensor subclass or nil if none was found.
 */
- (RLASensor *)sensorOfClass:(Class)class;

/**
 * Returns sensors matching the specified class
 * @param class RLASensor subclass
 * @return Array of RLASensor subclasses or nil if none was found
 */

/*!
 *  @method sensorsOfClass:
 *
 *  @abstract Returns sensors matching the specified class
 *  @param class RLASensor subclass
 *  @return Array of RLASensor subclasses or nil if none was found
 */
- (NSArray *)sensorsOfClass:(Class)class;

#pragma mark Monitoring

/*!
 *  @property isConnected
 *
 *  @abstract <code>BOOL</code> value indicating if the device is currently receiving sensor content data.
 */
@property (readonly,nonatomic) BOOL isConnected;

/*!
 *  @method connectWithSuccessHandler:
 *
 *  @abstract Starts streaming sensor and input data.
 *  @discussion When an error occues the handler is beeing called with it otherwise the error object equals <code>nil</code>.
 *
 *  @param handler (void(^)(NSError *error))handler
 */
- (void)connectWithSuccessHandler:(void(^)(NSError*))handler;

/*!
 *  @method disconnectWithSuccessHandler:
 *
 *  @abstract Stops updating the devices sensors and outputs with data.
 *  @discussion Calling this method is not obligatory. <code>RLADevice</code> objects will automatically unsubscribe from any data stream once they get deallocated.
 *
 *  @param handler When an error occues the handler is beeing called with it
 * otherwise the error object equals <code>nil</code>.
 */
- (void)disconnectWithSuccessHandler:(void(^)(NSError*))handler;

#pragma mark Error handling

/*!
 *  @method setErrorHandler:
 *
 *  @abstract ...
 *
 *  @param handler When an error occures the handler is beeing called with it
 * otherwise the error object equals <code>nil</code>.
 */
- (void)setErrorHandler:(void(^)(NSError*))handler;

#pragma mark Outputs

/*!
 *  @property outputs
 *
 *  @abstract ...
 */
@property (readonly,nonatomic) NSArray* outputs;

@end
