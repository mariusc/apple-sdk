#import "RelayrDeviceModel.h"       // Header
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrInput.h"             // Relayr.framework (Public)
#import "RelayrDeviceModel_Setup.h" // Relayr.framework (Private)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)
#import "RLAService.h"              // Relayr.framework (Private)
#import "RLAServiceSelector.h"      // Relayr.framework (Private)

static NSString* const kCodingModelID = @"mID";
static NSString* const kCodingModelName = @"mNa";
static NSString* const kCodingManufacturer = @"man";
static NSString* const kCodingFirmwareModels = @"firms";
static NSString* const kCodingInputs = @"inp";
static NSString* const kCodingOutputs = @"out";

@implementation RelayrDeviceModel

#pragma mark - Public API

- (instancetype)initWithModelID:(NSString*)modelID
{
    if (!modelID.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _modelID = modelID;
    }
    return self;
}

#pragma mark Setup extension

- (void)setWith:(RelayrDeviceModel*)deviceModel
{
    if (self==deviceModel || ![_modelID isEqualToString:deviceModel.modelID]) { return; }
    
    if (deviceModel.modelName) { _modelName = deviceModel.modelName; }
    if (deviceModel.manufacturer) { _manufacturer = deviceModel.manufacturer; }
    if (deviceModel.firmwaresAvailable) { [self replaceAvailableFirmwares:(NSMutableArray*)deviceModel.firmwaresAvailable]; }
    [self replaceInputs:deviceModel.inputs];
    [self replaceOutputs:deviceModel.outputs];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithModelID:[decoder decodeObjectForKey:kCodingModelID]];
    if (self)
    {
        _modelName = [decoder decodeObjectForKey:kCodingModelName];
        _manufacturer = [decoder decodeObjectForKey:kCodingManufacturer];
        _firmwaresAvailable = [decoder decodeObjectForKey:kCodingFirmwareModels];
        _inputs = [decoder decodeObjectForKey:kCodingInputs];
        _outputs = [decoder decodeObjectForKey:kCodingOutputs];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_modelID forKey:kCodingModelID];
    [coder encodeObject:_modelName forKey:kCodingModelName];
    [coder encodeObject:_manufacturer forKey:kCodingManufacturer];
    [coder encodeObject:_firmwaresAvailable forKey:kCodingFirmwareModels];
    [coder encodeObject:_inputs forKey:kCodingInputs];
    [coder encodeObject:_outputs forKey:kCodingOutputs];
}

#pragma mark - Private methods

- (void)replaceAvailableFirmwares:(NSArray*)availableFirmwares
{
    // TODO: Fill up
}

- (void)replaceInputs:(NSSet*)inputs
{
    if (inputs)
    {
        NSMutableSet* result = [NSMutableSet setWithCapacity:inputs.count];
        for (RelayrInput* nInput in inputs)
        {
            RelayrInput* matchedInput = nInput;
            for (RelayrInput* pInput in _inputs)
            {
                if ([pInput.meaning isEqualToString:nInput.meaning]) { matchedInput = pInput; [matchedInput setWith:nInput]; break; }
            }
            [result addObject:matchedInput];
        }
        _inputs = [NSSet setWithSet:result];
    }
    else { _inputs = inputs; }
    
    if ([self isMemberOfClass:[RelayrDevice class]])
    {
        RelayrDevice* device = (RelayrDevice*)self;
        if (!device.hasOngoingSubscriptions)
        {
            id <RLAService> service = [RLAServiceSelector serviceCurrentlyInUseByDevice:device];
            if (service) { [service unsubscribeToDataFromDevice:device]; }
        }
    }
}

- (void)replaceOutputs:(NSSet*)outputs
{
    // TODO: Fill up
}

@end
