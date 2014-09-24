#pragma once

#pragma mark - Wunderbar onboarding options

FOUNDATION_EXPORT NSString* const kWunderbarOnboardingOptionsWifiSSID;
FOUNDATION_EXPORT NSString* const kWunderbarOnboardingOptionsWifiPassword;

#pragma mark - Peripheral advertisement

#define Wunderbar_MQTTServer                            @"mqtt.relayr.io"
#define Wunderbar_peripheralAdvertisement_localName     @"WunderbarApp"

#pragma mark - Wunderbar requests

#define Web_RequestRelativePath_WunderbarRegistration(userID)   [NSString stringWithFormat:@"/users/%@/wunderbar", userID]
#define Web_RequestResponseCode_WunderbarRegistration           201

#define Web_RespondKey_WunderbarMasterModule    @"masterModule"
#define Web_RespondKey_WunderbarGyroscope       @"gyroscope"
#define Web_RespondKey_WunderbarLight           @"light"
#define Web_RespondKey_WunderbarMicrophone      @"microphone"
#define Web_RespondKey_WunderbarThermomether    @"thermometer"
#define Web_ResopndKey_WunderbarInfrared        @"infrared"
#define Web_RespondKey_WunderbarBridge          @"bridge"

#pragma mark - Wunderbar model IDs

#define Wunderbar_devicemodel_gyroscope         @"173c44b5-334e-493f-8eb8-82c8cc65d29f"
#define Wunderbar_devicemodel_light             @"a7ec1b21-8582-4304-b1cf-15a1fc66d1e8"
#define Wunderbar_devicemodel_microphone        @"4f38b6c6-a8e9-4f93-91cd-2ac4064b7b5a"
#define Wunderbar_devicemodel_thermometer       @"ecf6cf94-cb07-43ac-a85e-dccf26b48c86"
#define Wunderbar_devicemodel_infrared          @"bab45b9c-1c44-4e71-8e98-a321c658df47"
#define Wunderbar_devicemodel_bridge            @"ebd828dd-250c-4baf-807d-69d85bed065b"

#pragma mark - Onboarding process

#define Wunderbar_transmitter_setupTimeout                  10
#define Wunderbar_transmitter_setupService                  @"2000"
#define Wunderbar_transmitter_setupServiceCharacteristics   7
#define Wunderbar_transmitter_setupServiceCharacteristicsReadTime       0.2
#define Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey   @"2010"
#define Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey      @"2011"
#define Wunderbar_transmitter_setupCharacteristic_wifiSSID              @"2012"
#define Wunderbar_transmitter_setupCharacteristic_wifiPasskey           @"2013"
#define Wunderbar_transmitter_setupCharacteristic_wunderbarID           @"2014"
#define Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity     @"2015"
#define Wunderbar_transmitter_setupCharacteristic_wunderbarURL          @"2016"

#define Wunderbar_transmitter_setupCharacteristic_htuGyroLightPasskey_length    19
#define Wunderbar_transmitter_setupCharacteristic_micBridIRPasskey_length       19
#define Wunderbar_transmitter_setupCharacteristic_wifiSSID_length               20
#define Wunderbar_transmitter_setupCharacteristic_wifiPasskey_length            20
#define Wunderbar_transmitter_setupCharacteristic_wunderbarID_length            17
#define Wunderbar_transmitter_setupCharacteristic_wunderbarSecurity_length      13
#define Wunderbar_transmitter_setupCharacteristic_wunderbarURL_length           20

#define Wunderbar_device_setupTimeout                       10
#define Wunderbar_device_setupService                       @"2001"
#define Wunderbar_device_setupCharacteristic_sensorID           @"2010"
#define Wunderbar_device_setupCharacteristic_passKey            @"2018"
#define Wunderbar_device_setupCharacteristic_mimFlag            @"2019"
#define Wunderbar_device_cloudService                       @"2000"
#define Wunderbar_device_cloudCharacteristic_sensorID           @"2010"
#define Wunderbar_device_cloudCharacteristic_beaconFrequency    @"2011"
#define Wunderbar_device_cloudCharacteristic_frequency          @"2012"
#define Wunderbar_device_cloudCharacteristic_LEDState           @"2013"
#define Wunderbar_device_cloudCharacteristic_threshold          @"2014"
#define Wunderbar_device_cloudCharacteristic_config             @"2015"
#define Wunderbar_device_cloudCharacteristic_dataRead           @"2016"
#define Wunderbar_device_cloudCharacteristic_dataWrite          @"2017"
#define Wunderbar_device_directService                      @"2002"
#define Wunderbar_device_directCharacteristic_sensorID          @"2010"
#define Wunderbar_device_directCharacteristic_beaconFrequency   @"2011"
#define Wunderbar_device_directCharacteristic_frequency         @"2012"
#define Wunderbar_device_directCharacteristic_LEDState          @"2013"
#define Wunderbar_device_directCharacteristic_threshold         @"2014"
#define Wunderbar_device_directCharacteristic_config            @"2015"
#define Wunderbar_device_directCharacteristic_dataRead          @"2016"
#define Wunderbar_device_directCharacteristic_dataWrite         @"2017"

#pragma mark - Firmware update process

#define Wunderbar_firmUpdate_transmitter_timeout    15

#define Wunderbar_firmUpdate_device_timeout         15
