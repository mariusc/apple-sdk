#import "RLAMQTTService.h"          // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RLAMQTTConstants.h"        // Relayr.framework (Protocols/MQTT)
#import "RLAIdentifierGenerator.h"  // Relayr.framework (Utilities)

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
        _user = user;
        _hostString = dRLAMQTT_Host;
        _port = [NSNumber numberWithUnsignedInteger:dRLAMQTT_PortUnencripted];
        
        NSString* tmp = [RLAIdentifierGenerator generateIDFromUserID:user.uid withMaximumRandomNumber:dRLAMQTT_ClientIDMaxRandomNum];
    }
    return self;
}

#pragma mark RLAService protocol

- (void)queryDataFromDevice:(RelayrDevice*)device completion:(void (^)(NSError* error, id value, NSDate * date))completion
{
    
}

- (void)subscribeToDataFromDevice:(RelayrDevice*)device completion:(void (^)(NSError* error))completion
{
    
}

- (void)unsubscribeToDataFromDevice:(RelayrDevice*)device
{
    
}

@end
