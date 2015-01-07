#import "RelayrPublisher.h"         // Header
#import "RelayrPublisher_Setup.h"   // Relayr.framework (Private)

static NSString* const kCodingID = @"uid";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingOwner = @"own";
static NSString* const kCodingApps = @"apps";

@implementation RelayrPublisher

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Setup extension

- (instancetype)initWithPublisherID:(NSString*)uid
{
    if (uid.length==0) return nil;
    
    if (self)
    {
        _uid = uid;
    }
    return self;
}

- (void)setWith:(RelayrPublisher*)publisher
{
    if (![publisher.uid isEqualToString:_uid]) { return; }
    if (publisher.owner) { _owner = publisher.owner; }
    if (publisher.name) { _name = publisher.name; }
    if (publisher.apps) { _apps = publisher.apps; }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithPublisherID:[decoder decodeObjectForKey:kCodingID]];
    if (self)
    {
        _owner = [decoder decodeObjectForKey:kCodingOwner];
        _name = [decoder decodeObjectForKey:kCodingName];
        _apps = [decoder decodeObjectForKey:kCodingApps];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_owner forKey:kCodingOwner];
    [coder encodeObject:_apps forKey:kCodingApps];
}

#pragma mark NSCopying & NSMutableCopying

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
    return self;
}

#pragma mark Base class

- (NSString*)description
{
    return [NSString stringWithFormat:@"Relayr Publisher:\n{\n\t ID:\t%@\n\t Name:\t%@\n\t Owner ID:\t%@\n\t Num apps:\t%@\n}\n", _uid, (_name) ? _name : @"?", (_owner) ? _owner : @"?", (_apps) ? [NSNumber numberWithUnsignedInteger:_apps.count] : @"?"];
}

@end
