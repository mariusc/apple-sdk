#import "RelayrInput.h"
#import "RelayrInput_Setup.h"

static NSString* const kCodingMeaning = @"men";
static NSString* const kCodingUnit = @"uni";
static NSString* const kCodingValues = @"val";
static NSString* const kCodingDates = @"dat";

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
    return _values.firstObject;
}

- (NSDate*)date
{
    return _dates.firstObject;
}

- (NSArray*)historicValues
{
    return (_values.count) ? [NSArray arrayWithArray:_values] : nil;
}

- (NSArray*)historicDates
{
    return (_dates.count) ? [NSArray arrayWithArray:_dates] : nil;
}

- (void)subscribeWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))subscriptionError
{
    // TODO: Fill up
}

- (void)subscribeWithBlock:(void (^)(RelayrDevice* device, RelayrInput* input, BOOL* unsubscribe))block error:(BOOL (^)(NSError* error))subscriptionError
{
    // TODO: Fill up
}

- (void)unsubscribeTarget:(id)target action:(SEL)action
{
    // TODO: Fill up
}

- (void)removeAllSubscriptions
{
    // TODO: Fill up
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
    return [NSString stringWithFormat:@"RelayrInput\n{\n\t Meaning: %@\n\t Unit: %@Num values: %@\n\t \n\t Date: %@\n}\n", _meaning, _unit, (_values.firstObject) ? _values.firstObject : @"?", (_dates.firstObject) ? _dates.firstObject : @"?"];
}

@end
