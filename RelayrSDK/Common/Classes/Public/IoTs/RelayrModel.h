@import Foundation;

/*!
 *  @abstract It specifies what a set of <code>RelayrDevice</code>s can do, how are they named (as a group), who is the manufacturer, etc.
 */
@interface RelayrModel : NSObject

/*!
 *  @abstract Relayr identifier for the device model.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract Device's model name.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract Manufacturer defining the current <code>RelayrModel</code>.
 */
@property (readonly,nonatomic) NSString* manufacturer;

/*!
 *  @abstract All the possible input/outputs of the <code>RelayrModel</code>.
 *  @discussion Array containing <code>RelayrReading</code> objects.
 */
@property (readonly,nonatomic) NSArray* readings;

/*!
 *  @abstract All the possible firmwares versions for the current <code>RelayrModel</code>.
 *  @discussion Array containing <code>RelayrFirmwareVersion</code> objects.
 */
@property (readonly,nonatomic) NSArray* firmwareVersions;

@end
