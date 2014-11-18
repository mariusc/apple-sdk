#import "RelayrOutput.h"            // Header
#import "RelayrOutput_Setup.h"      // Relayr.framework (Private)

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrDeviceModel.h"       // Relayr.framework (Public)
#import "RelayrErrors.h"            // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)
#import "RLAAPIService+Device.h"    // Relayr.framework (Service/API)

static NSString* const kCodingMeaning = @"men";

@implementation RelayrOutput

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (void)sendValue:(NSString*)value withCompletion:(void (^)(NSError*))completion
{
    if (!_deviceModel || ![_deviceModel isKindOfClass:[RelayrDevice class]]) { if (completion) { completion(RelayrErrorTryingToUseRelayrModel); } return; }
    RelayrDevice* device = (RelayrDevice*)_deviceModel;
    RelayrUser* user = device.user;
    if (!user) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    [user.apiService sendToDeviceID:device.uid withMeaning:_meaning value:value completion:completion];
}

#pragma mark Setup extension

- (instancetype)initWithMeaning:(NSString*)meaning
{
    self = [super init];
    if (self)
    {
        _meaning = meaning;
    }
    return self;
}

- (void)setWith:(RelayrOutput*)output
{
    if (!output.meaning.length) { return; }
    
    // TODO: Fill up
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    return [self initWithMeaning:[decoder decodeObjectForKey:kCodingMeaning]];
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_meaning forKey:kCodingMeaning];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrOutput\n{\n\t Meaning: %@}\n", _meaning];
}

@end
