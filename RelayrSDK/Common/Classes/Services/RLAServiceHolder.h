@class RelayrDevice;    // Relayr.framework (Public)
@protocol RLAService;   // Relayr.framework (Service)
@import Foundation;     // Apple

@interface RLAServiceHolder : NSObject

- (instancetype)initWithService:(id <RLAService>)service device:(RelayrDevice*)device;

@property (readonly,weak,nonatomic) id <RLAService> service;

@property (readonly,weak,nonatomic) RelayrDevice* device;

@end
