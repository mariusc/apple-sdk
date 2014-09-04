#import "RLANetworkInfo.h"                  // Header
#import "CPlatforms.h"                      // Relayr.framework (Utilities)
@import SystemConfiguration.CaptiveNetwork; // Apple

@implementation RLANetworkInfo

#pragma mark - Public API

+ (NSArray*)networksSSIDs
{
    CFArrayRef array = CNCopySupportedInterfaces();
    if (array == NULL) { return nil; }
    
    return (__bridge_transfer NSArray*)array;
}

+ (NSString*)currentNetworkSSID
{
#if defined(OS_APPLE_IOS) || defined (OS_APPLE_IOS_SIMULATOR)
    // Keys are the BSD- names of the network
    NSArray* networks = [RLANetworkInfo networksSSIDs];
    NSString* result;
    
    // Find the current network
    for (NSString* netName in networks)
    {
        NSDictionary* netInfo = (__bridge_transfer NSDictionary*)CNCopyCurrentNetworkInfo((__bridge CFStringRef)netName);
        if (!netInfo.count) { continue; }
        
        result = netInfo[(__bridge NSString* const)kCNNetworkInfoKeySSID];
        break;
    }
    
    return result;
    
#elif defined(OS_APPLE_OSX)
    #warning "Implement a function to discover current Wifi connection
    return nil;
#endif
}



@end
