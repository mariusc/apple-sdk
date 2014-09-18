#import "RelayrDevice.h"            // Header
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrFirmware.h"          // Relayr.framework (Public)
#import "RelayrInput.h"             // Relayr.framework (Public)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)
#import "RLAWebService.h"           // Relayr.framework (Web)
#import "RLAWebService+Device.h"    // Relayr.framework (Web)
#import "RLAError.h"                // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)


static NSString* const kCodingID = @"uid";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingOwner = @"own";
static NSString* const kCodingPublic = @"isP";
static NSString* const kCodingFirmware = @"fir";
static NSString* const kCodingSecret = @"sec";

@implementation RelayrDevice

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithID:(NSString*)uid modelID:(NSString*)modelID
{
    if ( uid.length==0 || modelID.length==0 ) { return nil; }
    
    self = [super initWithModelID:modelID];
    if (self)
    {
        _uid = uid;
    }
    return self;
}

#pragma mark Subscription

- (void)subscribeToAllInputsWithTarget:(id)target action:(SEL)action error:(BOOL (^)(NSError* error))subscriptionError
{
    // TODO: Fill up
}

- (void)subscribeToAllInputsWithBlock:(void (^)(RelayrDevice* device, RelayrInput* input, BOOL* unsubscribe))block error:(BOOL (^)(NSError* error))subscriptionError
{
    // TODO: Fill up
}

- (void)unsubscribeTarget:(id)target action:(SEL)action
{
    // TODO: Fill up
}

- (void)removeAllSubscriptions
{
    // TODO: Fill up
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        _uid = [decoder decodeObjectForKey:kCodingID];
        _name = [decoder decodeObjectForKey:kCodingName];
        _owner = [decoder decodeObjectForKey:kCodingOwner];
        _isPublic = [decoder decodeObjectForKey:kCodingPublic];
        _firmware = [decoder decodeObjectForKey:kCodingFirmware];
        _secret = [decoder decodeObjectForKey:kCodingSecret];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_owner forKey:kCodingOwner];
    [coder encodeObject:_isPublic forKey:kCodingPublic];
    [coder encodeObject:_firmware forKey:kCodingFirmware];
    [coder encodeObject:_secret forKey:kCodingSecret];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrDevice\n{\n\t Relayr ID: %@\n\t Name: %@\n\t Owner: %@\n\t Firmware version: %@\n\t MQTT secret: %@\n}\n", _uid, _name, (_owner) ? _owner : @"?", (_firmware.version) ? _firmware.version : @"?", _secret];
}

@end
