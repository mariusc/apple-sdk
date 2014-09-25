#import "RelayrFirmware.h"
#import "RelayrFirmware_Setup.h"

@implementation RelayrFirmware

#pragma mark - Public API

- (void)queryCloudForProperties:(void (^)(NSError* error, NSNumber* isThereChanges))completion
{
    // TODO: Fill up
}

- (void)setWith:(RelayrFirmware*)firmware
{
    [super setWith:firmware];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [super encodeWithCoder:coder];
}

@end
