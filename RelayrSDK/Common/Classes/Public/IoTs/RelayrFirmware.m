#import "RelayrFirmware.h"
#import "RelayrFirmware_Setup.h"

static NSString* const kCodingVersion = @"ver";
static NSString* const kCodingProperties = @"properties";

@implementation RelayrFirmware

@synthesize version=_version;
@synthesize properties=_properties;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithVersion:(NSString*)version
{
    if (!version.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _version = version;
        _properties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary*)configuration
{
    return [NSDictionary dictionaryWithDictionary:_properties];
}

- (void)queryCloudForProperties:(void (^)(NSError* error, BOOL isThereChanges))completion
{
    // TODO: Fill up
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithVersion:[decoder decodeObjectForKey:kCodingVersion]];
    if (self)
    {
        NSMutableDictionary* tmpProperties = [decoder decodeObjectForKey:kCodingProperties];
        if (tmpProperties.count) { _properties = tmpProperties; }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_version forKey:kCodingVersion];
    [coder encodeObject:_properties forKey:kCodingProperties];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrFirmware\n{\n\t Version: %@\n\t Number of configurations: %lu\n}\n", _version, (unsigned long)_properties.count];
}

@end
