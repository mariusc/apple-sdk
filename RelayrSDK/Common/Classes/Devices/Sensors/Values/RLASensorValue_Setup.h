#import "RLASensorValue.h"      // Base class

/*!
 *  @class RLASensorValue
 *
 *  @abstract It provides the means to initiliase an aobject with key/value data.
 */
@interface RLASensorValue ()

/*!
 *  @method initWithDictionary:
 *
 *  @abstract It initialises a sensor value object with a dictionary of raw data.
 *
 *  @param values <code>NSDictionary</code> containing key/value data.
 *	@return ...
 */
- (instancetype)initWithDictionary:(NSDictionary*)values;

@end
