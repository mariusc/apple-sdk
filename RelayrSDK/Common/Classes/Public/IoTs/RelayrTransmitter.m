#import "RelayrTransmitter.h"       // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrTransmitter_Setup.h" // Relayr.framework (Private)

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

- (instancetype)initWithID:(NSString*)uid secret:(NSString*)secret
{
    if (uid.length==0 || secret.length==0) { return nil; }
    
    self = [super init];
    if (self)
    {
        _uid = uid;
        _secret = secret;
    }
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithID:[decoder decodeObjectForKey:kCodingID] secret:[decoder decodeObjectForKey:kCodingSecret]];
    if (self)
    {
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

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"Relayr Transmitter\n{\n\t Relayr ID: %@\n\t Name: %@\n\t MQTT Secret: %@\n\t Owner: %@\n\t Number of devices: %lu\n}\n", _uid, _name, _secret, (_owner) ? _owner : @"?", (unsigned long)_devices.count];
}

@end
