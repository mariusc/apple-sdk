#import "RelayrUser.h"      // Header

static NSString* const kCodingToken = @"tok";
static NSString* const kCodingID = @"uid";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingEmail = @"ema";
static NSString* const kCodingApps = @"app";
static NSString* const kCodingTransmitters = @"tra";
static NSString* const kCodingDevices = @"dev";
static NSString* const kCodingBookmarks = @"bok";
static NSString* const kCodingPublishers = @"pub";

@implementation RelayrUser

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithToken:(NSString*)token
{
    if (!token.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _token = token;
    }
    return self;
}

- (void)queryCloudForUserInfo:(void (^)(NSError* error, NSString* previousName, NSString* previousEmail))completion
{
    
}

- (void)queryCloudForIoTs:(void (^)(NSError* error, BOOL isThereChanges))completion
{
    
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithToken:[decoder decodeObjectForKey:kCodingToken]];
    if (self)
    {
        _uid = [decoder decodeObjectForKey:kCodingID];
        _name = [decoder decodeObjectForKey:kCodingName];
        _email = [decoder decodeObjectForKey:kCodingEmail];
        _apps = [decoder decodeObjectForKey:kCodingApps];
        _transmitter = [decoder decodeObjectForKey:kCodingTransmitters];
        _devices = [decoder decodeObjectForKey:kCodingDevices];
        _devicesBookmarked = [decoder decodeObjectForKey:kCodingDevices];
        _publishers = [decoder decodeObjectForKey:kCodingPublishers];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_token forKey:kCodingToken];
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_email forKey:kCodingEmail];
    [coder encodeObject:_apps forKey:kCodingApps];
    [coder encodeObject:_transmitter forKey:kCodingTransmitters];
    [coder encodeObject:_devices forKey:kCodingDevices];
    [coder encodeObject:_devicesBookmarked forKey:kCodingBookmarks];
    [coder encodeObject:_publishers forKey:kCodingPublishers];
}

@end
