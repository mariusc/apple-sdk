#import "RelayrDevice.h"        // Header
#import "RelayrUser.h"          // Relayr.framework (Public)
#import "RelayrDevice_Setup.h"  // Relayr.framework (Private)

static NSString* const kCodingID = @"uid";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingOwner = @"own";
static NSString* const kCodingPublic = @"isP";
static NSString* const kCodingFirmVersion = @"fir";
static NSString* const kCodingModel = @"mod";
static NSString* const kCodingSecret = @"sec";

@implementation RelayrDevice

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
    self = [super init];
    if (self)
    {
        _uid = [decoder decodeObjectForKey:kCodingID];
        _name = [decoder decodeObjectForKey:kCodingName];
        _owner = [decoder decodeObjectForKey:kCodingOwner];
        _isPublic = [decoder decodeObjectForKey:kCodingPublic];
        _firmwareVersion = [decoder decodeObjectForKey:kCodingFirmVersion];
        _model = [decoder decodeObjectForKey:kCodingModel];
        _secret = [decoder decodeObjectForKey:kCodingSecret];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_owner forKey:kCodingOwner];
    [coder encodeObject:_isPublic forKey:kCodingPublic];
    [coder encodeObject:_firmwareVersion forKey:kCodingFirmVersion];
    [coder encodeObject:_model forKey:kCodingModel];
    [coder encodeObject:_secret forKey:kCodingSecret];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"Relayr Device\n{\n\t Relayr ID: %@\n\t Name: %@\n\t Owner: %@\n\t MQTT secret: %@\n}\n", _uid, _name, (_owner) ? _owner : @"?", _secret];
}

@end
