#import "RelayrDeviceModel.h"       // Header
#import "RelayrDeviceModel_Setup.h" // Relayr.framework (Private)

static NSString* const kCodingModelID = @"mID";
static NSString* const kCodingModelName = @"mNa";
static NSString* const kCodingManufacturer = @"man";
static NSString* const kCodingFirmwareModel = @"fir";
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

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithModelID:[decoder decodeObjectForKey:kCodingModelID]];
    if (self)
    {
        _modelName = [decoder decodeObjectForKey:kCodingModelName];
        _manufacturer = [decoder decodeObjectForKey:kCodingManufacturer];
        _firmware = [decoder decodeObjectForKey:kCodingFirmwareModel];
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
    [coder encodeObject:_firmware forKey:kCodingFirmwareModel];
    [coder encodeObject:_inputs forKey:kCodingInputs];
    [coder encodeObject:_outputs forKey:kCodingOutputs];
}

@end
