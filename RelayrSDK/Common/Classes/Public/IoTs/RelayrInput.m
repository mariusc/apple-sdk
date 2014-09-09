#import "RelayrInput.h"
#import "RelayrInput_Setup.h"

static NSString* const kCodingMeaning = @"men";
static NSString* const kCodingUnits = @"unis";
static NSString* const kCodingValues = @"val";
static NSString* const kCodingDates = @"dat";

@implementation RelayrInput

@synthesize values = _values;
@synthesize units = _units;
@synthesize dates = _dates;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithMeaning:(NSString*)meaning
{
    if (!meaning.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _meaning = meaning;
        _values = [[NSMutableArray alloc] init];
        _units = [[NSMutableArray alloc] init];
        _dates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)value
{
    return _values.firstObject;
}

- (NSString*)unit
{
    return _units.firstObject;
}

- (NSDate*)date
{
    return _dates.firstObject;
}

- (NSArray*)historicValues
{
    return [NSArray arrayWithArray:_values];
}

- (NSArray*)historicUnits
{
    return [NSArray arrayWithArray:_units];
}

- (NSArray*)historicDates
{
    return [NSArray arrayWithArray:_dates];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithMeaning:[decoder decodeObjectForKey:kCodingMeaning]];
    if (self)
    {
        NSMutableArray* tmpValues = [decoder decodeObjectForKey:kCodingValues];
        NSMutableArray* tmpUnits = [decoder decodeObjectForKey:kCodingUnits];
        NSMutableArray* tmpDates = [decoder decodeObjectForKey:kCodingDates];
        
        NSUInteger const numValues = tmpValues.count;
        if ( numValues > 0 && numValues == tmpUnits.count && numValues == tmpDates.count )
        {
            _values = tmpValues;
            _units = tmpUnits;
            _dates = tmpDates;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_meaning forKey:kCodingMeaning];
    
    NSUInteger const numValues = _values.count;
    if ( numValues && numValues == _units.count && numValues == _dates.count )
    {
        [coder encodeObject:_values forKey:kCodingValues];
        [coder encodeObject:_units forKey:kCodingUnits];
        [coder encodeObject:_dates forKey:kCodingDates];
    }
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrInput\n{\n\t Meaning: %@Value: %@\n\t Unit: %@\n\t \n\t Date: %@\n}\n", _meaning, (_values.firstObject) ? _values.firstObject : @"?", (_units.firstObject) ? _units.firstObject : @"?", (_dates.firstObject) ? _dates.firstObject : @"?"];
}

@end
