#import "RelayrInput.h"             // Header
#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrErrors.h"            // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)
#import "RLAService.h"              // Relayr.framework (Service)
#import "RLAServiceSelector.h"      // Relayr.framework (Service)
#import "RLATargetAction.h"         // Relayr.framework (Utilities)

#define dMaxValues   15

static NSString* const kCodingMeaning = @"men";
static NSString* const kCodingUnit = @"uni";
static NSString* const kCodingValues = @"val";
static NSString* const kCodingDates = @"dat";
static NSString* const kCodingDeviceModel = @"dmod";

@implementation RelayrInput

@synthesize values = _values;
@synthesize dates = _dates;
@synthesize subscribedBlocks = _subscribedBlocks;
@synthesize subscribedTargets = _subscribedTargets;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

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

- (void)subscribeWithBlock:(RelayrInputDataReceivedBlock)block error:(RelayrInputErrorReceivedBlock)errorBlock
{
    if (!block) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    
    RelayrDevice* device = ([_deviceModel isKindOfClass:[RelayrDevice class]]) ? (RelayrDevice*)_deviceModel : nil;
    if (!device) { if (errorBlock) { errorBlock(RelayrErrorTryingToUseRelayrModel); } return; }
    
    // Check if there was a previous subscription...
    if (device.hasOngoingInputSubscriptions)
    {   // If there were, you just need to add the block to the dictionary
        if (!_subscribedBlocks) { _subscribedBlocks = [[NSMutableDictionary alloc] init]; }
        _subscribedBlocks[[block copy]] = (errorBlock) ? [errorBlock copy] : [NSNull null];
        return;
    }
    
    // If this line is reached, there were no previous subscription...
    __weak RelayrDevice* weakDevice = device;
    __weak RelayrInput* weakInput = self;
    [RLAServiceSelector selectServiceForDevice:device completion:^(NSError* error, id<RLAService> service) {
        if (error) { if (errorBlock) { errorBlock(error); } return; }
        if (!service) { if (errorBlock) { errorBlock(RelayrErrorNoServiceAvailable); } return; }
        
        [service subscribeToDataFromDevice:weakDevice completion:^(NSError* error) {
            if (error) { if (errorBlock) { errorBlock(error); } return; }
            
            RelayrDevice* strongDevice = weakDevice;
            RelayrInput* strongInput = weakInput;
            if (!strongDevice || !strongInput) { if (errorBlock) { errorBlock(RelayrErrorMissingObjectPointer); } return; }
            
            if (!strongInput.subscribedBlocks) { strongInput.subscribedBlocks = [[NSMutableDictionary alloc] init]; }
            strongInput.subscribedBlocks[[block copy]] = (errorBlock) ? [errorBlock copy] : [NSNull null];
        }];
    }];
}

- (void)subscribeWithTarget:(id)target action:(SEL)action error:(RelayrInputErrorReceivedBlock)errorBlock
{
    RLATargetAction* pair = [[RLATargetAction alloc] initWithTarget:target action:action];
    if (!pair) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    
    RelayrDevice* device = ([_deviceModel isKindOfClass:[RelayrDevice class]]) ? (RelayrDevice*)_deviceModel : nil;
    if (!device) { if (errorBlock) { errorBlock(RelayrErrorTryingToUseRelayrModel); } return; }
    
    // Check if there was a previous subscription...
    if (device.hasOngoingInputSubscriptions)
    {   // If there were, you just need to add the target-action to the dictionary
        if (!_subscribedTargets) { _subscribedTargets = [[NSMutableDictionary alloc] init]; }
        _subscribedTargets[pair] = (errorBlock) ? [errorBlock copy] : [NSNull null];
        return;
    }
    
    // If this line is reached, there was no previous subscription...
    __weak RelayrDevice* weakDevice = device;
    __weak RelayrInput* weakInput = self;
    [RLAServiceSelector selectServiceForDevice:device completion:^(NSError* error, id<RLAService> service) {
        if (error) { if (errorBlock) { errorBlock(error); } return; }
        if (!service) { if (errorBlock) { errorBlock(RelayrErrorNoServiceAvailable); } return; }
        
        [service subscribeToDataFromDevice:weakDevice completion:^(NSError* error) {
            if (error) { if (errorBlock) { errorBlock(error); } return; }
            
            RelayrDevice* strongDevice = weakDevice;
            if (!strongDevice) { if (errorBlock) { errorBlock(RelayrErrorMissingObjectPointer); } return; }
            
            RelayrInput* strongInput = weakInput;
            if (!strongInput) { if (errorBlock) { errorBlock(RelayrErrorMissingObjectPointer); } return; }
            
            if (!strongInput.subscribedTargets) { strongInput.subscribedTargets = [[NSMutableDictionary alloc] init]; }
            strongInput.subscribedTargets[pair] = (errorBlock) ? [errorBlock copy] : [NSNull null];
        }];
    }];
}

- (void)unsubscribeTarget:(id)target action:(SEL)action
{
    if (!target || _subscribedTargets.count) { return; }
    
    RLATargetAction* matchedPair;
    for (RLATargetAction* pair in _subscribedTargets)
    {
        if (pair.target==target && pair.action==action) { matchedPair = pair; break; }
    }
    if (matchedPair) { [_subscribedTargets removeObjectForKey:matchedPair]; }
    
    if ([_deviceModel isKindOfClass:[RelayrDevice class]] && !_subscribedBlocks.count && !_subscribedTargets.count)
    {
        [((RelayrDevice*)_deviceModel) unsubscribeToCurrentServiceIfNecessary];
    }
}

- (void)removeAllSubscriptions
{
    if (!_subscribedBlocks.count && !_subscribedTargets.count) { return; }

    _subscribedBlocks = nil;
    _subscribedTargets = nil;
    
    if ([_deviceModel isKindOfClass:[RelayrDevice class]])
    {
        [((RelayrDevice*)_deviceModel) unsubscribeToCurrentServiceIfNecessary];
    }
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

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrInput\n{\n\
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
- (void)performSelector:(SEL)action onTarget:(id)target withDevice:(RelayrDevice*)device input:(RelayrInput*)input
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

- (void)setWith:(RelayrInput*)input
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
        if (obj != [NSNull null]) { ((RelayrInputErrorReceivedBlock)obj)(error); }
    }];
    
    [targets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        if (obj != [NSNull null]) { ((RelayrInputErrorReceivedBlock)obj)(error); }
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
    
    __weak RelayrInput* weakInput = self;
    
    if (_subscribedBlocks.count)
    {
        NSMutableArray* toSubstract = [[NSMutableArray alloc] init];
        NSMutableDictionary* tmpBlocks = [NSMutableDictionary dictionaryWithDictionary:_subscribedBlocks];
        
        [tmpBlocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            BOOL unsubscribe = NO;
            ((RelayrInputDataReceivedBlock)key)(((RelayrDevice*)weakInput.deviceModel), weakInput, &unsubscribe);
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
            if (!target || ![key respondsToSelector:action]) { return [toSubstract addObject:key]; }
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
