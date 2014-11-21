#import "RelayrDevice.h"            // Header
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relyar.framework (Public)
#import "RelayrFirmware.h"          // Relayr.framework (Public)
#import "RelayrInput.h"             // Relayr.framework (Public)
#import "RelayrConnection.h"        // Relayr.framework (Public)
#import "RelayrOnboarding.h"        // Relayr.framework (Public)
#import "RelayrFirmwareUpdate.h"    // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrFirmware_Setup.h"    // Relayr.framework (Private)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)
#import "RelayrConnection_Setup.h"  // Relayr.framework (Private)
#import "RLAService.h"              // Relayr.framework (Service)
#import "RLAServiceSelector.h"      // Relayr.framework (Service)
#import "RLAAPIService.h"           // Relayr.framework (Service/API)
#import "RLAAPIService+Device.h"    // Relayr.framework (Service/API)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)
#import "RLATargetAction.h"         // Relayr.framework (Utilities)
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
        for (RelayrInput* input in self.inputs) { [input errorReceived:error atDate:date]; }
        return;
    }
    
    __autoreleasing NSDate* parsedDate;
    NSDictionary* dict = [_firmware parseData:value fromService:service atDate:&parsedDate];
    if (!dict.count) { return; }
    if (parsedDate) { date = parsedDate; }
    
    for (RelayrInput* input in self.inputs) { [input valueReceived:dict[input.meaning] atDate:date]; };
}

- (void)unsubscribeToCurrentServiceIfNecessary
{
    if (!self.hasOngoingSubscriptions)
    {
        id <RLAService> service = [RLAServiceSelector serviceCurrentlyInUseByDevice:self];
        if (service) { [service unsubscribeToDataFromDevice:self]; }
    }
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
    return _connection.hasOngoingSubscriptions || self.hasOngoingInputSubscriptions;
}

- (BOOL)hasOngoingInputSubscriptions
{
    for (RelayrInput* input in self.inputs) { if (input.subscribedBlocks.count || input.subscribedTargets.count) { return YES; } }
    return NO;
}

- (void)subscribeToAllInputsWithBlock:(RelayrInputDataReceivedBlock)block error:(RelayrInputErrorReceivedBlock)errorBlock
{
    if (!block) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    for (RelayrInput* input in self.inputs) { [input subscribeWithBlock:block error:errorBlock]; }
}

- (void)subscribeToAllInputsWithTarget:(id)target action:(SEL)action error:(RelayrInputErrorReceivedBlock)errorBlock
{
    RLATargetAction* pair = [[RLATargetAction alloc] initWithTarget:target action:action];
    if (!pair) { if (errorBlock) { errorBlock(RelayrErrorMissingArgument); } return; }
    for (RelayrInput* input in self.inputs) { [input subscribeWithTarget:target action:action error:errorBlock]; }
}

- (void)removeAllSubscriptions
{
    [_connection removeAllSubscriptions];
    for (RelayrInput* input in self.inputs) { [input removeAllSubscriptions]; }
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

#pragma mark NSObject

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
\t Num inputs: %@\n\
\t Num outputs: %@\
\n}\n", _uid, _name, (_owner) ? _owner : @"?", (_firmware.version) ? _firmware.version : @"?", _secret, self.modelID, self.modelName, self.manufacturer, (self.firmwaresAvailable) ? @(self.firmwaresAvailable.count) : @"?", (self.inputs) ? @(self.inputs.count) : @"?", (self.outputs) ? @(self.outputs.count) : @"?"];
}

@end
