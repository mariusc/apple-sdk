#import "RelayrFirmwareModel.h"         // Header
#import "RelayrFirmwareModel_Setup.h"   // Relayr.firmware (Private)

static NSString* const kCodingVersion = @"ver";
static NSString* const kCodingConfiguration = @"con";

@implementation RelayrFirmwareModel
{
    NSMutableDictionary* _configuration;
}

@synthesize configuration = _configuration;

#pragma mark - Public API

- (instancetype)initWithVersion:(NSString*)version
{
    if (!version.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _version = nil;
    }
    return nil;
}

- (void)setWith:(RelayrFirmwareModel*)firmwareModel
{
    if (firmwareModel.version) { _version = firmwareModel.version; }
    if (firmwareModel.configuration) { _configuration = (NSMutableDictionary*)firmwareModel.configuration; }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithVersion:[decoder decodeObjectForKey:kCodingVersion]];
    if (self)
    {
        _configuration = [decoder decodeObjectForKey:kCodingConfiguration];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_version forKey:kCodingVersion];
    [coder encodeObject:_configuration forKey:kCodingConfiguration];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrFirmware\n{\n\t Version: %@\n\t Number of configurations: %lu\n}\n", _version, (unsigned long)_configuration.count];
}

@end
