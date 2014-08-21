@import Foundation; // Apple

/*!
 *  @class RLAPeripheralnfo
 *
 *  @abstract Provides a means to store information about Bluetooth peripherals.
 *
 *  @see CBPeripheral
 */
@interface RLAPeripheralnfo : NSObject

/*!
 *  @method initWithName:bleIdentifier:relayrModelID:mappings:
 *
 *  @abstract Object aggregating the some important peripheral's characteristics: name, bleIdentifier, relayrModelID, and mappings.
 *
 *  @param name <code>NSString</code> representing the peripheral's name.
 *  @param bleIdentifier <code>NSString</code> representing the peripheral's Bluetooth identifier.
 *  @param relayrModelID <code>NSString</code> representing the peripheral's model ID. This ID is returned by the Relayr cloud during registration of a new device.
 *  @param mappings <code>NSArray</code> of <code>RLAMapping</code> info objects that is used to assign the devices services and characteristics to <code>RLASensor</code> types.
 *	@return A fully initialised object with all the peripheral (and relayr peripheral properties) information.
 *
 *  @see RLAMapping
 *  @see RLABluetoothAdapter
 */
- (instancetype)initWithName:(NSString *)name
               bleIdentifier:(NSString *)bleIdentifier
               relayrModelID:(NSString *)relayrModelID
                    mappings:(NSArray *)mappings;

/*!
 *  @property name
 *
 *  @abstract <code>NSString</code> representing the name of the <code>CBPeripheral</code>.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @property bleIdentifier
 *
 *  @abstract <code>NSString</code> representing the peripheral Bluetooth identifier.
 */
@property (readonly,nonatomic) NSString* bleIdentifier;

/*!
 *  @property relayrModelID
 *
 *  @abstract <code>NSString</code> representing the peripheral's model ID.
 */
@property (readonly,nonatomic) NSString* relayrModelID;

/*!
 *  @property mappings
 *
 *  @abstract <code>NSArray</code> of <code>RLAMapping</code> information objects.
 *
 *  @see RLAMapping
 */
@property (readonly,nonatomic) NSArray* mappings;

@end
