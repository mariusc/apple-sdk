#import "RelayrApp.h"           // Header
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)

#import "RelayrCloud.h"         // Relayr.framework (Public)
#import "RelayrUser.h"          // Relayr.framework (Public)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLAWebService.h"       // Relayr.framework (Web)
#import "RLAWebService+Cloud.h" // Relayr.framework (Web)
#import "RLAWebService+App.h"   // Relayr.framework (Web)

#import "RLAError.h"            // Relayr.framework (Utilities)
#import "RLALog.h"              // Relayr.framework (Utilities)
#import "RLAKeyChain.h"         // Relayr.framework (Utilities)

// KeyChain key
static NSString* const kRelayrAppStorageKey = @"RelayrApps";

// NSCoding variables
static NSString* const kCodingID = @"uid";
static NSString* const kCodingClientSecret = @"cse";
static NSString* const kCodingRedirectURI = @"uri";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingDescription = @"des";
static NSString* const kCodingPublisherID = @"pub";
static NSString* const kCodingUsers = @"usr";

@interface RelayrApp ()
@property (readwrite,nonatomic) NSString* oauthClientSecret;
@property (readwrite,nonatomic) NSMutableArray* users;
@end

@implementation RelayrApp

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithID:(NSString*)appID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI
{
    if (!appID.length || !clientSecret.length || !redirectURI.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _uid = appID;
        _oauthClientSecret = clientSecret;
        _redirectURI = redirectURI;
        _users = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithID:(NSString*)appID
{
    return [self initWithID:appID OAuthClientSecret:nil redirectURI:nil];
}

+ (void)appWithID:(NSString*)appID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI completion:(void (^)(NSError*, RelayrApp*))completion
{
    if (!completion) { return [RLALog debug:dRLAErrorMessageMissingArgument]; }
    if (appID.length==0) { return completion(RLAErrorMissingArgument, nil); }
    
    RelayrApp* result = [RelayrApp retrieveAppFromKeyChain:appID];
    if (result) { return completion(nil, result); }
    
    result = [[RelayrApp alloc] initWithID:appID OAuthClientSecret:clientSecret redirectURI:redirectURI];
    if (!result) { return completion(RLAErrorSigningFailure, nil); }
    
    [RLAWebService requestAppInfoFor:result.uid completion:^(NSError* error, NSString* appID, NSString* appName, NSString* appDescription) {
        if ( ![result.uid isEqualToString:appID] ) { return completion(RLAErrorWebrequestFailure, nil); }
        result.name = appName;
        result.appDescription = appDescription;
        completion(nil, result);
    }];
}

+ (BOOL)storeAppInKeyChain:(RelayrApp*)app
{
    if (!app.uid || !app.oauthClientSecret || !app.redirectURI) { [RLALog debug:dRLAErrorMessageMissingArgument]; return NO; }
    NSMutableArray* storedApps = [RelayrApp storedRelayrApps];
    
    if (storedApps.count)
    {
        NSNumber* appIndex = [RelayrApp indexForRelayrAppID:app.uid inRelayrAppsArray:storedApps];
        if (!appIndex) { [storedApps addObject:app]; }
        else { [storedApps replaceObjectAtIndex:appIndex.unsignedIntegerValue withObject:app]; }
    }
    else { storedApps = [NSMutableArray arrayWithObject:app]; }
    
    [RLAKeyChain setObject:storedApps forKey:kRelayrAppStorageKey];
    return YES;
}

+ (RelayrApp*)retrieveAppFromKeyChain:(NSString*)appID
{
    NSArray* currentlyStoredApps = [RelayrApp storedRelayrApps];
    NSNumber* appIndex = [RelayrApp indexForRelayrAppID:appID inRelayrAppsArray:currentlyStoredApps];
    return (appIndex) ? [currentlyStoredApps objectAtIndex:appIndex.unsignedIntegerValue] : nil;
}

+ (BOOL)removeAppFromKeyChain:(RelayrApp*)app
{
    if (!app.uid) { return NO; }
    
    NSMutableArray* storedApps = [RelayrApp storedRelayrApps];
    if (storedApps.count==0) { return YES; }
    
    NSNumber* appIndex = [RelayrApp indexForRelayrAppID:app.uid inRelayrAppsArray:storedApps];
    if (appIndex)
    {
        [storedApps removeObjectAtIndex:appIndex.unsignedIntegerValue];
        
        if (storedApps.count == 0) { [RLAKeyChain removeObjectForKey:kRelayrAppStorageKey]; }
        else { [RLAKeyChain setObject:storedApps forKey:kRelayrAppStorageKey]; }
    }
    return YES;
}

- (void)queryForAppInfoWithUserCredentials:(RelayrUser*)user completion:(void (^)(NSError*, NSString*, NSString*))completion
{
    if (!user) { if (completion) { completion(RLAErrorMissingArgument, nil, nil); } return; }
    
    __weak RelayrApp* weakSelf = self;
    [RLAWebService requestAppInfoFor:_uid completion:^(NSError* error, NSString* appID, NSString* appName, NSString* appDescription) {
        __strong RelayrApp* strongSelf = weakSelf;
        
        if ( ![strongSelf.uid isEqualToString:appID] ) { return completion(RLAErrorWebrequestFailure, nil, nil); }
        NSString* pName = strongSelf.name, * pDesc = strongSelf.description;
        strongSelf.name = appName; strongSelf.appDescription = appDescription;
        completion(nil, pName, pDesc);
    }];
}

- (NSArray*)loggedUsers
{
    return (_users.count>0) ? [NSMutableArray arrayWithArray:_users] : nil ;
}

- (RelayrUser*)loggedUserWithRelayrID:(NSString*)relayrID
{
    if (!relayrID || relayrID.length==0) { [RLALog debug:RLAErrorMissingArgument.localizedDescription]; return nil; }
    
    RelayrUser* result;
    NSArray* loggedUsers = self.loggedUsers;
    
    for (RelayrUser* user in loggedUsers)
    {
        if ( [user.uid isEqualToString:relayrID] ) { result=user; break; }
    }
    
    return result;
}

- (void)signInUser:(void (^)(NSError*, RelayrUser*))completion
{
    __weak RelayrApp* weakSelf = self;
    [RLAWebService requestOAuthCodeWithOAuthClientID:_uid redirectURI:_redirectURI completion:^(NSError* error, NSString* tmpCode) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        [RLAWebService requestOAuthTokenWithOAuthCode:tmpCode OAuthClientID:weakSelf.uid OAuthClientSecret:weakSelf.oauthClientSecret redirectURI:weakSelf.redirectURI completion:^(NSError* error, NSString* token) {
            if (error) { if (completion) { completion(error, nil); } return; }
            if (!token.length) { if (completion) { completion(RLAErrorMissingArgument, nil); } return; }
            
            RelayrUser* serverUser = [[RelayrUser alloc] initWithToken:token];
            if (!serverUser) { if (completion) { completion(RLAErrorMissingExpectedValue,nil); } return; }
            
            // If the user wasn't logged, retrieve the basic information.
            [serverUser queryCloudForUserInfo:^(NSError *error, NSString* previousName, NSString* previousEmail) {
                if (error) { if (completion) { completion(error, nil); } return; }
                
                __strong RelayrApp* strongSelf = weakSelf;
                // If the user was already logged, return that user.
                RelayrUser* localUser = [strongSelf loggedUserWithRelayrID:serverUser.uid];
                if (localUser)
                {
                    localUser.name = serverUser.name;
                    localUser.email = serverUser.email;
                    if (completion) { completion(nil, localUser); }
                    return;
                }
                else
                {
                    [strongSelf.users addObject:serverUser];
                    if (completion) { completion(nil, serverUser); }
                }
            }];
        }];
    }];
}

- (void)signOutUser:(RelayrUser*)user
{
    NSString* userToken = user.token;
    if (userToken.length == 0) { return; }
    
    NSUInteger const userCount = _users.count;
    for (NSUInteger i=0; i<userCount; ++i)
    {
        RelayrUser* tmpUser = _users[i];
        if ( [userToken isEqualToString:tmpUser.token] ) { return [_users removeObjectAtIndex:i]; }
    }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithID:[decoder decodeObjectForKey:kCodingID] OAuthClientSecret:[decoder decodeObjectForKey:kCodingClientSecret] redirectURI:[decoder decodeObjectForKey:kCodingRedirectURI]];
    if (self)
    {
        _name = [decoder decodeObjectForKey:kCodingName];
        _appDescription = [decoder decodeObjectForKey:kCodingDescription];
        _publisherID = [decoder decodeObjectForKey:kCodingPublisherID];
        _users = [decoder decodeObjectForKey:kCodingUsers];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_oauthClientSecret forKey:kCodingClientSecret];
    [coder encodeObject:_redirectURI forKey:kCodingRedirectURI];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_appDescription forKey:kCodingDescription];
    [coder encodeObject:_publisherID forKey:kCodingPublisherID];
    [coder encodeObject:_users forKey:kCodingUsers];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrApp\n{\n\t ID:\t%@\n\t Name:\t%@\n\t Description: %@\n}\n", _uid, _name, _appDescription];
}

#pragma mark - Private methods

/*******************************************************************************
 * It retrieves all currently stored Relayr Apps.
 * If there are none, it returns <code>nil</code>.
 ******************************************************************************/
+ (NSMutableArray*)storedRelayrApps
{
    NSObject<NSCoding> * obj = [RLAKeyChain objectForKey:kRelayrAppStorageKey];
    return ([obj isKindOfClass:[NSMutableArray class]] && ((NSMutableArray*)obj).count!=0) ? (NSMutableArray*)obj : nil;
}

/*******************************************************************************
 * It returns the index of the Relayr Application with the specified ID (or <code>nil</code>), within an array of RelayrApp objects.
 ******************************************************************************/
+ (NSNumber*)indexForRelayrAppID:(NSString*)appID inRelayrAppsArray:(NSArray*)apps
{
    if (apps.count==0 || appID.length==0) { return nil; }
    
    __block NSNumber* result = nil;
    [apps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if ( [obj isKindOfClass:[RelayrApp class]] && [((RelayrApp*)obj).uid isEqualToString:appID] )
        {
            result = [NSNumber numberWithUnsignedInteger:idx];
            *stop = YES;
        }
    }];
    return result;
}

@end
