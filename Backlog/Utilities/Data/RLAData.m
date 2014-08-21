#import "RLAData.h"     // Header

@implementation RLAData

#pragma mark - Conversion

+ (NSData*)shortUidWithLongUidString:(NSString*)uid
{
    NSMutableData* shortUidData = [[NSMutableData alloc] init];
	NSString* cleanUID = [uid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	for (int i=0; i<cleanUID.length/2; ++i)
    {
        byte_chars[0] = [cleanUID characterAtIndex:i*2];
        byte_chars[1] = [cleanUID characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [shortUidData appendBytes:&whole_byte length:1];
	}
	
	return [shortUidData copy];
}

@end
