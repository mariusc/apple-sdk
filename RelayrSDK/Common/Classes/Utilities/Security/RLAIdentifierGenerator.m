#import "RLAIdentifierGenerator.h"      // Header
#import <CBasics/CPlatforms.h>          // Relayr (Utilities)

#if defined(OS_APPLE_IOS) || defined (OS_APPLE_SIMULATOR)
@import UIKit;                          // Apple
#elif defined(OS_APPLE_OSX)
@import Cocoa;                          // Apple
#endif

@implementation RLAIdentifierGenerator

#pragma mark - Public API

+ (NSString*)generateIDFromBaseString:(NSString*)baseString withMaximumRandomNumber:(NSUInteger)max
{
    if (!baseString.length) { return nil; }
    if (max == 0) { return baseString; }
    
    unsigned long const randomNumber = arc4random() % ((unsigned)max + 1);
    return [NSString stringWithFormat:@"%@_%lu", baseString, randomNumber];
}

+ (NSString*)identifierForVendor
{
    NSString* result;
    
    #if defined(OS_APPLE_IOS) || defined (OS_APPLE_SIMULATOR)
    result = [UIDevice currentDevice].identifierForVendor.UUIDString;
    #elif defined(OS_APPLE_OSX)
    result = nil;       // TODO: Find a method for the Mac. https://devforums.apple.com/thread/250731
    #endif
    
    return result;
}

+ (NSString*)randomIDWithMaximumRandomNumber:(NSUInteger)max
{
    if (max == 0) { return nil; }
    
    unsigned long const randomNumber = arc4random() % ((unsigned)max + 1);
    return [NSString stringWithFormat:@"%lu", randomNumber];
}

@end
