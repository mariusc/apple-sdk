#import "RLANetworkInfo.h"                  // Header
@import SystemConfiguration.CaptiveNetwork; // Apple

@implementation RLANetworkInfo

#pragma mark - Public API

+ (NSArray*)networksSSIDs
{
    return (__bridge_transfer NSArray*)CNCopySupportedInterfaces();
}

+ (NSString*)currentNetworkSSID
{
    NSArray* networks = [RLANetworkInfo networksSSIDs];
    
    // Find the current network
    NSString* result;
    
    for (NSString* netName in networks)
    {
        NSDictionary* netInfo = (__bridge_transfer NSDictionary*)CNCopyCurrentNetworkInfo((__bridge CFStringRef)netName);
        if (!netInfo.count) { continue; }
        
        result = netInfo[@"SSID"];
        break;
    }
    
    return result;
}



@end
