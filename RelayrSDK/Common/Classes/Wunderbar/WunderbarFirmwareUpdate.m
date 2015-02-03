#import "WunderbarFirmwareUpdate.h" // Header
#import "RelayrTransmitter.h"       // Relayr (Public)
#import "RelayrDevice.h"            // Relayr (Public)
#import "RelayrErrors.h"            // Relayr (Utilities)
#import "RLALog.h"                  // Relayr (Utilities)
#import "WunderbarConstants.h"      // Relayr (Wunderbar)

@implementation WunderbarFirmwareUpdate

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (void)launchFirmwareUpdateProcessForTransmitter:(RelayrTransmitter*)transmitter timeout:(NSNumber*)timeout completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? Wunderbar_firmUpdate_transmitter_timeout : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    // TODO: Fill up
}

+ (void)launchFirmwareUpdateProcessForDevice:(RelayrDevice*)device timeout:(NSNumber*)timeout completion:(void (^)(NSError* error))completion
{
    NSTimeInterval const timeInterval = (!timeout) ? Wunderbar_firmUpdate_device_timeout : timeout.doubleValue;
    if (!timeInterval <= 0.0) { if (completion) { completion(RelayrErrorMissingExpectedValue); } return; }
    
    // TODO: Fill up
}

@end
