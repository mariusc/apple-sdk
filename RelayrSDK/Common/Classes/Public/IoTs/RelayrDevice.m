#import "RelayrDevice.h"        // Header
#import "RelayrUser.h"          // Relayr.framework (Public)
#import "RelayrDevice_Setup.h"  // Relayr.framework (Private)

static NSString* const kCodingID = @"uid";
static NSString* const kCodingSecret = @"sec";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingOwner = @"own";

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
        _secret = [decoder decodeObjectForKey:kCodingSecret];
        _name = [decoder decodeObjectForKey:kCodingName];
        _owner = [decoder decodeObjectForKey:kCodingOwner];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_secret forKey:kCodingSecret];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_owner forKey:kCodingOwner];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"Relayr Device\n{\n\t Relayr ID: %@\n\t Name: %@\n\t MQTT secret: %@\n\t Owner: %@\n}\n", _uid, _name, _secret, (_owner) ? _owner : @"?"];
}

@end
