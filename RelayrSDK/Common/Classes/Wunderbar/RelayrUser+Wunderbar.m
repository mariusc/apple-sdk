#import "RelayrUser+Wunderbar.h"    // Apple
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RLAWebService+Wunderbar.h" // Relayr.framework (Wunderbar)

@implementation RelayrUser (Wunderbar)

- (void)registerWunderbarWithName:(NSString*)name completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    [self.webService registerWunderbar:^(NSError* error, RelayrTransmitter* transmitter) {
        [self addTransmitter:transmitter];
        for (RelayrDevice* device in transmitter.devices)
        {
            [self addDevice:device];
        }
        completion(error, transmitter);
    }];
}

@end
