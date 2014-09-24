#import "RelayrPublisher.h"         // Header
#import "RelayrPublisher_Setup.h"   // Relayr.framework (Private)
#import "RelayrUser.h"              // Relayr.framework (Public)

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

- (instancetype)initWithPublisherID:(NSString*)uid owner:(NSString*)owner
{
    if (uid.length==0) return nil;
    
    if (self)
    {
        _uid = uid;
        _owner = owner;
    }
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithPublisherID:[decoder decodeObjectForKey:kCodingID] owner:[decoder decodeObjectForKey:kCodingOwner]];
    if (self)
    {
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

#pragma mark Base class

- (NSString*)description
{
    return [NSString stringWithFormat:@"Relayr Publisher:\n{\n\t ID:\t%@\n\t Name:\t%@\n\t User ID:\t%@\n}", _uid, (_name) ? _name : @"?", (_owner) ? _owner : @"?"];
}

@end
