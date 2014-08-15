#import "RLAPeripheralnfo.h" // Headers

@implementation RLAPeripheralnfo

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithName:(NSString *)name bleIdentifier:(NSString *)bleIdentifier relayrModelID:(NSString *)relayrModelID mappings:(NSArray *)mappings
{
    RLAErrorAssertTrueAndReturnNil(name, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(bleIdentifier, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(relayrModelID, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturnNil(mappings, RLAErrorCodeMissingArgument);
    
    self = [super init];
    if (self)
    {
        _name = name;
        _bleIdentifier = bleIdentifier;
        _relayrModelID = relayrModelID;
        _mappings = mappings;
    }
    return self;
}

@end
