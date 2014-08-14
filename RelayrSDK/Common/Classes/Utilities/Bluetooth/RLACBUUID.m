// Header
#import "RLACBUUID.h"

@implementation RLACBUUID

#pragma mark - Public API

+ (NSString *)UUIDStringWithCBUUID:(CBUUID *)uuid
{
    RLAErrorAssertTrueAndReturnNil(uuid, RLAErrorCodeMissingArgument);
    
    // Code taken from this answer on stackoverflow:
    // http://stackoverflow.com/a/13280278
    
    NSData* data = [uuid data];
    NSUInteger bytesToConvert = [data length];
    unsigned char const* uuidBytes = [data bytes];
    NSMutableString* outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:
                [outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]];
                break;
            default:
                [outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
    }
    
    return outputString;
}

@end
