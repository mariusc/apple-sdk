#pragma once

#define kTestsTimeout               4

#define kTestsAppID                 @"e411147f-4098-4a8e-a976-b6fe32d52f81"
#define kTestsAppSecret             @"PuuF8IBldAHM4LxRdP95HyWUIGNBYD5O"
#define kTestsAppRedirect           @"https://relayr.io"
#define kTestsAppName               @"Testing app name set"
#define kTestsAppDescription        @"Testing app description set"

#define kTestsUserToken             @"Nincqe90rw8zFSk6Dw1r7WFIJD0iJ-d3"
#define kTestsUserID                @"0d3d5e69-735e-4dea-a6ed-fd6e6ce2c8d0"
#define kTestsUserName              @"Roberto"
#define kTestsUserEmail             @"roberto@relayr.de"

#define kTestsTransmitterName       @"AppleTest Transmitter"
#define kTestsTransmitterModel      nil
#define kTestsTransmitterFirmVr     @"1.0.0"

#define kTestsDeviceName            @"AppleTest Device"
#define kTestsDeviceModel           @"7d7a4def-796f-4fd0-9895-41047c3ab452"
#define kTestsDeviceFirmwVr         @"1.0.0"

#define kTestsWunderbarOnboardingTransmitterTimeout     12
#define kTestsWunderbarOnboardingDeviceTimeout          8
#define kTestsWunderbarOnboardingTimeout                (kTestsWunderbarOnboardingTransmitterTimeout + 6*kTestsWunderbarOnboardingDeviceTimeout)
#define kTestsWunderbarOnboardingOptionsWifiSSID        @"relayr"
#define kTestsWunderbarOnboardingOptionsWifiPassword    @"wearsimaspants"

#define kTestsWunderbarFirmwareUpdateTransmitterTimeout 6
#define kTestsWunderbarFirmwareUpdateDeviceTimeout      3
#define kTestsWunderbarFirmwareUpdateTimeout            (kTestsWunderbarFirmwareUpdateTransmitterTimeout + 6*kTestsWunderbarFirmwareUpdateDeviceTimeout)
