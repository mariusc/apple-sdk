#pragma once

// This macro expands into the reiterative process request (Be careful when changing variable names).
#define RLAAPI_processHTTPresponse(expectedCode, ...)   \
    (!error && ((NSHTTPURLResponse*)response).statusCode==expectedCode && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil; \
    if (!json) { if (completion) { completion( (error) ? error : RelayrErrorWebRequestFailure, __VA_ARGS__); } return; }

#pragma mark - Common values

#define dRLAAPI_Host                                    @"https://api.relayr.io"
#define dRLAAPIRequest_Timeout                          10
#define dRLAAPIRequest_HeaderField_Authorization        @"Authorization"
#define dRLAAPIRequest_HeaderValue_Authorization(token) [NSString stringWithFormat:@"Bearer %@", token]
#define dRLAAPIRequest_HeaderField_ContentType          @"Content-Type"
#define dRLAAPIRequest_HeaderValue_ContentType_UTF8     @"application/x-www-form-urlencoded; charset=utf-8"
#define dRLAAPIRequest_HeaderValue_ContentType_JSON     @"application/json"
#define dRLAAPIRequest_HeaderField_UserAgent            @"User-Agent"
#define dRLAAPIRequest_Respond_BadRequest               400

#pragma mark - RLAAPIService

#pragma mark RLAAPIService+Cloud

// Cloud reachable?
#define dRLAAPI_CloudReachability_RelativePath          @"/device-models"
#define dRLAAPI_CloudReachability_ResponseCode          200
// OAuth temporal code
#define dRLAWebOAuthController_Timeout                  10
#define dRLAWebOAuthController_CodeRequestURL(clientID,redirectURI)    [NSString stringWithFormat:@"/oauth2/auth?client_id=%@&redirect_uri=%@&response_type=code&scope=access-own-user-info", clientID, redirectURI]
#define dRLAWebOAuthController_Title                    @"Relayr"
#define dRLAWebOAuthControllerIOS_Spinner_Animation     0.3
#define dRLAWebOAuthControllerOSX_WindowStyle           (NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask)
#define dRLAWebOAuthControllerOSX_WindowSize            NSMakeRect(0.0f, 0.0f, 1050.0f, 710.0f)
#define dRLAWebOAuthControllerOSX_WindowSizeMin         NSMakeSize(350.0f, 450.0f)
// OAuth token
#define dRLAAPI_CloudOAuthToken_RelativePath            @"/oauth2/token"
#define dRLAAPI_CloudOAuthToken_HTTPBody(code, redirectURI, clientID, clientSecret) [NSString stringWithFormat:@"code=%@&redirect_uri=%@&client_id=%@&scope=&client_secret=%@&grant_type=authorization_code", code, [redirectURI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], clientID, clientSecret]
#define dRLAAPI_CloudOAuthToken_ResponseCode            200
#define dRLAAPI_CloudOAuthToken_RespondKey_AccessToken  @"access_token"
// Logging
#define dRLAAPI_CloudLogging_RelativePath               @"/client/log"

#pragma mark RLAAPIService+App

// All Relayr's apps
#define dRLAAPI_Apps_RelativePath                       @"/apps"
#define dRLAAPI_Apps_ResponseCode                       200
// App registration
#define dRLAAPI_AppRegistration_RelativePath            @"/apps"
#define dRLAAPI_AppRegistration_ResponseCode            201
// App info
#define dRLAAPI_AppInfo_RelativePath(appID)             [NSString stringWithFormat:@"/apps/%@", appID]
#define dRLAAPI_AppInfo_ResponseCode                    200
// App info (extended)
#define dRLAAPI_AppInfoExt_RelativePath(appID)          [NSString stringWithFormat:@"/apps/%@/extended", appID]
#define dRLAAPI_AppInfoExt_ResponseCode                 200
// App info (set)
#define dRLAAPI_AppInfoSet_RelativePath(appID)          [NSString stringWithFormat:@"/apps/%@", appID]
#define dRLAAPI_AppInfoSet_ResponseCode                 200
// App deletion
#define dRLAAPI_AppDeletion_RelativePath(appID)         [NSString stringWithFormat:@"/apps/%@", appID]
#define dRLAAPI_AppDeletion_ResponseCode                204
// Connect app to device
#define dRLAAPI_AppConnection_RelativePath(devID, apID) [NSString stringWithFormat:@"/apps/%@/devices/%@", apID, devID]
#define dRLAAPI_AppConnection_ResponseCode              200
// Disconnect app to device
#define dRLAAPI_AppDisconn_RelativePath(devID, appID)   [NSString stringWithFormat:@"/apps/%@/devices/%@", appID, devID]
#define dRLAAPI_AppDisconn_ResponseCode                 204
// HTTP Request body keys
#define dRLAAPI_App_RequestKey_Name                     @"name"
#define dRLAAPI_App_RequestKey_Publisher                @"publisher"
#define dRLAAPI_App_RequestKey_Description              @"description"
#define dRLAAPI_App_RequestKey_RedirectURI              @"redirectUri"
// HTTP Respond body keys
#define dRLAAPI_App_RespondKey_ID                       @"id"
#define dRLAAPI_App_RespondKey_App                      @"app"
#define dRLAAPI_App_RespondKey_Name                     @"name"
#define dRLAAPI_App_RespondKey_Description              @"description"
#define dRLAAPI_App_RespondKey_Publisher                @"publisher"
#define dRLAAPI_App_RespondKey_Owner                    @"owner"
#define dRLAAPI_App_RespondKey_OAuthClientSecret        @"clientSecret"
#define dRLAAPI_App_RespondKey_RedirectURI              @"redirectUri"
#define dRLAAPI_App_RespondKey_ConnectedDevices         @"connectedDevices"

#pragma mark RLAAPIService+User

// User's email check
#define dRLAAPI_UserEmailCheck_RelativePath(email)      [NSString stringWithFormat:@"/users/validate?email=%@", email]
#define dRLAAPI_UserEmailCheck_ResponseCode             200
#define dRLAAPI_UserEmailCheck_ResponseKey              @"exists"
// User's info (get)
#define dRLAAPI_UserInfo_RelativePath                   @"/oauth2/user-info"
#define dRLAAPI_UserInfo_ResponseCode                   200
// User's info (set)
#define dRLAAPI_UserSetInfo_RelativePath(userID)        [NSString stringWithFormat:@"/users/%@", userID]
#define dRLAAPI_UserSetInfo_ResponseCode                200
// Install app under user
#define dRLAAPI_UserAppAuth_RelativePath(userID, appID) [NSString stringWithFormat:@"/users/%@/apps/%@", userID, appID]
#define dRLAAPI_UserAppAuth_ResponseCode                200
// User's apps
#define dRLAAPI_UserAuthApps_RelativePath(userID)       [NSString stringWithFormat:@"/users/%@/apps", userID]
#define dRLAAPI_UserAuthApps_ResponseCode               200
// Install app under user
#define dRLAAPI_UserUnauthApp_RelativePath(userID, appID) [NSString stringWithFormat:@"/users/%@/apps/%@", userID, appID]
#define dRLAAPI_UserUnauthApp_ResponseCode              204
// User's publishers
#define dRLAAPI_UserPublishers_RelativePath(userID)     [NSString stringWithFormat:@"/users/%@/publishers", userID]
#define dRLAAPI_UserPublishers_ResponseCode             200
// User's transmitters
#define dRLAAPI_UserTransmitters_RelativePath(userID)   [NSString stringWithFormat:@"/users/%@/transmitters", userID]
#define dRLAAPI_UserTransmitters_ResponseCode           200
// User's devices
#define dRLAAPI_UserDevices_RelativePath(userID)        [NSString stringWithFormat:@"/users/%@/devices", userID]
#define dRLAAPI_UserDevices_ResponseCode                200
// User's devices (filtered by meaning)
#define dRLAAPI_UserDevicesFilter_RelativePath(userID, meaning) [NSString stringWithFormat:@"/users/%@/devices?meaning=%@", userID, meaning]
#define dRLAAPI_UserDevicesFilter_ResponseCode          200
// Register user's bookmark devices
#define dRLAAPI_UserBookDeviceNew_RelativePath(userID, devID)     [NSString stringWithFormat:@"/users/%@/devices/%@/bookmarks", userID, devID]
#define dRLAAPI_UserBookDeviceNew_ResponseCode          201
// User's bookmark devices
#define dRLAAPI_UserBookDevices_RelativePath(userID)    [NSString stringWithFormat:@"/users/%@/devices/bookmarks", userID]
#define dRLAAPI_UserBookDevices_ResponseCode            200
// Delete user's bookmark devices
#define dRLAAPI_UserBookDeviceDelete_RelativePath(userID, devID)  [NSString stringWithFormat:@"/users/%@/devices/%@/bookmarks", userID, devID]
#define dRLAAPI_UserBookDeviceDelete_ResponseCode       204
// HTTP Request body keys
#define dRLAAPI_User_RequestKey_ID                      @"id"
#define dRLAAPI_User_RequestKey_Name                    @"name"
// HTTP Respond body keys
#define dRLAAPI_User_RespondKey_ID                      @"id"
#define dRLAAPI_User_RespondKey_Name                    @"name"
#define dRLAAPI_User_RespondKey_Email                   @"email"

#pragma mark RLAAPIService+Publisher

// Publisher registration
#define dRLAAPI_PublisherRegistration_RelativePath      @"/publishers"
#define dRLAAPI_PublisherRegistration_ResponseCode      201
// All Publishers in the Cloud
#define dRLAAPI_PublishersCloud_RelativePath            @"/publishers"
#define dRLAAPI_PublishersCloud_ResponseCode            200
// Publisher info (get)
#define dRLAAPI_PublisherInfo_RelativePath(pubID)       [NSString stringWithFormat:@"/publishers/%@", pubID]
#define dRLAAPI_PublisherInfo_ResponseCode              200
// Publisher info (set)
#define dRLAAPI_PublisherSet_RelativePath(pubID)        [NSString stringWithFormat:@"/publishers/%@", pubID]
#define dRLAAPI_PublisherSet_ResponseCode               200
// Publisher apps (get)
#define dRLAAPI_PublisherApps_RelativePath(pubID)       [NSString stringWithFormat:@"/publishers/%@/apps", pubID]
#define dRLAAPI_PublisherApps_ResponseCode              200
// Publisher apps (get extended)
#define dRLAAPI_PublisherGetExtended_RelativePath(appID) [NSString stringWithFormat:@"/publishers/%@/apps/extended", appID]
#define dRLAAPI_PublisherGetExtended_ResponseCode       200
// Publisher deletion
#define dRLAAPI_PublisherDelete_RelativePath(pubID)     [NSString stringWithFormat:@"/publishers/%@", pubID]
#define dRLAAPI_PublisherDelete_ResponseCode            204
// HTTP Request body keys
#define dRLAAPI_Publisher_RequestKey_Name               @"name"
#define dRLAAPI_Publisher_RequestKey_Owner              @"owner"
// HTTP Respond body keys
#define dRLAAPI_Publisher_RespondKey_ID                 @"id"
#define dRLAAPI_Publisher_RespondKey_Name               @"name"
#define dRLAAPI_Publisher_RespondKey_Owner              @"owner"

#pragma mark RLAAPIService+Transmitter

// Transmitter registration
#define dRLAAPI_TransmitterRegistration_RelativePath    @"/transmitters"
#define dRLAAPI_TransmitterRegistration_ResponseCode    201
// Transmitter's info (get)
#define dRLAAPI_TransmitterInfo_RelativePath(tranID)    [NSString stringWithFormat:@"/transmitters/%@", tranID]
#define dRLAAPI_TransmitterInfo_ResponseCode            200
// Transmitter's info (set)
#define dRLAAPI_TransmitterInfoSet_RelativePath(tranID) [NSString stringWithFormat:@"/transmitters/%@", tranID]
#define dRLAAPI_TransmitterInfoSet_ResponseCode         200
// Transmitter's devices
#define dRLAAPI_TransmitterDevices_RelativePath(tranID) [NSString stringWithFormat:@"/transmitters/%@/devices", tranID]
#define dRLAAPI_TransmitterDevices_ResponseCode          200
// Create an association between a transmitter and a device
#define dRLAAPI_TransmitterConnectDevice_RelativePath(transID, devID)       [NSString stringWithFormat:@"/transmitter/%@/devices/%@", transID, devID]
#define dRLAAPI_TransmitterConnectDevice_ResponseCode                       200
// Delete an association between a transmitter and a device
#define dRLAAPI_TransmitterDisconnectDevice_RelativePath(transID, devID)    [NSString stringWithFormat:@"/transmitter/%@/devices/%@", transID, devID]
#define dRLAAPI_TransmitterDisconnectDevice_ResponseCode                    204
// Transmitter deletion
#define dRLAAPI_TransmitterDelete_RelativePath(transID) [NSString stringWithFormat:@"/transmitters/%@", transID]
#define dRLAAPI_TransmitterDelete_ResponseCode          204
// HTTP Request body keys
#define dRLAAPI_Transmitter_RequestKey_Name             @"name"
#define dRLAAPI_Transmitter_RequestKey_Owner            @"owner"
// HTTP Respond body keys
#define dRLAAPI_Transmitter_RespondKey_ID               @"id"
#define dRLAAPI_Transmitter_RespondKey_Name             @"name"
#define dRLAAPI_Transmitter_RespondKey_Secret           @"secret"
#define dRLAAPI_Transmitter_RespondKey_Owner            @"owner"

#pragma mark RLAAPIService+Device

// Device registration
#define dRLAAPI_DeviceRegister_RelativePath             @"/devices"
#define dRLAAPI_DeviceRegister_ResponseCode             201
// Device's info (get)
#define dRLAAPI_DeviceInfo_RelativePath(devID)          [NSString stringWithFormat:@"/devices/%@", devID]
#define dRLAAPI_DeviceInfo_ResponseCode                 200
// Device's info (set)
#define dRLAAPI_DeviceInfoSet_RelativePath(devID)       [NSString stringWithFormat:@"/devices/%@", devID]
#define dRLAAPI_DeviceInfoSet_ResponseCode              200
// Device removal
#define dRLAAPI_DeviceDelete_RelativePath(devID)        [NSString stringWithFormat:@"/devices/%@", devID]
#define dRLAAPI_DeviceDelete_ResponseCode               204
// Connect device to an app
#define dRLAAPI_DeviceConnect_RelativePath(devID, apID) [NSString stringWithFormat:@"/devices/%@/apps/%@", devID, apID]
#define dRLAAPI_DeviceConnect_ResponseCode              200
// Applications connect to device
#define dRLAAPI_DeviceApps_RelativePath(devID)          [NSString stringWithFormat:@"/devices/%@/apps", devID]
#define dRLAAPI_DeviceApps_ResponseCode                 200
// Disconnect device to an app
#define dRLAAPI_DeviceDisconnect_RelativePath(dID, aID) [NSString stringWithFormat:@"/devices/%@/apps/%@", dID, aID]
#define dRLAAPI_DeviceDisconnect_ResponseCode           204
// Sends a blob of data to a device
#define dRLAAPI_DeviceSend_RelativePath(devID, meaning) ((!meaning.length) ? [NSString stringWithFormat:@"/devices/%@/cmd", devID] : [NSString stringWithFormat:@"/devices/%@/cmd/%@", devID, meaning])
#define dRLAAPI_DeviceSend_ResponseCode                 200
// Device's that are public
#define dRLAAPI_DevicesPublic_RelativePath              @"/devices/public"
#define dRLAAPI_DevicesPublic_ResponseCode              200
// Devices that are public (filtered by meaning)
#define dRLAAPI_DevicesPublicMean_RelativePath(meaning) [NSString stringWithFormat:@"/devices/public?meaning=%@", meaning]
#define dRLAAPI_DevicesPublicMean_ResponseCode          200
// Subscribe to a public device (It doesn't need token)
#define dRLAAPI_DevicesPublicSub_RelativePath(devID)    [NSString stringWithFormat:@"/devices/%@/subscription", devID]
#define dRLAAPI_DevicesPublicSub_ResponseCode           200
// Device-model (all in Cloud)
#define dRLAAPI_DeviceModels_RelativePath               @"/device-models"
#define dRLAAPI_DeviceModels_ResponseCode               200
// Device-model (get)
#define dRLAAPI_DeviceModelGet_RelativePath(modelID)    [NSString stringWithFormat:@"/device-models/%@", modelID]
#define dRLAAPI_DeviceModelGet_ResponseCode             200
// Device-model's meaning (all devices in Cloud)
#define dRLAAPI_DeviceModelMean_RelativePath            @"/device-models/meanings"
#define dRLAAPI_DeviceModelMean_ResponseCode            200
// Device-model (firmwares)
#define dRLAAPI_DeviceModelFirmwares_RelativePath(mID)  [NSString stringWithFormat:@"/device-model/%@/firmware", mID]
#define dRLAAPI_DeviceModelFirmwares_RepsonseCode       200
// Device-model (specific firmware)
#define dRLAAPI_DeviceModelFirmwareVersion_RelativePath(modelID, firmwareVersion)    [NSString stringWithFormat:@"/device-model/%@/firmware/%@", modelID, firmwareVersion]
#define dRLAAPI_DeviceModelFirmwareVersion_ResponseCode 200
// HTTP Request body keys
#define dRLAAPI_Device_RequestKey_Name                  @"name"
#define dRLAAPI_Device_RequestKey_Owner                 @"owner"
#define dRLAAPI_Device_RequestKey_Model                 @"model"
#define dRLAAPI_Device_RequestKey_FirmwareVersion       @"firmwareVersion"
#define dRLAAPI_Device_RequestKey_Description           @"description"
#define dRLAAPI_Device_RequestKey_Public                @"public"
// HTTP Respond body keys
#define dRLAAPI_Device_RespondKey_ID                    @"id"
#define dRLAAPI_Device_RespondKey_Name                  @"name"
#define dRLAAPI_Device_RespondKey_Model                 @"model"
#define dRLAAPI_Device_RespondKey_Firmware              @"firmwareVersion"
#define dRLAAPI_Device_RespondKey_Secret                @"secret"
#define dRLAAPI_Device_RespondKey_Owner                 @"owner"
#define dRLAAPI_Device_RespondKey_Public                @"public"
// HTTP Respond body keys
#define dRLAAPI_DeviceModel_RespondKey_ID               @"id"
#define dRLAAPI_DeviceModel_RespondKey_Name             @"name"
#define dRLAAPI_DeviceModel_RespondKey_Manufacturer     @"manufacturer"
#define dRLAAPI_DeviceModel_RespondKey_Readings         @"readings"
#define dRLAAPI_DeviceModel_RespondKey_Firmware         @"firmwareVersions"
// HTTP Respond body keys
#define dRLAAPI_DeviceReading_RespondKey_Meaning        @"meaning"
#define dRLAAPI_DeviceReading_RespondKey_Unit           @"unit"
// HTTP Respond body keys
#define dRLAAPI_DeviceModel_RespondKey_Key              @"key"
#define dRLAAPI_DeviceModel_RespondKey_Value            @"value"
// HTTP Respond body keys
#define dRLAAPI_DeviceFirmware_RespondKey_Version       @"version"
#define dRLAAPI_DeviceFirmware_RespondKey_Configuration @"configuration"
#define dRLAAPI_DeviceFirmware_RespondKey_Schema        @"schema"
#define dRLAAPI_DeviceFirmware_RespondKey_DefaultValues @"defaultValues"

#pragma mark - JSON Schema

#define JSONSchema_Type_Array                           @"array"
#define JSONSchema_Type_Boolean                         @"boolean"
#define JSONSchema_Type_Integer                         @"integer"
#define JSONSchema_Type_Number                          @"number"
#define JSONSchema_Type_Null                            @"null"
#define JSONSchema_Type_Object                          @"object"
#define JSONSchema_Type_String                          @"string"

#define JSONSchema_Keyword_ID                           @"id"
#define JSONSchema_Keyword_Title                        @"title"
#define JSONSchema_Keyword_Description                  @"description"
#define JSONSchema_Keyword_Type                         @"type"
#define JSONSchema_Keyword_Properties                   @"properties"
