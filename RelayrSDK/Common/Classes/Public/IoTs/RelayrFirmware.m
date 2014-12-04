#import "RelayrFirmware.h"          // Header
#import "RelayrFirmware_Setup.h"    // Relayr.framework (Private)
#import "WunderbarParsing.h"        // Relayr.framework (Wunderbar)

@implementation RelayrFirmware

#pragma mark - Public API

#pragma mark Setup extension

- (void)setWith:(RelayrFirmware*)firmware
{
    [super setWith:firmware];
}

- (NSDictionary*)parseData:(NSData*)data fromService:(id<RLAService>)service atDate:(NSDate**)datePtr
{
    // FIXME: Make it generic. Talk to the server guys
    return [WunderbarParsing parseData:data fromService:service device:(RelayrDevice*)self.deviceModel atDate:datePtr];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        // Fill up when server guys implement something meaningful
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [super encodeWithCoder:coder];
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

@end
