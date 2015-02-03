#import "RLADispatcher.h"       // Header
#import "RelayrUser.h"          // Relayr (Public)
#import "RelayrTransmitter.h"   // Relayr (Public/IoTs)
#import "RelayrDevice.h"        // Relayr (Public/IoTs)
#import "RelayrReading.h"       // Relayr (Public/IoTs)

@implementation RLADispatcher

#pragma mark - Public API

- (void)queryDataFromReading:(RelayrReading*)reading
{
    // TODO:
}

- (void)queryDataFromDevice:(RelayrDevice*)device
{
    
}

- (void)queryDataFromTransmitter:(RelayrTransmitter*)transmitter
{
    
}

- (void)subscribeToDataFromReading:(RelayrReading*)reading
{
    
}

- (void)subscribeToDataFromDevice:(RelayrDevice*)device
{
    
}

- (void)subscribeToDataFromTransmitterDevices:(RelayrTransmitter*)transmitter
{
    
}

- (void)subscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofReading:(RelayrReading*)reading
{
    
}

- (void)subscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofDevice:(RelayrDevice*)device
{
    
}

- (void)unsubscribeToDataFromReading:(RelayrReading*)reading
{
    
}

- (void)unsubscribeToDataFromDevice:(RelayrDevice*)device
{
    
}

- (void)unsubscribeToDataFromTransmitterDevices:(RelayrTransmitter*)transmitter
{
    
}

- (void)unsubscribeToDataFromUserDevices:(RelayrUser*)user
{
    
}

- (void)unsubscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofReading:(RelayrReading*)reading
{
    
}

- (void)unsubscribeToCommunicationChannelState:(RelayrConnectionProtocol)protocol ofDevice:(RelayrDevice*)device
{
    
}

- (void)unsubscribeToCommunicationChannelStateOfReading:(RelayrReading*)reading
{
    
}

- (void)unsubscribeToCommunicationChannelStateOfDevice:(RelayrDevice*)device
{
    
}

- (void)unsubscribeToCommunicationChannelStateOfTransmitterDevices:(RelayrTransmitter*)transmitter
{
    
}

- (void)unsubscribeToCommunicationChannelStateOfUserDevices:(RelayrUser*)user
{
    
}

@end
