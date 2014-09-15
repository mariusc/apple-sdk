#pragma once

#pragma mark - RLAWebRequest

#define dRLAWebRequest_Timeout                          10
#define dRLAWebRequest_HeaderField_Authorization        @"Authorization"
#define dRLAWebRequest_HeaderValue_Authorization(token) [NSString stringWithFormat:@"Bearer %@", token]
#define dRLAWebRequest_HeaderField_ContentType          @"Content-Type"
#define dRLAWebRequest_HeaderValue_ContentType_UTF8     @"application/x-www-form-urlencoded; charset=utf-8"
#define dRLAWebRequest_HeaderValue_ContentType_JSON     @"application/json"
#define dRLAWebRequest_HeaderField_UserAgent            @"User-Agent"
#define dRLAWebRequest_Respond_BadRequest               400

#pragma mark - RLAWebService

#define Web_Host                            @"https://api.relayr.io"

// Relayr Applications
#define Web_RespondKey_AppID                @"id"
#define Web_RespondKey_AppName              @"name"
#define Web_RespondKey_AppDescription       @"description"
#define Web_RespondKey_AppOwner             @"owner"
#define Web_RespondKey_AppOAuthClientSecret @"clientSecret"
#define Web_RespondKey_AppConnectedDevices  @"connectedDevices"

// Relayr Users
#define Web_RespondKey_UserID               @"id"
#define Web_RespondKey_UserName             @"name"
#define Web_RespondKey_UserEmail            @"email"

// Relayr Publishers
#define Web_RespondKey_PublisherID          @"id"
#define Web_RespondKey_PublisherName        @"name"
#define Web_RespondKey_PublisherOwner       @"owner"

// Relayr Transmitters
#define Web_RespondKey_TransmitterID        @"id"
#define Web_RespondKey_TransmitterName      @"name"
#define Web_RespondKey_TransmitterSecret    @"secret"
#define Web_RespondKey_TransmitterOwner     @"owner"

// Relayr Devices
#define Web_RespondKey_DeviceID             @"id"
#define Web_RespondKey_DeviceName           @"name"
#define Web_RespondKey_DeviceModel          @"model"
#define Web_RespondKey_DeviceFirmware       @"firmwareVersion"
#define Web_RespondKey_DeviceSecret         @"secret"
#define Web_RespondKey_DeviceOwner          @"owner"
#define Web_RespondKey_DevicePublic         @"public"

// Relayr Device Models
#define Web_RespondKey_ModelID              @"id"
#define Web_RespondKey_ModelName            @"name"
#define Web_RespondKey_ModelManufacturer    @"manufacturer"
#define Web_RespondKey_ModelReadings        @"readings"

// Relayr Device Model Readings
#define Web_RespondKey_ReadingsMeaning      @"meaning"
#define Web_RespondKey_ReadingsUnit         @"unit"

#pragma mark RLAWebService+Cloud

// isReachable
#define Web_RequestRelativePath_Reachability            @"/device-models"
#define Web_RequestResponseCode_Reachability            200

// OAuth temporal code
#define dRLAWebOAuthController_Timeout                  10
#define dRLAWebOAuthController_CodeRequestURL(clientID, redirectURI) \
[NSString stringWithFormat:@"/oauth2/auth?client_id=%@&redirect_uri=%@&response_type=code&scope=access-own-user-info", clientID, redirectURI]

#define dRLAWebOAuthController_Title                    @"Relayr"
#define dRLAWebOAuthControllerIOS_Spinner_Animation     0.3
#define dRLAWebOAuthControllerOSX_WindowStyle           (NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask)
#define dRLAWebOAuthControllerOSX_WindowSize            NSMakeRect(0.0f, 0.0f, 1050.0f, 710.0f)
#define dRLAWebOAuthControllerOSX_WindowSizeMin         NSMakeSize(350.0f, 450.0f)

// OAuth token
#define Web_RequestRelativePath_OAuthToken              @"/oauth2/token"
#define Web_RequestBody_OAuthToken(code, redirectURI, clientID, clientSecret) \
    [NSString stringWithFormat:@"code=%@&redirect_uri=%@&client_id=%@&scope=&client_secret=%@&grant_type=authorization_code", code, [redirectURI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], clientID, clientSecret]
#define Web_RequestResponseCode_OAuthToken              200
#define Web_RequestResponseKey_OAuthToken_AccessToken   @"access_token"

#pragma mark RLAWebService+App

// All Relayr's apps
#define Web_RequestRelativePath_Apps                    @"/apps"
#define Web_RequestResponseCode_Apps                    200

// App registration
#define Web_RequestRelativePath_AppRegistration         @"/apps"
#define Web_RequestResponseCode_Apps                    200

