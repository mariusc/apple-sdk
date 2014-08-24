#import "RLANetworkInfo.h"                  // Header
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
    // Keys are the BSD- names of the network
    NSArray* networks = [RLANetworkInfo networksSSIDs];
    NSString* result;
    
#if TARGET_OS_IPHONE
    // Find the current network
    for (NSString* netName in networks)
    {
        NSDictionary* netInfo = (__bridge_transfer NSDictionary*)CNCopyCurrentNetworkInfo((__bridge CFStringRef)netName);
        if (!netInfo.count) { continue; }
        
        result = netInfo[(__bridge NSString* const)kCNNetworkInfoKeySSID];
        break;
    }
#elif TARGET_OS_MAC
    #warning "Implement a function to discover current Wifi connection
#endif
    
    return result;
}



@end
