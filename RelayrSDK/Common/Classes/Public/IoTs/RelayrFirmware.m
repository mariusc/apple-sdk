#import "RelayrFirmware.h"          // Header
#import "RelayrFirmware_Setup.h"    // Relayr.framework (Private)

@implementation RelayrFirmware

#pragma mark - Public API

#pragma mark Setup extension

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
