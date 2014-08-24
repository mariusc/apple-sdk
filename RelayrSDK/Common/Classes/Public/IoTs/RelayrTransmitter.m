#import "RelayrTransmitter.h"       // Header

static NSString* const kCodingID = @"uid";
static NSString* const kCodingSecret = @"sec";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingOwner = @"own";
static NSString* const kCodingDevices = @"dev";

@implementation RelayrTransmitter

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
        _uid = [decoder decodeObjectForKey:kCodingID];
        _secret = [decoder decodeObjectForKey:kCodingSecret];
        _name = [decoder decodeObjectForKey:kCodingName];
        _owner = [decoder decodeObjectForKey:kCodingOwner];
        _devices = [decoder decodeObjectForKey:kCodingDevices];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_secret forKey:kCodingSecret];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_owner forKey:kCodingOwner];
    [coder encodeObject:_devices forKey:kCodingDevices];
}

@end
