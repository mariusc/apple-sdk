@import Foundation;     // Apple

/*!
 *  @class RLAMappingInfo
 *
 *  @abstract It provides means to map a devices data stored under specific services and characteristics to predefined sensor classes.
 *  @discussion Transformation of the device data is being handled by the adapter class.
 *
 *  @see RLASensor
 *  @see RLABluetoothAdapter
 */
@interface RLAMappingInfo : NSObject

/**
 * @param sensorClass resulting RLASensor subclass
 * @param adapterClass RLABluetoothAdapter subclass
 * that is used to populate the sensor with data
 * @param serviceUUIDs NSArray of NSString representing the
 * necessary UUIDs which contain the characteristics which data is needed
 * @param characteristicUUIDs NSArray of NSString objects representing the
 * UUIDs which contain the values the sensor adapter needs to parse
 * @return An initialized object or nil if the object could not be created
 */

/*!
 *  @method initWithSensorClass:adapterClass:serviceUUIDs:characteristicUUIDs:
 *
 *  @abstract Designated initialiser of the specific mapping of a set of services and characteristics.
 *
 *  @param sensorClass Subclass of <code>RLASensor</code>.
 *  @param adapterClass Subclass of <code>RLABluetoothAdapter</code> that is used to populate the sensor with data.
 *  @param serviceUUIDs <code>NSArray</code> of <code>NSString</code>s representing the necessary UUIDs which contain the characteristics with the data needed.
 *  @param characteristicUUIDs <code>NSArray</code> of <code>NSString<code> objects representing the UUIDs which contain the values of the sensor adapter needs to parse.
 *	@return Fully initialised mapping or <code>nil</code> if the object could not be created.
 */
- (instancetype)initWithSensorClass:(Class)sensorClass
                       adapterClass:(Class)adapterClass
                       serviceUUIDs:(NSArray*)serviceUUIDs
                characteristicUUIDs:(NSArray*)characteristicUUIDs;

/**
 * A mapping utilizing an output class does not need any adapters
 * since the value is beeing written directly to any characteristic
 * that accepts writing
 * @param outputClass RLAOutput subclass accepting write input
 */

/*!
 *  @method initWithOutputClass:
 *
 *  @abstract A mapping utilising an output class doesn't need any adpaters since the value is being written directly to any characteristic that accepts writing.
 *
 *  @param outputClass <code>RLAOutput</code> subclass accepting write input.
 *	@return Fully initiliased mapping or <code>nil</code> if the object couldn't be created.
 *
 *  @see RLAOutput
 */
- (instancetype)initWithOutputClass:(Class)outputClass;

/*!
 *  @property adapterClass
 *
 *  @abstract <code>RLABluetoothAdapter</code> subclass.
 *
 *  @see RLABluetoothAdapter
 */
@property (readonly,nonatomic) Class adapterClass;

/*!
 *  @property sensorClass
 *
 *  @abstract <code>RLASensor</code> subclass.
 *
 *  @see RLASensor
 */
@property (readonly,nonatomic) Class sensorClass;

/*!
 *  @property outputClass
 *
 *  @abstract <code>RLAOutput</code> subclass.
 *
 *  @see RLAOutput
 */
@property (readonly,nonatomic) Class outputClass;

/*!
 *  @property serviceUUIDs
 *
 *  @abstract <code>NSArray</code> of strings representing the necessary UUIDs which contain the characteristics with the data needed.
 */
@property (readonly,nonatomic) NSArray* serviceUUIDs;

/*!
 *  @property characteristicUUIDs
 *
 *  @abstract <code>NSArray</code> of strings representing the UUIDs which contain the values the sensor adpater needs to parse.
 */
@property (readonly,nonatomic) NSArray* characteristicUUIDs;

@end
