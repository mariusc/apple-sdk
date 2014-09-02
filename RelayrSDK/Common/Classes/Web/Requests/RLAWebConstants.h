#pragma once

#pragma mark - RLAWebRequest

#define dRLAWebRequest_Timeout                          10
#define dRLAWebRequest_HeaderField_Authorization        @"Authorization"
#define dRLAWebRequest_HeaderValue_Authorization(token) [NSString stringWithFormat:@"Bearer %@", token]
#define dRLAWebRequest_HeaderField_ContentType          @"Content-Type"
#define dRLAWebRequest_HeaderValue_ContentType_UTF8     @"application/x-www-form-urlencoded; charset=utf-8"
#define dRLAWebRequest_HeaderValue_ContentType_JSON     @"application/json"
#define dRLAWebRequest_Respond_BadRequest               400

#pragma mark - RLAWebService

#define dRLAWebService_Host                             @"https://api.relayr.io"

// Relayr cloud reachability
#define dRLAWebService_Reachability_RelativePath        @"/device-models"
#define dRLAWebService_Reachability_Respond_StatusCode  200

// App info
#define dRLAWebService_AppInfo_RelativePath(appID)      [NSString stringWithFormat:@"/apps/%@", appID]
#define dRLAWebService_AppInfo_Respond_StatusCode       200
#define dRLAWebService_AppInfo_RespondKey_ID            @"id"
#define dRLAWebService_AppInfo_RespondKey_Name          @"name"
#define dRLAWebService_AppInfo_RespondKey_Description   @"description"

// OAuth token
#define dRLAWebService_OAuthToken_RelativePath          @"/oauth2/token"
#define dRLAWebService_OAuthToken_Body(code, redirectURI, clientID, clientSecret)   \
[NSString stringWithFormat:@"code=%@&redirect_uri=%@&client_id=%@&scope=&client_secret=%@&grant_type=authorization_code", code, [redirectURI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], clientID, clientSecret]
#define dRLAWebService_OAuthToken_Respond_StatusCode    200
#define dRLAWebService_OAuthToken_RespondKey_Token      @"access_token"

// User registration query
#define dRLAWebService_UserQuery_RelativePath(email)    [NSString stringWithFormat:@"/users/validate?email=%@", email]
#define dRLAWebService_UserQuery_Respond_StatusCode     200
#define dRLAWebService_UserQuery_RespondKey_Message     @"message"
#define dRLAWebService_UserQuery_RespondVal_ValidSubstr @"is already registered"

// User info
#define dRLAWebService_UserInfo_RelativePath            @"/oauth2/user-info"
#define dRLAWebService_UserInfo_Respond_StatusCode      200
#define dRLAWebService_UserInfo_RespondKey_ID           @"id"
#define dRLAWebService_UserInfo_RespondKey_Name         @"name"
#define dRLAWebService_UserInfo_RespondKey_Email        @"email"

// Publishers
#define dRLAWebService_Publishers_RelativePath(userID)  [NSString stringWithFormat:@"/users/%@/publishers", userID]
#define dRLAWebService_Publishers_Respond_StatusCode    200
#define dRLAWebService_Publishers_RespondKey_ID         @"id"
#define dRLAWebService_Publishers_RespondKey_Name       @"name"
#define dRLAWebService_Publishers_RespondKey_Owner      @"owner"

// Apps
#define dRLAWebService_Apps_RelativePath(userID)        [NSString stringWithFormat:@"/users/%@/apps", userID]
#define dRLAWebService_Apps_Respond_StatusCode          200
#define dRLAWebService_Apps_RespondKey_ID               @"id"
#define dRLAWebService_Apps_RespondKey_Name             @"name"
#define dRLAWebService_Apps_RespondKey_Owner            @"owner"
#define dRLAWebService_Apps_RespondKey_ConnectedDevices @"connectedDevices"

#pragma mark - RLAWebOAuthController

#define dRLAWebOAuthController_Timeout                  10
#define dRLAWebOAuthController_CodeRequestURL(clientID, redirectURI) \
        [NSString stringWithFormat:@"/oauth2/auth?client_id=%@&redirect_uri=%@&response_type=code&scope=access-own-user-info", clientID, redirectURI]

#define mark - RLAWebOAuthController

#define dRLAWebOAuthController_Title                    @"Relayr"
#define dRLAWebOAuthControllerIOS_Spinner_Animation     0.3
#define dRLAWebOAuthControllerOSX_WindowStyle           (NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask)
#define dRLAWebOAuthControllerOSX_WindowSize            NSMakeRect(0.0f, 0.0f, 1050.0f, 710.0f)
#define dRLAWebOAuthControllerOSX_WindowSizeMin         NSMakeSize(350.0f, 450.0f)
