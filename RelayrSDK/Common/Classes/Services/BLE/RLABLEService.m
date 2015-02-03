#import "RLABLEService.h"   // Header
#import "RelayrUser.h"      // Relayr (Public)

@implementation RLABLEService

@synthesize user = _user;
@synthesize connectionState = _connectionState;
@synthesize connectionScope = _connectionScope;

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
        _connectionState = RelayrConnectionStateUnknown;
        _connectionScope = RelayrConnectionScopeUnknown;
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
