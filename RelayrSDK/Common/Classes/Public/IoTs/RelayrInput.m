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
#import "RLAAPIService+Device.h"    // Relyar.framework (Service/API)
#import "RLATargetAction.h"         // Relayr.framework (Utilities)

#define dMaxValues   15

static NSString* const kCodingMeaning = @"men";
static NSString* const kCodingUnit = @"uni";
static NSString* const kCodingValues = @"val";
static NSString* const kCodingDates = @"dat";

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
    
    RelayrDevice* device = ([self.device isKindOfClass:[RelayrDevice class]]) ? (RelayrDevice*)self.device : nil;
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
            if (!strongDevice) { if (errorBlock) { errorBlock(RelayrErrorMissingObjectPointer); } return; }
            
            RelayrInput* strongInput = weakInput;
            if (!strongInput) { if (errorBlock) { errorBlock(RelayrErrorMissingObjectPointer); } return; }
            
            if (!strongInput.subscribedBlocks) { strongInput.subscribedBlocks = [[NSMutableDictionary alloc] init]; }
            strongInput.subscribedBlocks[[block copy]] = (errorBlock) ? [errorBlock copy] : [NSNull null];
        }];
    }];
}

- (void)subscribeWithTarget:(id)target action:(SEL)action error:(RelayrInputErrorReceivedBlock)errorBlock
{
    RLATargetAction* pair = [[RLATargetAction alloc] initWithTarget:target action:action];
    if (!pair) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    
    RelayrDevice* device = ([self.device isKindOfClass:[RelayrDevice class]]) ? (RelayrDevice*)self.device : nil;
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
    
    if ([self.device isKindOfClass:[RelayrDevice class]] && !_subscribedBlocks.count && !_subscribedTargets.count)
    {
        [((RelayrDevice*)self) unsubscribeToCurrentServiceIfNecessary];
    }
}

- (void)removeAllSubscriptions
{
    if (!_subscribedBlocks.count && !_subscribedTargets.count) { return; }

    _subscribedBlocks = nil;
    _subscribedTargets = nil;
    
    if ([self.device isKindOfClass:[RelayrDevice class]])
    {
        [((RelayrDevice*)self) unsubscribeToCurrentServiceIfNecessary];
    }
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
    // If the input's meaning and units are the same, no further work is needed.
    if ([_meaning isEqualToString:input.meaning] && [_unit isEqualToString:input.unit]) { return; }
    
    // If the input's meaning or unit has changed, previous values will not be right. Thus, delete everything stored previously.
    [_values removeAllObjects];
    [_dates removeAllObjects];
}

- (void)valueReceived:(NSObject <NSCopying> *)valueOrError at:(NSDate*)date
{
    if (!valueOrError) { return; }
    
    // If an error was received, communicate all subscribers, and remove them from the subscribers dictionary.
    if ([valueOrError isKindOfClass:[NSError class]])
    {
        NSError* error = (NSError*)valueOrError;
        
        NSMutableDictionary* blocks = _subscribedBlocks;
        NSMutableDictionary* targets = _subscribedTargets;
        _subscribedBlocks = nil;
        _subscribedTargets = nil;
        
        NSNull* null = [NSNull null];
        
        [blocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            if (obj != null) { ((RelayrInputErrorReceivedBlock)obj)(error); }
        }]; blocks = nil;
        
        [targets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            if (obj != null) { ((RelayrInputErrorReceivedBlock)obj)(error); }
        }]; targets = nil;
        return;
    }
    
    // If there is no date, do not allow the value to be stored.
    if (!date) { return; }
    
    if (!_values) { _values = [[NSMutableArray alloc] init]; }
    else if (_values.count > dMaxValues) { [_values removeObjectAtIndex:0]; }
    [_values addObject:valueOrError];
    
    if (!_dates) { _dates = [[NSMutableArray alloc] init]; }
    else if (_dates.count > dMaxValues) { [_dates removeObjectAtIndex:0]; }
    [_dates addObject:date];
    
    __weak RelayrInput* weakInput = self;
    NSMutableDictionary* tmpBlocks = [NSMutableDictionary dictionaryWithDictionary:_subscribedBlocks];
    NSMutableDictionary* tmpTargets = [NSMutableDictionary dictionaryWithDictionary:_subscribedTargets];
    NSMutableArray* toSubstract = [[NSMutableArray alloc] init];
    
    [tmpBlocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        BOOL unsubscribe = NO;
        ((RelayrInputDataReceivedBlock)key)(((RelayrDevice*)weakInput.device), weakInput, &unsubscribe);
        if (unsubscribe) { [toSubstract addObject:key]; }
    }]; tmpBlocks = nil;
    
    [_subscribedBlocks removeObjectsForKeys:toSubstract];
    [toSubstract removeAllObjects];
    
    [tmpTargets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        RLATargetAction* pair = key;
        id target = pair.target;
        SEL action = pair.action;
        if (!target || ![key respondsToSelector:action]) { return [toSubstract addObject:key]; }
        [self performSelector:action onTarget:target withDevice:(RelayrDevice*)self.device input:self];
    }]; tmpTargets = nil;
    
    [_subscribedTargets removeObjectsForKeys:toSubstract];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithMeaning:[decoder decodeObjectForKey:kCodingMeaning] unit:[decoder decodeObjectForKey:kCodingUnit]];
    if (self)
    {
        NSMutableArray* tmpValues = [decoder decodeObjectForKey:kCodingValues];
        NSMutableArray* tmpDates = [decoder decodeObjectForKey:kCodingDates];
        
        NSUInteger const numValues = tmpValues.count;
        if (numValues && numValues==tmpDates.count)
        {
            _values = tmpValues;
            _dates = tmpDates;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_meaning forKey:kCodingMeaning];
    [coder encodeObject:_unit forKey:kCodingUnit];
    
    NSUInteger const numValues = _values.count;
    if (numValues && numValues==_dates.count)
    {
        [coder encodeObject:_values forKey:kCodingValues];
        [coder encodeObject:_dates forKey:kCodingDates];
    }
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrInput\n{\n\t Meaning: %@\n\t Unit: %@Num values: %@\n\t \n\t Date: %@\n}\n", _meaning, _unit, (_values.lastObject) ? _values.lastObject : @"?", (_dates.lastObject) ? _dates.lastObject : @"?"];
}

#pragma mark - Private

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

@end
