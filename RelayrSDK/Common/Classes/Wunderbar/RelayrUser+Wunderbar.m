#import "RelayrUser+Wunderbar.h"        // Apple
#import "RelayrUser.h"                  // Relayr.framework (Public)
#import "RelayrTransmitter.h"           // Relayr.framework (Public)
#import "RelayrUser_Setup.h"            // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h"     // Relayr.framework (Private)
#import "RLAAPIService+Transmitter.h"   // Relayr.framework (Service/API)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)
#import "RLAAPIService+Wunderbar.h"     // Relayr.framework (Wunderbar)

@implementation RelayrUser (Wunderbar)

#pragma mark - Public API

- (void)registerWunderbarWithName:(NSString*)name completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    [self.apiService registerWunderbar:^(NSError* error, RelayrTransmitter* transmitter) {
        if (error) { if (completion) { completion(error, nil); } return; }
        if (!transmitter) { if (completion) { completion(RelayrErrorMissingExpectedValue, nil); } return; }
        
        if (name)
        {
            [self.apiService setTransmitter:transmitter.uid withName:name completion:nil];
            transmitter.name = name;
        }
        
        RelayrTransmitter* result = [self addTransmitter:transmitter];
        if (!completion) { return; }
        
        return (result) ? completion(nil, result) : completion(RelayrErrorMissingExpectedValue, nil);
    }];
}

- (void)deleteWunderbar:(RelayrTransmitter*)transmitter completion:(void (^)(NSError*))completion
{
    if (!transmitter.uid.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    [self.apiService deleteWunder:transmitter completion:^(NSError* error) {
        if (error) { if (completion) { completion(error); } return; };
        
        RelayrUser* user = transmitter.user;
        NSSet* devices = transmitter.devices;
        transmitter.devices = nil;
        
        for (RelayrDevice* device in devices) { [user removeDevice:device]; }
        [user removeTransmitter:transmitter];
        
        if (completion) { completion(nil); }
    }];
}

@end
