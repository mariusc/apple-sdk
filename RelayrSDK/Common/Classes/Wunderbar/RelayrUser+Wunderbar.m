#import "RelayrUser+Wunderbar.h"        // Apple
#import "RelayrUser.h"                  // Relayr.framework (Public)
#import "RelayrTransmitter.h"           // Relayr.framework (Public)
#import "RelayrUser_Setup.h"            // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h"     // Relayr.framework (Private)
#import "RLAWebService+Transmitter.h"   // Relayr.framework (Protocols/Web)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)
#import "RLAWebService+Wunderbar.h"     // Relayr.framework (Wunderbar)

@implementation RelayrUser (Wunderbar)

- (void)registerWunderbarWithName:(NSString*)name completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    [self.webService registerWunderbar:^(NSError* error, RelayrTransmitter* transmitter) {
        if (error) { if (completion) { completion(error, nil); } return; }
        if (!transmitter) { if (completion) { completion(RelayrErrorMissingExpectedValue, nil); } return; }
        
        if (name)
        {
            [self.webService setTransmitter:transmitter.uid withName:name completion:nil];
            transmitter.name = name;
        }
        
        RelayrTransmitter* result = [self addTransmitter:transmitter];
        if (!completion) { return; }
        return (result) ? completion(nil, result) : completion(RelayrErrorMissingExpectedValue, nil);
    }];
}

@end
