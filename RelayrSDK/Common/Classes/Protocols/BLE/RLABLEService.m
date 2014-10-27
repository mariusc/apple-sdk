#import "RLABLEService.h"   // Header
#import "RelayrUser.h"      // Relayr.framework (Public)

@implementation RLABLEService

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
