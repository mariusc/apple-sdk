#import "RelayrInput.h"

static NSString* const kCodingMeaning = @"men";
static NSString* const kCodingUnit = @"uni";
static NSString* const kCodingValues = @"val";
static NSString* const kCodingDates = @"dat";

@implementation RelayrInput
{
    NSMutableArray* _values;
    NSMutableArray* _dates;
}

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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
    return [NSArray arrayWithArray:_values];
}

- (NSArray*)historicDates
{
    return [NSArray arrayWithArray:_dates];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (self)
    {
        _meaning = [decoder decodeObjectForKey:kCodingMeaning];
        _unit = [decoder decodeObjectForKey:kCodingUnit];
        
        _values = [decoder decodeObjectForKey:kCodingValues];
        _dates = [decoder decodeObjectForKey:kCodingDates];
        
        if ( _values.count==0 || _values.count!=_dates.count)
        {
            _values = [[NSMutableArray alloc] init];
            _dates = [[NSMutableArray array] init];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_meaning forKey:kCodingMeaning];
    [coder encodeObject:_unit forKey:kCodingUnit];
    if (_values.count) { [coder encodeObject:_values forKey:kCodingValues]; }
    if (_dates.count) { [coder encodeObject:_dates forKey:kCodingDates]; }
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrInput\n{\n\t Meaning: %@\n\t Unit: %@\n\t Value: %@\n\t Date: %@\n}\n", _meaning, _unit, (_values.firstObject) ? _values.firstObject : @"?", (_dates.firstObject) ? _dates.firstObject : @"?"];
}

@end
