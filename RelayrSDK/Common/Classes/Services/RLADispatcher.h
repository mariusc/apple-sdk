@import Foundation;         // Apple
@class RelayrUser;          // Relayr (Public)
@class RelayrTransmitter;   // Relayr (Public/IoT)
@class RelayrDevice;        // Relayr (Public/IoT)
@class RelayrReading;       // Relayr (Public/IoT)
#import "RelayrConnection.h"

@interface RLADispatcher : NSObject

@property (readonly,weak,nonatomic) RelayrUser* user;

#pragma mark Data queries

- (void)queryDataFromReading:(RelayrReading*)reading;

- (void)queryDataFromDevice:(RelayrDevice*)device;

- (void)queryDataFromTransmitter:(RelayrTransmitter*)transmitter;

#pragma mark Subscriptions

- (void)subscribeToDataFromReading:(RelayrReading*)reading;

- (void)subscribeToDataFromDevice:(RelayrDevice*)device;

- (void)subscribeToDataFromTransmitterDevices:(RelayrTransmitter*)transmitter;

- (void)subscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofReading:(RelayrReading*)reading;

- (void)subscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofDevice:(RelayrDevice*)device;

#pragma mark Unsubscriptions

- (void)unsubscribeToDataFromReading:(RelayrReading*)reading;

- (void)unsubscribeToDataFromDevice:(RelayrDevice*)device;

- (void)unsubscribeToDataFromTransmitterDevices:(RelayrTransmitter*)transmitter;

- (void)unsubscribeToDataFromUserDevices:(RelayrUser*)user;

- (void)unsubscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofReading:(RelayrReading*)reading;

- (void)unsubscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofDevice:(RelayrDevice*)device;

- (void)unsubscribeToCommunicationChannelStateOfReading:(RelayrReading*)reading;

- (void)unsubscribeToCommunicationChannelStateOfDevice:(RelayrDevice*)device;

- (void)unsubscribeToCommunicationChannelStateOfTransmitterDevices:(RelayrTransmitter*)transmitter;

- (void)unsubscribeToCommunicationChannelStateOfUserDevices:(RelayrUser*)user;

@end
