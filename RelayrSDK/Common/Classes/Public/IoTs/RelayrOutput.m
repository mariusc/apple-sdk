#import "RelayrOutput.h"            // Header
#import "RelayrOutput_Setup.h"      // Relayr.framework (Private)

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrDeviceModel.h"       // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Public)
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)
#import "RLAWebService+Device.h"    // Relayr.framework (Web)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)

static NSString* const kCodingMeaning = @"men";

@implementation RelayrOutput

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithMeaning:(NSString*)meaning
{
    self = [super init];
    if (self)
    {
        _meaning = meaning;
    }
    return self;
}

- (void)sendValue:(NSString*)value withCompletion:(void (^)(NSError*))completion
{
    if (!_device || ![_device isKindOfClass:[RelayrDevice class]]) { if (completion) { completion(RelayrErrorTryingToUseRelayrModel); } return; }
    RelayrDevice* device = (RelayrDevice*)_device;
    RelayrUser* user = device.user;
    if (!user) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    [user.webService sendToDeviceID:device.uid withMeaning:_meaning value:value completion:completion];
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
