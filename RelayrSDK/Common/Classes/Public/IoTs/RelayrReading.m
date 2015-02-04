#import "RelayrReading.h"           // Header
#import "RelayrApp.h"               // Relayr (Public)
#import "RelayrUser.h"              // Relayr (Public)
#import "RelayrDevice.h"            // Relayr (Public/IoTs)
#import "RelayrErrors.h"            // Relayr (Public/IoTs)
#import "RelayrUser_Setup.h"        // Relayr (Private)
#import "RelayrDevice_Setup.h"      // Relayr (Private/IoTs)
#import "RelayrReading_Setup.h"     // Relayr (Private)
#import "RLADispatcher.h"           // Relayr (Services)
#import "RLATargetAction.h"         // Relayr (Utilities)

#define dMaxValues   15

static NSString* const kCodingMeaning = @"men";
static NSString* const kCodingUnit = @"uni";
static NSString* const kCodingValues = @"val";
static NSString* const kCodingDates = @"dat";
static NSString* const kCodingDeviceModel = @"dmod";

@implementation RelayrReading

@synthesize values = _values;
@synthesize dates = _dates;
@synthesize subscribedBlocks = _subscribedBlocks;
@synthesize subscribedTargets = _subscribedTargets;

#pragma mark - Public API

- (id)value
{
    return _values.lastObject;
}

- (NSDate*)date
{
    return _dates.lastObject;
}

- (NSArray*)historicValues
{
    return (_values.count) ? [NSArray arrayWithArray:_values] : nil;
}

- (NSArray*)historicDates
{
    return (_dates.count) ? [NSArray arrayWithArray:_dates] : nil;
}

- (void)subscribeWithBlock:(RelayrReadingDataReceivedBlock)block error:(RelayrReadingErrorReceivedBlock)errorBlock
{
    if (![_deviceModel isKindOfClass:[RelayrDevice class]]) { if (errorBlock) { errorBlock(RelayrErrorTryingToUseRelayrModel); } return; }
    if (!block) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    RelayrDevice* device = (RelayrDevice*)_deviceModel;
    
    // Add the subscription block to the queues
    if (!_subscribedBlocks) { _subscribedBlocks = [[NSMutableDictionary alloc] init]; }
    _subscribedBlocks[[block copy]] = (errorBlock) ? [errorBlock copy] : [NSNull null];
    
    // Tell the service dispatcher to take over
    [device.user.dispatcher subscribeToDataFromReading:self];
}

- (void)subscribeWithTarget:(id)target action:(SEL)action error:(RelayrReadingErrorReceivedBlock)errorBlock
{
    if (![_deviceModel isKindOfClass:[RelayrDevice class]]) { if (errorBlock) { errorBlock(RelayrErrorTryingToUseRelayrModel); } return; }
    RLATargetAction* pair = [[RLATargetAction alloc] initWithTarget:target action:action];
    if (!pair) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    RelayrDevice* device = (RelayrDevice*)_deviceModel;
    
    if (!_subscribedTargets) { _subscribedTargets = [[NSMutableDictionary alloc] init]; }
    _subscribedTargets[pair] = (errorBlock) ? [errorBlock copy] : [NSNull null];
    
    [device.user.dispatcher subscribeToDataFromReading:self];
}

- (void)unsubscribeTarget:(id)target action:(SEL)action
{
    if (!target || _subscribedTargets.count) { return; }
    
    NSMutableArray* matchedPairs = [[NSMutableArray alloc] init];
    for (RLATargetAction* pair in _subscribedTargets)
    {
        if (pair.target==target && pair.action==action) { [matchedPairs addObject:pair]; }
    }
    [_subscribedTargets removeObjectsForKeys:matchedPairs];
    
    if (!_subscribedBlocks.count && !_subscribedTargets.count)
    {
        [_deviceModel.user.dispatcher unsubscribeToDataFromReading:self];
    }
}

- (void)unsubscribeToAll
{
    if (!_subscribedBlocks.count && !_subscribedTargets.count) { return; }

    _subscribedBlocks = nil;
    _subscribedTargets = nil;
    [_deviceModel.user.dispatcher unsubscribeToDataFromReading:self];
}

#pragma mark NSCopying & NSMutableCopying

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
    return self;
}

#pragma mark NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrReading\n{\n\
\t Meaning: %@\n\
\t Unit: %@\n\
\t Last value: %@\n\
\t Last date: %@\n\
}\n", _meaning, _unit, (_values.lastObject) ? _values.lastObject : @"?", (_dates.lastObject) ? _dates.lastObject : @"?"];
}

#pragma mark - Private functionality

/*******************************************************************************
 * It performs a selector on a given target.
 * This method doesn't check that the arguments aren't <code>nil</code>. Be careful.
 ******************************************************************************/
