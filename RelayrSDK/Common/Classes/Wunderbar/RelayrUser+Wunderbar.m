#import "RelayrUser+Wunderbar.h"    // Apple
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RLAWebService+Wunderbar.h" // Relayr.framework (Wunderbar)

@implementation RelayrUser (Wunderbar)

- (void)registerWunderbarWithName:(NSString*)name completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    [self.webService registerWunderbar:^(NSError* error, RelayrTransmitter* transmitter) {
#warning Properly implement
        self.devices = transmitter.devices;
        completion(error, transmitter);
    }];
}

@end
