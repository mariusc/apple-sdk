#import "RelayrFirmwareModel.h"         // Header

#import "RelayrUser.h"                  // Relayr.framework (Public)
#import "RelayrDeviceModel.h"           // Relayr.framework (Public)
#import "RelayrUser_Setup.h"            // Relayr.framework (Private)
#import "RelayrFirmwareModel_Setup.h"   // Relayr.firmware (Private)
#import "RLAAPIService+Device.h"        // Relayr.framework (Service/API)

static NSString* const kCodingVersion = @"ver";
static NSString* const kCodingConfiguration = @"con";

@implementation RelayrFirmwareModel
{
    NSMutableDictionary* _configuration;
}

@synthesize configuration = _configuration;

#pragma mark - Public API

- (void)queryCloudForDefaultConfigurationValues:(void (^)(NSError* error))completion
{
    [self.deviceModel.user.apiService requestDeviceModel:self.deviceModel.modelID completion:^(NSError* error, RelayrDeviceModel* deviceModel) {
        if (error) { if (completion) { completion(error); } return; }
    }];
}

#pragma mark Setup extension

- (instancetype)initWithVersion:(NSString*)version
{
    if (!version.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _version = version;
    }
    return self;
}

- (void)setWith:(RelayrFirmwareModel*)firmwareModel
{
    if (!firmwareModel || self==firmwareModel || ![_version isEqualToString:firmwareModel.version]) { return; }

    if (firmwareModel.version) { _version = firmwareModel.version; }
    if (firmwareModel.configuration) { _configuration = (NSMutableDictionary*)firmwareModel.configuration; }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithVersion:[decoder decodeObjectForKey:kCodingVersion]];
    if (self)
    {
        _configuration = [decoder decodeObjectForKey:kCodingConfiguration];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_version forKey:kCodingVersion];
    [coder encodeObject:_configuration forKey:kCodingConfiguration];
}

#pragma mark NSObject

- (NSString*)description
{
    NSString* configurations;
    if (_configuration)
    {
        NSMutableString* tmp = [[NSMutableString alloc] initWithString:@"{ "];
        [_configuration enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [tmp appendString:[NSString stringWithFormat:@"%@ : %@", key, obj]];
        }];
        [tmp appendString:@" }"];
    }
    else { configurations = @"?"; }
    
    return [NSString stringWithFormat:@"RelayrFirmware\n{\n\
\t Version: %@\n\
\t Configurations: %@\n\
}\n", _version, configurations];
}

@end
