#import "RelayrTransmitter.h"       // Header
#import "RelayrTransmitter_Setup.h" // Relayr.framework (Private)

#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrOnboarding.h"        // Relayr.framework (Public)
#import "RelayrFirmwareUpdate.h"    // Relayr.framework (Public)
#import "RLAError.h"                // Relayr.framework (Utilities)

static NSString* const kCodingID = @"uid";
static NSString* const kCodingSecret = @"sec";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingOwner = @"own";
static NSString* const kCodingDevices = @"dev";

@implementation RelayrTransmitter
{
    NSMutableSet* _devices;
}

@synthesize devices = _devices;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithID:(NSString*)uid
{
    if (uid.length==0) { return nil; }
    
    self = [super init];
    if (self) { _uid = uid; }
    return self;
}

- (void)setWith:(RelayrTransmitter*)transmitter
{
    if (_uid != transmitter.uid) { return; }
    
    if (transmitter.name) { _name = transmitter.name; }
    if (transmitter.owner) { _owner = transmitter.owner; }
    if (transmitter.secret) { _secret = transmitter.secret; }
    if (transmitter.devices) { [self replaceDevicesWith:(NSMutableSet*)transmitter.devices]; }
}

#pragma mark Processes

- (void)onboardWithClass:(Class <RelayrOnboarding>)onboardingClass completion:(void (^)(NSError* error))completion
{
    if (!onboardingClass) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    [onboardingClass launchOnboardingProcessForTransmitter:self timeout:nil completion:completion];
}

- (void)updateFirmwareWithClass:(Class)updateClass completion:(void (^)(NSError* error))completion
{
    if (!updateClass) { if (completion) { completion(RLAErrorMissingArgument); } return; }
    [updateClass launchFirmwareUpdateProcessForTransmitter:self completion:completion];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithID:[decoder decodeObjectForKey:kCodingID]];
    if (self)
    {
        _name = [decoder decodeObjectForKey:kCodingName];
        _owner = [decoder decodeObjectForKey:kCodingOwner];
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
    [coder encodeObject:_secret forKey:kCodingSecret];
    [coder encodeObject:_devices forKey:kCodingDevices];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"Relayr Transmitter\n{\n\t Relayr ID: %@\n\t Name: %@\n\t Owner: %@\n\t MQTT Secret: %@\n\t Number of devices: %lu\n}\n", _uid, _name, (_owner) ? _owner : @"?", _secret, (unsigned long)_devices.count];
}

#pragma mark - Private methods

/*******************************************************************************
 * It replaces/set the current managed devices by a newer set of devices.
 * If <code>futureDevices</code> is <code>nil</code>, the managed devices are unknown and thus no further working is performed.
 * If <code>futureDevices</code> is an empty set, the transmitter doesn't manage any device.
 * If <code>futureDevices</code> contains <code>RelayrDevice</code> objects, a replacing process will be launched.
 ******************************************************************************/
- (void)replaceDevicesWith:(NSMutableSet*)devices
{
    if (!devices) { return; }
    
    if (devices.count == 0)
    {
        if (!_devices) {
            _devices = [[NSMutableSet alloc] init];
        } else {
            [_devices removeAllObjects];
        }
        return;
    }
    
    NSMutableSet* minusSet = [[NSMutableSet alloc] init];
    for (RelayrDevice* device in _devices)
    {
        NSString* uid = device.uid;
        RelayrDevice* matchedDevice;
        
        for (RelayrDevice* tmpDevice in devices)
        {
            if (uid == tmpDevice.uid)
            {
                matchedDevice = tmpDevice;
                [device setWith:tmpDevice];
                break;
            }
        }
        
        if (!matchedDevice) {
            [minusSet addObject:device];
        } else {
            [devices removeObject:matchedDevice];
        }
    }
    
    [_devices minusSet:minusSet];
}

@end
