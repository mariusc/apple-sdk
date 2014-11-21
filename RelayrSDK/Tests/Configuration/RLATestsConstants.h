#pragma once

#define kTestsTimeout               4

#define kTestsAppID                 @""
#define kTestsAppSecret             @""
#define kTestsAppRedirect           @""
#define kTestsAppName               @""
#define kTestsAppDescription        @""

#define kTestsUserToken             @""
#define kTestsUserID                @""
#define kTestsUserName              @""
#define kTestsUserEmail             @""

#define kTestsTransmitterName       @""
#define kTestsTransmitterModel      nil
#define kTestsTransmitterFirmVr     @""

#define kTestsDeviceName            @""
#define kTestsDeviceModel           @""
#define kTestsDeviceFirmwVr         @""

#define kTestsWunderbarOnboardingTransmitterTimeout     12
#define kTestsWunderbarOnboardingDeviceTimeout          8
#define kTestsWunderbarOnboardingTimeout                (kTestsWunderbarOnboardingTransmitterTimeout + 6*kTestsWunderbarOnboardingDeviceTimeout)
#define kTestsWunderbarOnboardingOptionsWifiSSID        @""
#define kTestsWunderbarOnboardingOptionsWifiPassword    @""

#define kTestsWunderbarFirmwareUpdateTransmitterTimeout 6
#define kTestsWunderbarFirmwareUpdateDeviceTimeout      3
#define kTestsWunderbarFirmwareUpdateTimeout            (kTestsWunderbarFirmwareUpdateTransmitterTimeout + 6*kTestsWunderbarFirmwareUpdateDeviceTimeout)
