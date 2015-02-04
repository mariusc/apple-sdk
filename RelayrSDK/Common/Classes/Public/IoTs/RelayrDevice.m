#import "RelayrDevice.h"            // Header

#import "RelayrUser.h"              // Relayr (Public)
#import "RelayrTransmitter.h"       // Relayr (Public)
#import "RelayrFirmware.h"          // Relayr (Public)
#import "RelayrReading.h"           // Relayr (Public)
#import "RelayrConnection.h"        // Relayr (Public)
#import "RelayrOnboarding.h"        // Relayr (Public)
#import "RelayrFirmwareUpdate.h"    // Relayr (Public)
#import "RelayrUser_Setup.h"        // Relayr (Private)
#import "RelayrDevice_Setup.h"      // Relayr (Private)
#import "RelayrFirmware_Setup.h"    // Relayr (Private)
#import "RelayrReading_Setup.h"     // Relayr (Private)
#import "RelayrConnection_Setup.h"  // Relayr (Private)
#import "RLAService.h"              // Relayr (Service)
#import "RLAAPIService.h"           // Relayr (Services/API)
#import "RLAAPIService+Device.h"    // Relayr (Services/API)
#import "RelayrErrors.h"            // Relayr (Utilities)
#import "RLATargetAction.h"         // Relayr (Utilities)
#import "RLALog.h"                  // Relayr (Utilities)

static NSString* const kCodingID = @"uid";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingOwner = @"own";
static NSString* const kCodingPublic = @"isP";
static NSString* const kCodingFirmware = @"fir";
static NSString* const kCodingSecret = @"sec";

@implementation RelayrDevice

@synthesize uid = _uid;

#pragma mark - Public API

- (RelayrTransmitter*)transmitter
{
    for (RelayrTransmitter* transmitter in self.user.transmitters)
    {
        for (RelayrDevice* device in transmitter.devices) { if (device==self) { return transmitter; } }
    }
    
    return nil;
}

- (void)setNameWith:(NSString*)name completion:(void (^)(NSError*, NSString*))completion
{
    if (!name.length) { if (completion) { completion(RelayrErrorMissingArgument, _name); } return; }
    
    __weak RelayrDevice* weakSelf = self;
    [self.user.apiService setDevice:_uid name:name modelID:nil isPublic:nil description:nil completion:(!completion) ? nil : ^(NSError* error, RelayrDevice* device) {
        NSString* previousName = weakSelf.name;
        if (error) { return completion(error, previousName); }
        
        weakSelf.name = name;
        completion(nil, previousName);
    }];
}

#pragma mark Processes

- (void)onboardWithClass:(Class <RelayrOnboarding>)onboardingClass timeout:(NSNumber*)timeout options:(NSDictionary*)options completion:(void (^)(NSError* error))completion
{
    [onboardingClass launchOnboardingProcessForDevice:self timeout:timeout options:options completion:completion];
}

- (void)updateFirmwareWithClass:(Class <RelayrFirmwareUpdate>)updateClass timeout:(NSNumber*)timeout options:(NSDictionary*)options completion:(void (^)(NSError* error))completion
{
    [updateClass launchFirmwareUpdateProcessForDevice:self timeout:timeout options:options completion:completion];
}

#pragma mark Subscription

- (BOOL)hasOngoingSubscriptions
{
    return (_connection.hasOngoingSubscriptions || self.hasOngoingReadingSubscriptions);
}

- (BOOL)hasOngoingReadingSubscriptions
{
    for (RelayrReading* reading in self.readings) { if (reading.subscribedBlocks.count || reading.subscribedTargets.count) { return YES; } }
    return NO;
}

- (void)subscribeToAllReadingsWithBlock:(RelayrReadingDataReceivedBlock)block error:(RelayrReadingErrorReceivedBlock)errorBlock
{
    if (!block) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    for (RelayrReading* reading in self.readings) { [reading subscribeWithBlock:block error:errorBlock]; }
}

- (void)subscribeToAllReadingsWithTarget:(id)target action:(SEL)action error:(RelayrReadingErrorReceivedBlock)errorBlock
{
    RLATargetAction* pair = [[RLATargetAction alloc] initWithTarget:target action:action];
    if (!pair) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    for (RelayrReading* reading in self.readings) { [reading subscribeWithTarget:target action:action error:errorBlock]; }
}

- (void)unsubscribeToAll
{
    [_connection unsubscribeToAll];
    for (RelayrReading* reading in self.readings) { [reading unsubscribeToAll]; }
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
        _connection = [[RelayrConnection alloc] initWithDevice:self];
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

#pragma mark NSCopying & NSMutableCopying

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
    return self;
}

#pragma mark NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrDevice\n{\n\
\t Relayr ID: %@\n\
\t Name: %@\n\
\t Owner: %@\n\
\t Firmware version: %@\n\
\t MQTT secret: %@\n\
\t Model ID: %@\n\
\t Model name: %@\n\
\t Manufacturer: %@\n\
\t Num firmwares available: %@\n\
\t Num readings: %@\n\
\t Num writings: %@\
\n}\n", _uid, _name, (_owner) ? _owner : @"?", (_firmware.version) ? _firmware.version : @"?", _secret, self.modelID, self.modelName, self.manufacturer, (self.firmwaresAvailable) ? @(self.firmwaresAvailable.count) : @"?", (self.readings) ? @(self.readings.count) : @"?", (self.writings) ? @(self.writings.count) : @"?"];
}

#pragma mark - Private functionality

#pragma mark Setup extension

- (instancetype)initWithID:(NSString*)uid modelID:(NSString*)modelID
{
    if ( !uid.length || !modelID.length ) { return nil; }
    
    self = [super initWithModelID:modelID];
    if (self)
    {
        _uid = uid;
        _connection = [[RelayrConnection alloc] initWithDevice:self];
    }
    return self;
}

- (void)setWith:(RelayrDevice*)device
{
    if (self==device || ![_uid isEqualToString:device.uid]) { return; }
    
    [super setWith:device];
    if (device.name) { _name = device.name; }
    if (device.owner) { _owner = device.owner; }
    if (device.isPublic) { _isPublic = device.isPublic; }
    if (device.secret) { _secret = device.secret; }
    [_firmware setWith:device.firmware];
    [_connection setWith:device.connection];
}

- (void)handleBinaryValue:(NSData*)value fromService:(id<RLAService>)service atDate:(NSDate*)date withError:(NSError*)error
{
    if (error)
    {
        for (RelayrReading* reading in self.readings) { [reading errorReceived:error atDate:date]; }
        return;
    }
    
    __autoreleasing NSDate* parsedDate;
    NSDictionary* dict = [_firmware parseData:value fromService:service atDate:&parsedDate];
    if (!dict.count) { return; }
    if (parsedDate) { date = parsedDate; }
    
    for (RelayrReading* reading in self.readings) { [reading valueReceived:dict[reading.meaning] atDate:date]; };
}

@end
