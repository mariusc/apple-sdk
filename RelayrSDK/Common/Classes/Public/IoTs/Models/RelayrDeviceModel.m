#import "RelayrDeviceModel.h"       // Header

#import "RelayrFirmware.h"          // Relayr.framework (Public)
#import "RelayrInput.h"             // Relayr.framework (Public)
#import "RelayrOutput.h"            // Relayr.framework (Public)
#import "RelayrDeviceModel_Setup.h" // Relayr.framework (Private)
#import "RelayrFirmware_Setup.h"    // Relayr.framework (Private)
#import "RelayrInput_Setup.h"       // Relayr.framework (Private)
#import "RelayrOutput_Setup.h"      // Relayr.framework (Private)

static NSString* const kCodingUser = @"usr";
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

- (RelayrInput*)inputWithMeaning:(NSString*)meaning
{
    if (!meaning.length) { return nil; }
    
    RelayrInput* matchedInput;
    for (RelayrInput* input in _inputs)
    {
        if ([meaning isEqualToString:input.meaning]) { matchedInput=input; break; }
    }
    return matchedInput;
}

#pragma mark Setup extension

- (void)setWith:(RelayrDeviceModel*)deviceModel
{
    if (self==deviceModel || ![_modelID isEqualToString:deviceModel.modelID]) { return; }
    
    if (deviceModel.modelName) { _modelName = deviceModel.modelName; }
    if (deviceModel.manufacturer) { _manufacturer = deviceModel.manufacturer; }
    [self setFirmwaresAvailableWith:deviceModel.firmwaresAvailable];
    [self setInputsWith:deviceModel.inputs];
    [self setOutputsWith:deviceModel.outputs];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithModelID:[decoder decodeObjectForKey:kCodingModelID]];
    if (self)
    {
        _user = [decoder decodeObjectForKey:kCodingUser];
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
    [coder encodeObject:_user forKey:kCodingUser];
    [coder encodeObject:_modelID forKey:kCodingModelID];
    [coder encodeObject:_modelName forKey:kCodingModelName];
    [coder encodeObject:_manufacturer forKey:kCodingManufacturer];
    [coder encodeObject:_firmwaresAvailable forKey:kCodingFirmwareModels];
    [coder encodeObject:_inputs forKey:kCodingInputs];
    [coder encodeObject:_outputs forKey:kCodingOutputs];
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

#pragma mark - Private methods

- (void)setFirmwaresAvailableWith:(NSArray*)availableFirmwares
{
    if (!availableFirmwares) { return; }
    
    NSMutableSet* previous = [NSMutableSet setWithArray:_firmwaresAvailable];
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:availableFirmwares.count];
    
    for (RelayrFirmware* neueFirmware in availableFirmwares)
    {
        RelayrFirmware* matchedFirmware;
        for (RelayrFirmware* pFirm in previous)
        {
            if ([pFirm.version isEqualToString:neueFirmware.version]) { matchedFirmware = pFirm; break; }
        }
        
        if (matchedFirmware)
        {
            [previous removeObject:matchedFirmware];
            [matchedFirmware setWith:neueFirmware];
        }
        else
        {
            matchedFirmware = neueFirmware;
            matchedFirmware.deviceModel = self;
        }
        
        [result addObject:matchedFirmware];
    }
    
    _firmwaresAvailable = [NSMutableArray arrayWithArray:result];
}

- (void)setInputsWith:(NSSet*)inputs
{
    if (!inputs) { return; }
    
    NSMutableSet* previous = [NSMutableSet setWithSet:_inputs];
    NSMutableSet* result = [NSMutableSet setWithCapacity:inputs.count];
    
    for (RelayrInput* neueInput in inputs)
    {
        RelayrInput* matchedInput;
        for (RelayrInput* pInput in previous)
        {
            if ([pInput.meaning isEqualToString:neueInput.meaning]) { matchedInput = pInput; break; }
        }
        
        if (matchedInput)
        {
            [previous removeObject:matchedInput];
            [matchedInput setWith:neueInput];
        }
        else
        {
            matchedInput = neueInput;
            matchedInput.deviceModel = self;
        }
        
        [result addObject:matchedInput];
    }
    
    _inputs = [NSSet setWithSet:result];
    
    // Clean up previous subscriptions since they are not needed anymore.
    for (RelayrInput* pInput in previous) { [pInput removeAllSubscriptions]; }
}

- (void)setOutputsWith:(NSSet*)outputs
{
    if (!outputs) { return; }
    
    NSMutableSet* previous = [NSMutableSet setWithSet:_outputs];
    NSMutableSet* result = [NSMutableSet setWithCapacity:outputs.count];
    
    for (RelayrOutput* neueOutput in outputs)
    {
        RelayrOutput* matchedOutput;
        for (RelayrOutput* pOutput in previous)
        {
            if ([pOutput.meaning isEqualToString:neueOutput.meaning]) { matchedOutput = pOutput; break; }
        }
        
        if (matchedOutput)
        {
            [previous removeObject:matchedOutput];
            [matchedOutput setWith:neueOutput];
        }
        else
        {
            matchedOutput = neueOutput;
            matchedOutput.deviceModel = self;
        }
        
        [result addObject:matchedOutput];
    }
    
    _outputs = [NSSet setWithSet:result];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrDevice\n{\n\
\t Model ID: %@\n\
\t Model name: %@\n\
\t Manufacturer: %@\n\
\t Num firmwares available: %@\n\
\t Num inputs: %@\n\
\t Num outputs: %@\
\n}\n", self.modelID, self.modelName, self.manufacturer, (self.firmwaresAvailable) ? @(self.firmwaresAvailable.count) : @"?", (self.inputs) ? @(self.inputs.count) : @"?", (self.outputs) ? @(self.outputs.count) : @"?"];
}

@end
