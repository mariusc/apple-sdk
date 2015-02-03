#import "RelayrFirmware.h"              // Parent class
#import "RelayrFirmwareModel_Setup.h"   // Relayr (Private)
@protocol RLAService;                   // Relayr (Service)

/*!
 *  @abstract Represents the firmware running on a <code>RelayrDevice</code> or a <code>RelayrTransmitter</code>.
 *
 *  @see RelayrDevice
 *  @see RelayrTransmitter
 */
@interface RelayrFirmware () <NSCoding>

/*!
 *  @abstract Sets the instance where this object is being called onto, with the properties of the object passed as the argument.
 *  @discussion The object passed as the argument is considered new and thus the properties have more priority.
 *
 *  @param firmware The newly <code>RelayrFirmware</code> instance.
 */
- (void)setWith:(RelayrFirmware*)firmware;

/*!
 *  @abstract It parses the data received on a specific service.
 *
 *  @param service Where the data is coming.
 *  @param datePtr If there is timestamp data in the blob received, this pointer is being filled with an object.
 *  @return Dictionary with the results of the parsing. The result values are identified as <code>NSString</code> meaning keys.
 */
- (NSDictionary*)parseData:(NSData*)data fromService:(id <RLAService>)service atDate:(NSDate**)datePtr;

@end
