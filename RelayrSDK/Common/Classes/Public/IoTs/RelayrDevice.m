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
static NSString* const kCodingManufacturer = @"man";
static NSString* const kCodingPublic = @"isP";
static NSString* const kCodingModelID = @"mod";
static NSString* const kCodingFirmware = @"fir";
static NSString* const kCodingInputs = @"inp";
static NSString* const kCodingOutputs = @"out";
static NSString* const kCodingSecret = @"sec";

@implementation RelayrDevice

@synthesize modelID = _modelID;
@synthesize manufacturer = _manufacturer;
@synthesize firmware = _firmware;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;


#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithID:(NSString*)uid secret:(NSString*)secret modelID:(NSString*)modelID
{
    if ( uid.length==0 || secret.length==0 || modelID.length==0 ) { return nil; }
    
    self = [super init];
    if (self)
    {
        _uid = uid;
        _secret = secret;
        _modelID = modelID;
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
    self = [self initWithID:[decoder decodeObjectForKey:kCodingID] secret:[decoder decodeObjectForKey:kCodingName] modelID:[decoder decodeObjectForKey:kCodingModelID]];
    if (self)
    {
        _owner = [decoder decodeObjectForKey:kCodingOwner];
        _manufacturer = [decoder decodeObjectForKey:kCodingManufacturer];
        _isPublic = [decoder decodeObjectForKey:kCodingPublic];
        _firmware = [decoder decodeObjectForKey:kCodingFirmware];
        _inputs = [decoder decodeObjectForKey:kCodingInputs];
        _outputs = [decoder decodeObjectForKey:kCodingOutputs];
        _secret = [decoder decodeObjectForKey:kCodingSecret];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_owner forKey:kCodingOwner];
    [coder encodeObject:_manufacturer forKey:kCodingManufacturer];
    [coder encodeObject:_isPublic forKey:kCodingPublic];
    [coder encodeObject:_modelID forKey:kCodingModelID];
    [coder encodeObject:_firmware forKey:kCodingFirmware];
    [coder encodeObject:_inputs forKey:kCodingInputs];
    [coder encodeObject:_outputs forKey:kCodingOutputs];
    [coder encodeObject:_secret forKey:kCodingSecret];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrDevice\n{\n\t Relayr ID: %@\n\t Name: %@\n\t Owner: %@\n\t Manufacturer: %@\n\tModel ID: %@\n\t Firmware version: %@\n\t Number of inputs: %lu\n\t Number of outputs: %lu\n\t MQTT secret: %@\n}\n", _uid, _name, (_owner) ? _owner : @"?", (_manufacturer) ? _manufacturer : @"?", _modelID, (_firmware.version) ? _firmware.version : @"?", (unsigned long)_inputs.count, (unsigned long)_outputs.count, _secret];
}

@end
