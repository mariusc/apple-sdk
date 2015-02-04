@import Foundation;         // Apple
@class RelayrUser;          // Relayr (Public)
@class RelayrTransmitter;   // Relayr (Public/IoT)
@class RelayrDevice;        // Relayr (Public/IoT)
@class RelayrReading;       // Relayr (Public/IoT)
#import "RelayrConnection.h"

@interface RLADispatcher : NSObject

- (instancetype)initWithUser:(RelayrUser*)user;

@property (readonly,weak,nonatomic) RelayrUser* user;

#pragma mark Subscriptions

- (void)queryDataFromReading:(RelayrReading*)reading;

- (void)subscribeToDataFromReading:(RelayrReading*)reading;

- (void)subscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofReading:(RelayrReading*)reading;

#pragma mark Unsubscriptions

- (void)unsubscribeToDataFromReading:(RelayrReading*)reading;

- (void)unsubscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofReading:(RelayrReading*)reading;

- (void)unsubscribeToCommunicationChannelStateOfReading:(RelayrReading*)reading;

@end
