@class RelayrDevice;    // Relayr.framework (Public)
@protocol RLAService;   // Relayr.framework (Service)
@import Foundation;     // Apple

@interface WunderbarParsing : NSObject

+ (NSDictionary*)parseData:(NSData*)data fromService:(id<RLAService>)service device:(RelayrDevice*)device atDate:(NSDate**)date;

@end
