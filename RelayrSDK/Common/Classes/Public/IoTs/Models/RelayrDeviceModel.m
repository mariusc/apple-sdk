#import "RelayrDeviceModel.h"       // Header
#import "RelayrDeviceModel_Setup.h" // Relayr.framework (Private)

static NSString* const kCodingModelID = @"mID";
static NSString* const kCodingModelName = @"mNa";
static NSString* const kCodingManufacturer = @"man";
static NSString* const kCodingFirmwareModels = @"firms";
static NSString* const kCodingInputs = @"inp";
static NSString* const kCodingOutputs = @"out";

@implementation RelayrDeviceModel
{
    NSMutableArray* _firmwaresAvailable;
    NSMutableSet* _inputs;
    NSMutableSet* _outputs;
}

@synthesize firmwaresAvailable = _firmwaresAvailable;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

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

- (void)setWith:(RelayrDeviceModel*)deviceModel
{
    if (_modelID != deviceModel.modelID) { return; }
    
    if (deviceModel.modelName) { _modelName = deviceModel.modelName; }
    if (deviceModel.manufacturer) { _manufacturer = deviceModel.manufacturer; }
    if (deviceModel.firmwaresAvailable) { [self replaceAvailableFirmwares:(NSMutableArray*)deviceModel.firmwaresAvailable]; }
    if (deviceModel.inputs) { [self replaceInputs:(NSMutableSet*)deviceModel.inputs]; }
    if (deviceModel.outputs) { [self replaceOutputs:(NSMutableSet*)deviceModel.outputs]; }
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

- (void)replaceAvailableFirmwares:(NSMutableArray*)availableFirmwares
{
    // TODO: Fill up
}

- (void)replaceInputs:(NSMutableSet*)inputs
{
    // TODO: Fill up
}

- (void)replaceOutputs:(NSMutableSet*)outputs
{
    // TODO: Fill up
}

@end