// App info
#define Web_RequestRelativePath_AppInfo(appID)          [NSString stringWithFormat:@"/apps/%@", appID]
#define Web_RequestResponseCode_AppInfo                 200

// App info (extended)
#define Web_RequestRelativePath_AppInfoExtended(appID)  [NSString stringWithFormat:@"/apps/%@/extended", appID]
#define Web_RequestResponseCode_AppInfoExtended         200

// App info (set)
#define Web_RequestRelativePath_AppInfoSet(appID)       [NSString stringWithFormat:@"/apps/%@", appID]
#define Web_RequestResponseCode_AppInfoSet              200

// App deletion
#define Web_RequestRelativePath_AppDeletion(appID)      [NSString stringWithFormat:@"/apps/%@", appID]
#define Web_RequestResponseCode_AppDeletion             204

#define Web_RequestBodyKey_AppName                      @"name"
#define Web_RequestBodyKey_AppPublisher                 @"publisher"
#define Web_RequestBodyKey_AppDescription               @"description"
#define Web_RequestBodyKey_AppRedirectURI               @"redirectUri"

#pragma mark RLAWebService+User

// Email check
#define Web_RequestRelativePath_EmailCheck(email)       [NSString stringWithFormat:@"/users/validate?email=%@", email]
#define Web_RequestResponseCode_EmailCheck              200
#define Web_RequestResponseKey_EmailCheck_Exists        @"exists"
#define Web_RequestResponseVal_EmailCheck_Exists        @"true"

// User's info (get)
#define Web_RequestRelativePath_UserInfo                @"/oauth2/user-info"
#define Web_RequestResponseCode_UserInfo                200

// User's info (set)
#define Web_RequestRelativePath_UserInfoSet(userID)     [NSString stringWithFormat:@"/users/%@", userID]
#define Web_RequestResponseCode_UserInfoSet             200

// User's apps
#define Web_RequestRelativePath_UserInstalledApps(userID)   [NSString stringWithFormat:@"}/users/%@/apps", userID]
#define Web_RequestResponseCode_UserInstalledApps       200

// User's publishers
#define Web_RequestRelativePath_UserPubs(userID)        [NSString stringWithFormat:@"/users/%@/publishers", userID]
#define Web_RequestResponseCode_UserPubs                200

// User's transmitters
#define Web_RequestRelativePath_UserTrans(userID)       [NSString stringWithFormat:@"/users/%@/transmitters", userID];
#define Web_RequestResponseCode_UserTrans               200

// User's devices
#define Web_RequestRelativePath_UserDevices(userID)     [NSString stringWithFormat:@"/users/%@/devices", userID];
#define Web_RequestResponseCode_UserDevices             200

// User's bookmark devices
#define Web_RequestRelativePath_UserBookmarkDevices(userID) [NSString stringWithFormat:@"/users/%@/devices/bookmarks", userID];
#define Web_RequestResponseCode_UserBookmarkDevices     200

#pragma mark RLAWebService+Publisher

#define Web_RequestRelativePath_PublisherRegistration   @"/publishers"
#define Web_RequestResponseCode_PublisherRegistration   200

#define Web_RequestRelativePath_Publishers              @"/publishers"
#define Web_RequestResponseCode_Publishers              200

#define Web_RequestRelativePath_PublisherSet(pubID)     [NSString stringWithFormat:@"/publishers/%@", pubID]
#define Web_RequestResponseCode_PublisherSet            200

#define Web_RequestBodyKey_PublisherName                @"name"
#define Web_RequestBodyKey_PublisherOwner               @"owner"

#pragma mark RLAWebService+Transmitter

#define Web_RequestRelativePath_TransRegistration       @"/transmitters"
#define Web_RequestResponseCode_TransRegistration       200

#define Web_RequestRelativePath_TransInfo(transID)      [NSString stringWithFormat:@"/transmitters/%@", transID];
#define Web_RequestResponseCode_TransInfo               200

#define Web_RequestRelativePath_TransInfoSet(transID)   [NSString stringWithFormat:@"/transmitters/%@", transID];
#define Web_RequestResponseCode_TransInfoSet            200

#define Web_RequestRelativePath_TransConnectionDev(transID, devID)  [NSString stringWithFormat:@"/transmitter/%@/device/%@", transID, devID];
#define Web_RequestResponseCode_TransConnectionDev      200

#define Web_RequestRelativePath_TransDevices(transID)   [NSString stringWithFormat:@"/transmitters/%@/devices", transID];
#define Web_RequestResponseCode_TransDevices            200

#define Web_RequestBodyKey_TransName                    @"name"
#define Web_RequestBodyKey_TransOwner                   @"owner"

#pragma mark RLAWebService+Device




