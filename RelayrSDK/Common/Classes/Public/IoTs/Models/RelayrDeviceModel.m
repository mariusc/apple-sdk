#import "RelayrDeviceModel.h"       // Header

#import "RelayrFirmware.h"          // Relayr (Public)
#import "RelayrReading.h"           // Relayr (Public)
#import "RelayrWriting.h"           // Relayr (Public)
#import "RelayrDeviceModel_Setup.h" // Relayr (Private)
#import "RelayrFirmware_Setup.h"    // Relayr (Private)
#import "RelayrReading_Setup.h"     // Relayr (Private)
#import "RelayrWriting_Setup.h"     // Relayr (Private)

static NSString* const kCodingUser = @"usr";
static NSString* const kCodingModelID = @"mID";
static NSString* const kCodingModelName = @"mNa";
static NSString* const kCodingManufacturer = @"man";
static NSString* const kCodingFirmwareModels = @"firms";
static NSString* const kCodingReadings = @"rea";
static NSString* const kCodingWritings = @"wri";

@implementation RelayrDeviceModel

#pragma mark - Public API

- (NSSet<RelayrIDSubscripting>*)readingsWithMeanings:(NSArray*)meanings
{
    NSMutableSet* result = [[NSMutableSet alloc] init];
    for (NSString* meaning in meanings)
    {
        for (RelayrReading* reading in _readings)
        {
            if ([reading.meaning isEqualToString:meaning]) { [result addObject:reading]; }
        }
    }
    return result;
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
\t Model ID: %@\n\
\t Model name: %@\n\
\t Manufacturer: %@\n\
\t Num firmwares available: %@\n\
\t Num readings: %@\n\
\t Num writings: %@\
\n}\n", self.modelID, self.modelName, self.manufacturer, (self.firmwaresAvailable) ? @(self.firmwaresAvailable.count) : @"?", (self.readings) ? @(self.readings.count) : @"?", (self.writings) ? @(self.writings.count) : @"?"];
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

- (void)setReadingsWith:(NSSet*)readings
{
    if (!readings) { return; }
    
    NSMutableSet* result = [NSMutableSet setWithCapacity:readings.count];
    
    NSMutableSet* previous = [NSMutableSet setWithSet:_readings];
    for (RelayrReading* neueInput in readings)
    {
        RelayrReading* matchedInput;
        for (RelayrReading* prevInput in previous)
        {
            if ([prevInput.meaning isEqualToString:neueInput.meaning]) { matchedInput = prevInput; break; }
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
    
    _readings = [NSSet setWithSet:result];
    
    // Clean up previous subscriptions since they are not needed anymore.
    for (RelayrReading* pInput in previous) { [pInput unsubscribeToAll]; }
}

- (void)setWritingsWith:(NSSet*)writings
{
    if (!writings) { return; }
    
    NSMutableSet* previous = [NSMutableSet setWithSet:_writings];
    NSMutableSet* result = [NSMutableSet setWithCapacity:writings.count];
    
    for (RelayrWriting* neueOutput in writings)
    {
        RelayrWriting* matchedOutput;
        for (RelayrWriting* pOutput in previous)
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
    
    _writings = [NSSet setWithSet:result];
}

#pragma mark Setup extension

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
    if (self==deviceModel || ![_modelID isEqualToString:deviceModel.modelID]) { return; }
    
    if (deviceModel.user) { _user = deviceModel.user; }
    if (deviceModel.modelName) { _modelName = deviceModel.modelName; }
    if (deviceModel.manufacturer) { _manufacturer = deviceModel.manufacturer; }
    [self setFirmwaresAvailableWith:deviceModel.firmwaresAvailable];
    [self setReadingsWith:deviceModel.readings];
    [self setWritingsWith:deviceModel.writings];
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
        _readings = [decoder decodeObjectForKey:kCodingReadings];
        _writings = [decoder decodeObjectForKey:kCodingWritings];
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
    [coder encodeObject:_readings forKey:kCodingReadings];
    [coder encodeObject:_writings forKey:kCodingWritings];
}

@end
