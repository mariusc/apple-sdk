@import UIKit;              // Apple
#import "RLASensorValue.h"  // Base class

/*!
 *  @class RLASensorValueColor
 *
 *  @abstract ...
 */
@interface RLASensorValueColor : RLASensorValue

/*!
 *  @property color
 *
 *  @abstract <code>UIColor</code> value for the measured color.
 */
@property (readonly,nonatomic) UIColor* color;

@end
