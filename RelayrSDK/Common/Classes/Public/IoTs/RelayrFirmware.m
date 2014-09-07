#import "RelayrFirmware.h"

static NSString* const kCodingVersion = @"ver";
static NSString* const kCodingConfiguration = @"con";

@implementation RelayrFirmware

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (self)
    {
        _version = [decoder decodeObjectForKey:kCodingVersion];
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
    return [NSString stringWithFormat:@"RelayrFirmware\n{\n\t Version: %@\n}\n", _version];
}

@end
