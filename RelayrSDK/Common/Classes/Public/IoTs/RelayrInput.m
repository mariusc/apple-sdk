#import "RelayrInput.h"             // Header
#import "RelayrApp.h"               // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)
#import "RLAService.h"              // Relayr.framework (Protocols)
#import "RLAWebService+Device.h"    // Relyar.framework (Protocols/Web)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)
#import "RLATargetAction.h"         // Relayr.framework (Utilities)

#define dMaxValues   15

static NSString* const kCodingMeaning = @"men";
static NSString* const kCodingUnit = @"uni";
static NSString* const kCodingValues = @"val";
static NSString* const kCodingDates = @"dat";

@interface RelayrInput ()
@property (readwrite,nonatomic) NSMutableDictionary* subscribedBlocks;
@property (readwrite,nonatomic) NSMutableDictionary* subscribedTargets;
@end

@implementation RelayrInput

@synthesize values = _values;
@synthesize dates = _dates;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithMeaning:(NSString*)meaning unit:(NSString*)unit
{
    if (!meaning.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _meaning = meaning;
        _unit = unit;
        _values = [[NSMutableArray alloc] init];
        _dates = [[NSMutableArray alloc] init];
    }
    return self;
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

- (void)subscribeWithBlock:(RelayrInputDataReceivedBlock)block error:(BOOL (^)(NSError* error))errorBlock
{
    // A retry option is not given since not all arguments are there.
    if (!block) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    
    RelayrDevice* device = ([self.device isKindOfClass:[RelayrDevice class]]) ? (RelayrDevice*)self.device : nil;
    if (!device) { if (errorBlock) { errorBlock(RelayrErrorTryingToUseRelayrModel); } return; }
    
    if (!self.subscribedBlocks) { _subscribedBlocks = [[NSMutableDictionary alloc] init]; }
    
    id <RLAService> service = [self selectServiceForCurrentConnection];
    if (!service)
    {
        // ???: Do we give possibility of retry?
        if (errorBlock) { errorBlock(RelayrErrorNoConnectionPossible); }
        return;
    }
    
    __weak RelayrInput* weakSelf = self;
    [service subscribeToDataFromDevice:device completion:^(NSError *error) {
        if (error)
        {
            if (!errorBlock) { return; }
            BOOL const repeat = errorBlock(error);
            if (repeat) { [weakSelf subscribeWithBlock:block error:errorBlock]; }
            return;
        }
        else
        {
            RelayrInput* strongSelf = weakSelf;
            strongSelf.subscribedBlocks[[block copy]] = (errorBlock) ? [errorBlock copy] : [NSNull null];
        }
    }];
}

- (void)subscribeWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))errorBlock
{
    RLATargetAction* pair = [[RLATargetAction alloc] initWithTarget:target action:action];
    
    // A retry option is not given since not all arguments are there.
    if (!pair) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    if (![target respondsToSelector:action]) { if (errorBlock) { errorBlock(RelayrErrorUnknwon); } return; }
    
    RelayrDevice* device = ([self.device isKindOfClass:[RelayrDevice class]]) ? (RelayrDevice*)self.device : nil;
    if (!device) { if (errorBlock) { errorBlock(RelayrErrorTryingToUseRelayrModel); } return; }
    
    if (!_subscribedTargets) { _subscribedTargets = [[NSMutableDictionary alloc] init]; }
    
    // TODO: Implement!!!!
//    __weak RelayrInput* weakSelf = self;
//    [device.user.webService setConnectionBetweenDevice:device.uid andApp:device.user.app.uid completion:^(NSError *error, id credentials) {
//        if (error)
//        {
//            if (!errorBlock) { return; }
//            BOOL const repeat = errorBlock(error);
//            if (repeat) { [weakSelf subscribeWithTarget:target action:action error:errorBlock]; }
//            return;
//        }
//        
//        __strong RelayrInput* strongSelf = weakSelf;
////        if (![RLAPubNub arePubNubCredentials:credentials] || !strongSelf)
////        {
////            if (errorBlock) { errorBlock(RelayrErrorPubNubWrongCredentials); }
////            return [device.user.webService deleteConnectionBetweenDevice:device.uid andApp:device.user.app.uid completion:nil];
////        }
//        
//        strongSelf.subscribedTargets[pair] = (errorBlock) ? [errorBlock copy] : [NSNull null];
////        [RLAPubNub subscribeToChannel:credentials[kRLAPubNubOptionsChannel] withOptions:credentials input:strongSelf callback:@selector(dataReceived:at:)];
//    }];
}

- (void)unsubscribeTarget:(id)target action:(SEL)action
{
    if (!target) { return; }
    
    RLATargetAction* matchedPair;
    for (RLATargetAction* pair in _subscribedTargets)
    {
        if (pair.target==target && pair.action==action)
        {
            matchedPair = pair;
            break;
        }
    }
    
    if (matchedPair) { [_subscribedTargets removeObjectForKey:matchedPair]; }
    if (!_subscribedBlocks.count && !_subscribedTargets.count) { return [self removeAllSubscriptions]; }
}

- (void)removeAllSubscriptions
{
    if (_subscribedBlocks) { _subscribedBlocks = nil; }
    if (_subscribedTargets) { _subscribedTargets = nil; }
    
    if (![self.device isKindOfClass:[RelayrDevice class]]) { return; }
    RelayrDevice* device = (RelayrDevice*)self.device;
    [device.user.webService deleteConnectionBetweenDevice:device.uid andApp:device.user.app.uid completion:nil];
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
        if ( numValues > 0 && numValues == tmpDates.count )
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
    if ( numValues && numValues == _dates.count )
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
 * Callback method when some data has arrived.
 ******************************************************************************/
- (void)dataReceived:(NSObject <NSCopying> *)valueOrError at:(NSDate*)date
{
    if (!valueOrError) { return; }
    
    if ([valueOrError isKindOfClass:[NSError class]])
    {
        NSError* error = (NSError*)valueOrError;
        NSMutableDictionary* blocks = _subscribedBlocks;
        NSMutableDictionary* targets = _subscribedTargets;
        _subscribedBlocks = [[NSMutableDictionary alloc] init];
        _subscribedTargets = [[NSMutableDictionary alloc] init];
        
        NSNull* null = [NSNull null];
        __weak RelayrInput* weakInput = self;
        
        [blocks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            if (obj == null) { return; }
            BOOL const repeat = ((BOOL (^)(NSError*))obj)(error);
            if (repeat) { [weakInput subscribeWithBlock:key error:obj]; }
        }]; blocks = nil;
        
        [targets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            if (obj == null) { return; }
            BOOL const repeat = ((BOOL (^)(NSError*))obj)(error);
            if (repeat)
            {
                RLATargetAction* pair = (RLATargetAction*)key;
                [weakInput subscribeWithTarget:pair.target action:pair.action error:obj];
            }
        }]; targets = nil;
        return;
    }
    
    [_values addObject:valueOrError];
    if (_values.count > dMaxValues) { [_values removeObjectAtIndex:0]; }
    [_dates addObject:(date) ? date : [NSNull null]];
    if (_dates.count > dMaxValues) { [_dates removeObjectAtIndex:0]; }
    
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

/*******************************************************************************
 * <#abstract#>
 * <#discussion#>
 ******************************************************************************/
- (id <RLAService>)selectServiceForCurrentConnection
{
    // TODO: Implement!!!
    return nil;
}

@end
