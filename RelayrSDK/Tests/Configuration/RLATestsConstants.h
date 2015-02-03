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
#define kTestsDeviceModel           @"ecf6cf94-cb07-43ac-a85e-dccf26b48c86"
#define kTestsDeviceFirmwVr         @"1.0.0"

#define kTestsMeaningsAngularSpeed  @"angularSpeed"
#define kTestsMeaningsLuminosity    @"luminosity"
#define kTestsMeaningsAcceleration  @"acceleration"
#define kTestsMeaningsTemperature   @"temperature"
#define kTestsMeaningsProximity     @"proximity"
#define kTestsMeaningsColor         @"color"
#define kTestsMeaningsHumidity      @"humidity"
#define kTestsMeaningsNoiseLevel    @"noiseLevel"
#define kTestsMeaningsRaw           @"raw"

#define kTestsWunderbarOnboardingTransmitterTimeout     12
#define kTestsWunderbarOnboardingDeviceTimeout          8
#define kTestsWunderbarOnboardingTimeout                (kTestsWunderbarOnboardingTransmitterTimeout + 6*kTestsWunderbarOnboardingDeviceTimeout)
#define kTestsWunderbarOnboardingOptionsWifiSSID        @"relayr"
#define kTestsWunderbarOnboardingOptionsWifiPassword    @"wearsimaspants"

#define kTestsWunderbarFirmwareUpdateTransmitterTimeout 6
#define kTestsWunderbarFirmwareUpdateDeviceTimeout      3
#define kTestsWunderbarFirmwareUpdateTimeout            (kTestsWunderbarFirmwareUpdateTransmitterTimeout + 6*kTestsWunderbarFirmwareUpdateDeviceTimeout)

#define ADDRESS     "ssl://mqtt.relayr.io:8883"
#define CLIENTID    "manolete"
#define USERNAME    "99a1cfd0-5282-40ce-a73c-ed9ca7c2f01b"
#define PASSWORD    "GZNxt38J75Qu"
#define TOPIC_PUB   "/v1/e2744ce1-4f1b-47ed-aac1-6454d9097409/data"
#define TOPIC_SUB   "/v1/e2744ce1-4f1b-47ed-aac1-6454d9097409/+"
#define QOS         1
#define TIMEOUT     10000L
