#import "RelayrTransmitter.h"           // Header

#import "RelayrUser.h"                  // Relayr.framework (Public)
#import "RelayrDevice.h"                // Relayr.framework (Public)
#import "RelayrOnboarding.h"            // Relayr.framework (Public)
#import "RelayrFirmwareUpdate.h"        // Relayr.framework (Public)
#import "RelayrTransmitter_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"            // Relayr.framework (Private)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)

#import "RLAAPIService+Transmitter.h"   // Relayr.framework (Service/API)

static NSString* const kCodingID = @"uid";
static NSString* const kCodingSecret = @"sec";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingOwner = @"own";
static NSString* const kCodingUser = @"usr";
static NSString* const kCodingDevices = @"dev";

@implementation RelayrTransmitter

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setNameWith:(NSString*)name completion:(void (^)(NSError*, NSString*))completion
{
    if (!name.length) { if (completion) { completion(RelayrErrorMissingArgument, _name); } return; }
    
    __weak RelayrTransmitter* weakSelf = self;
    [_user.apiService setTransmitter:self.uid withName:name completion:(!completion) ? nil : ^(NSError* error) {
        if (error) { return completion(error, weakSelf.name); }
        
        NSString* previousName = weakSelf.name;
        weakSelf.name = name;
        completion(nil, previousName);
    }];
}

#pragma mark Setup extension

- (instancetype)initWithID:(NSString*)uid
{
    if (uid.length==0) { return nil; }
    
    self = [super init];
    if (self) { _uid = uid; }
    return self;
}

- (void)setWith:(RelayrTransmitter*)transmitter
{
    if (self==transmitter || ![_uid isEqualToString:transmitter.uid]) { return; }
    
    if (transmitter.name) { _name = transmitter.name; }
    if (transmitter.owner) { _owner = transmitter.owner; }
    if (transmitter.secret) { _secret = transmitter.secret; }
    if (transmitter.devices) { _devices = transmitter.devices; }
}

#pragma mark Processes

- (void)onboardWithClass:(Class<RelayrOnboarding>)onboardingClass timeout:(NSNumber *)timeout options:(NSDictionary*)options completion:(void (^)(NSError*))completion
{
    if (!onboardingClass) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    [onboardingClass launchOnboardingProcessForTransmitter:self timeout:timeout options:options completion:completion];
}

- (void)updateFirmwareWithClass:(Class<RelayrFirmwareUpdate>)updateClass timeout:(NSNumber*)timeout options:(NSDictionary*)options completion:(void (^)(NSError *))completion
{
    if (!updateClass) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    [updateClass launchFirmwareUpdateProcessForTransmitter:self timeout:timeout options:options completion:completion];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithID:[decoder decodeObjectForKey:kCodingID]];
    if (self)
    {
        _name = [decoder decodeObjectForKey:kCodingName];
        _owner = [decoder decodeObjectForKey:kCodingOwner];
        _user = [decoder decodeObjectForKey:kCodingUser];
        _secret = [decoder decodeObjectForKey:kCodingSecret];
        _devices = [decoder decodeObjectForKey:kCodingDevices];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_owner forKey:kCodingOwner];
    [coder encodeObject:_user forKey:kCodingUser];
    [coder encodeObject:_secret forKey:kCodingSecret];
    [coder encodeObject:_devices forKey:kCodingDevices];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"Relayr Transmitter\n{\n\t Relayr ID: %@\n\t Name: %@\n\t Owner: %@\n\t MQTT Secret: %@\n\t Number of devices: %lu\n}\n", _uid, _name, (_owner) ? _owner : @"?", _secret, (unsigned long)_devices.count];
}

@end