- (void)performSelector:(SEL)action onTarget:(id)target withDevice:(RelayrDevice*)device input:(RelayrReading*)input
{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    NSMethodSignature* msig = [target methodSignatureForSelector:action];
    if (msig != nil)
    {
        NSUInteger const numArguments = msig.numberOfArguments;
        if (numArguments == 2)
        {
            [target performSelector:action];
        }
        else if (numArguments == 3)
        {
            [target performSelector:action withObject:input];
        }
        else if (numArguments == 4)
        {
            [target performSelector:action withObject:device withObject:input];
        }
    }
    
    #pragma clang diagnostic pop
}

#pragma mark Setup extension

- (instancetype)initWithMeaning:(NSString*)meaning unit:(NSString*)unit
{
    if (!meaning.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _meaning = meaning;
        _unit = unit;
    }
    return self;
}

- (void)setWith:(RelayrReading*)input
{
    if (!input.meaning.length) { return; }
    // Do not pass the deviceModel (since the new deviceModel will be deleted after the settings are done).
    
    // If the input's meaning and units are the same, no further work is needed.
    if ([_meaning isEqualToString:input.meaning] && [_unit isEqualToString:input.unit]) { return; }
    
    // If the input's meaning or unit has changed, previous values will not be right. Thus, delete everything stored previously.
    [_values removeAllObjects];
    [_dates removeAllObjects];
}

- (void)errorReceived:(NSError*)error atDate:(NSDate*)date
{
    NSMutableDictionary* blocks  = _subscribedBlocks;   _subscribedBlocks = nil;
    NSMutableDictionary* targets = _subscribedTargets;  _subscribedTargets = nil;
    
    [blocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        if (obj != [NSNull null]) { ((RelayrReadingErrorReceivedBlock)obj)(error); }
    }];
    
    [targets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        if (obj != [NSNull null]) { ((RelayrReadingErrorReceivedBlock)obj)(error); }
    }];
}

- (void)valueReceived:(NSObject<NSCopying>*)value atDate:(NSDate*)date
{
    if (!value || !date) { return; }
    
    if (!_values) { _values = [[NSMutableArray alloc] init]; }
    else if (_values.count > dMaxValues) { [_values removeObjectAtIndex:0]; }
    [_values addObject:value];
    
    if (!_dates) { _dates = [[NSMutableArray alloc] init]; }
    else if (_dates.count > dMaxValues) { [_dates removeObjectAtIndex:0]; }
    [_dates addObject:date];
    
    __weak RelayrReading* weakInput = self;
    
    if (_subscribedBlocks.count)
    {
        NSMutableArray* toSubstract = [[NSMutableArray alloc] init];
        NSMutableDictionary* tmpBlocks = [NSMutableDictionary dictionaryWithDictionary:_subscribedBlocks];
        
        [tmpBlocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            BOOL unsubscribe = NO;
            ((RelayrReadingDataReceivedBlock)key)(((RelayrDevice*)weakInput.deviceModel), weakInput, &unsubscribe);
            if (unsubscribe) { [toSubstract addObject:key]; }
        }];
        
        [_subscribedBlocks removeObjectsForKeys:toSubstract];
    }
    
    if (_subscribedTargets.count)
    {
        NSMutableArray* toSubstract = [[NSMutableArray alloc] init];
        NSMutableDictionary* tmpTargets = [NSMutableDictionary dictionaryWithDictionary:_subscribedTargets];
        
        [tmpTargets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            RLATargetAction* pair = key;
            id target = pair.target;
            SEL action = pair.action;
            if (!target || ![target respondsToSelector:action]) { return [toSubstract addObject:key]; }
            [self performSelector:action onTarget:target withDevice:(RelayrDevice*)self.deviceModel input:self];
        }];
        
        [_subscribedTargets removeObjectsForKeys:toSubstract];
    }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithMeaning:[decoder decodeObjectForKey:kCodingMeaning] unit:[decoder decodeObjectForKey:kCodingUnit]];
    if (self)
    {
        _deviceModel = [decoder decodeObjectForKey:kCodingDeviceModel];
        
        NSArray* tmpValues = [decoder decodeObjectForKey:kCodingValues];
        NSArray* tmpDates = [decoder decodeObjectForKey:kCodingDates];
        
        NSUInteger const numValues = tmpValues.count;
        if (numValues && numValues==tmpDates.count)
        {
            _values = [[NSMutableArray alloc] initWithArray:tmpValues];
            _dates = [[NSMutableArray alloc] initWithArray:tmpDates];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_deviceModel forKey:kCodingDeviceModel];
    [coder encodeObject:_meaning forKey:kCodingMeaning];
    [coder encodeObject:_unit forKey:kCodingUnit];
    
    NSUInteger const numValues = _values.count;
    if (numValues && numValues==_dates.count)
    {
        [coder encodeObject:[NSArray arrayWithArray:_values] forKey:kCodingValues];
        [coder encodeObject:[NSArray arrayWithArray:_dates] forKey:kCodingDates];
    }
}

@end
