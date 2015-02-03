#import "RLAServiceHolder.h"    // Header

#import "RelayrDevice.h"        // Relayr (Public)
#import "RLAService.h"          // Relayr (Service)

@implementation RLAServiceHolder

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithService:(id <RLAService>)service device:(RelayrDevice*)device
{
    if (!service || !device.uid.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _service = service;
        _device = device;
    }
    return self;
}

@end
