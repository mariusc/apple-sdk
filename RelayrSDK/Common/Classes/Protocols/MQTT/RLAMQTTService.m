#import "RLAMQTTService.h"      // Header
#import "RelayrUser.h"          // Relayr.framework (Public)
#import "RLAMQTTConstants.h"    // Relayr.framework (MQTT)

@implementation RLAMQTTService

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUser:(RelayrUser*)user
{
    if (!user.uid) { return nil; }
    
    self = [super init];
    if (self)
    {
        _hostString = dRLAMQTT_Host;
        _port = [NSNumber numberWithUnsignedInteger:dRLAMQTT_PortUnencripted];
    }
    return self;
}

@end
