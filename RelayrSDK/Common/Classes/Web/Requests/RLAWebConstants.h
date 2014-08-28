#pragma once

// OAuth temporal code
#define dRLARequestHost             @"https://api.relayr.io/"
#define dRLARequestOAuthCode1       @"oauth2/auth?client_id="
#define dRLARequestOAuthCode2       @"&redirect_uri="
#define dRLARequestOAuthCode3       @"&response_type=code&scope=access-own-user-info"

// OAuth token
#define dRLARequestOAuthToken_RelativePath              @"oauth2/token"
#define dRLARequestOAuthToken_HeaderKey_ClientID        @"client_id"
#define dRLARequestOAuthToken_HeaderKey_ClientSecret    @"client_secret"
#define dRLARequestOAuthToken_HeaderKey_GrantType       @"grant_type"
#define dRLARequestOAuthToken_HeaderVal_GrantType       @"authorization_code"
#define dRLARequestOAuthToken_HeaderKey_Code            @"code"
#define dRLARequestOAuthToken_HeaderKey_RedirectURI     @"redirect_uri"
#define dRLARequestOAuthToken_RespondKey_Code           200
#define dRLARequestOAuthToken_RespondKey_Token          @"access_token"

// User info
#define dRLARequestUserInfo_RelativePath        @"oauth2/user-info"
#define dRLARequestUserInfo_RespondKey_Code     200
#define dRLARequestUserInfo_RespondKey_Name     @"name"
#define dRLARequestUserInfo_RespondKey_Email    @"email"
