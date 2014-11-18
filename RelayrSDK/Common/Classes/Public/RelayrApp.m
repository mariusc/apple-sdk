#import "RelayrApp.h"               // Header

#import "RelayrCloud.h"             // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrErrors.h"            // Relayr.framework (Public)
#import "RelayrApp_Setup.h"         // Relayr.framework (Private)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RLAAPIService.h"           // Relayr.framework (Service/API)
#import "RLAAPIService+Cloud.h"     // Relayr.framework (Service/API)
#import "RLAAPIService+App.h"       // Relayr.framework (Service/API)
#import "RLAKeyChain.h"             // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)

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
@property (readonly,nonatomic) NSMutableArray* users;
@end

@implementation RelayrApp

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithID:(NSString*)appID
{
    if (!appID.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _uid = appID;
    }
    return self;
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

- (void)setName:(NSString*)name withUserCredentials:(RelayrUser*)user completion:(void (^)(NSError* error, NSString* previousName))completion
{
    if (!name.length || !user.apiService) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    __weak RelayrApp* weakApp = self;
    [user.apiService setApp:self.uid name:name description:nil redirectURI:nil completion:^(NSError* error, RelayrApp* app) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        __strong RelayrApp* strongApp = weakApp;
        NSString* pName = strongApp.name;
        strongApp.name = app.name;
        if (completion) { completion(nil, pName); }
    }];
}

- (void)setDescription:(NSString*)description withUserCredentials:(RelayrUser*)user completion:(void (^)(NSError* error, NSString* previousDescription))completion
{
    if (!user.apiService) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    __weak RelayrApp* weakApp = self;
    [user.apiService setApp:self.uid name:nil description:description redirectURI:nil completion:^(NSError* error, RelayrApp* app) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        __strong RelayrApp* strongApp = weakApp;
        NSString* pDescription = strongApp.appDescription;
        strongApp.appDescription = app.description;
        if (completion) { completion(nil, pDescription); }
    }];
}

- (void)queryForAppInfoWithUserCredentials:(RelayrUser*)user completion:(void (^)(NSError*, NSString*, NSString*))completion
{
    if (!user.apiService) { if (completion) { completion(RelayrErrorMissingArgument, nil, nil); } return; }
    
    __weak RelayrApp* weakSelf = self;
    [user.apiService requestAppInfoExtendedFor:_uid completion:^(NSError* error, RelayrApp* app) {
        if (error) { if (completion) { completion(error, nil, nil); } return; }
        
        __strong RelayrApp* strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        NSString* pName = strongSelf.name, * pDesc = strongSelf.description;
        [self setWith:app];
        completion(nil, pName, pDesc);
    }];
}

#pragma mark Lifecycle

+ (void)appWithID:(NSString*)appID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI completion:(void (^)(NSError*, RelayrApp*))completion
{
    if (!completion) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    if (appID.length==0) { return completion(RelayrErrorMissingArgument, nil); }
    
    RelayrApp* result = [RelayrApp retrieveAppFromKeyChain:appID];
    if (result) { return completion(nil, result); }
    
    result = [[RelayrApp alloc] initWithID:appID OAuthClientSecret:clientSecret redirectURI:redirectURI];
    if (!result) { return completion(RelayrErrorMissingArgument, nil); }
    
    [RLAAPIService requestAppInfoFor:result.uid completion:^(NSError* error, NSString* appID, NSString* appName, NSString* appDescription) {
        if ( ![result.uid isEqualToString:appID] ) { return completion(RelayrErrorWebRequestFailure, nil); }
        result.name = appName;
        result.appDescription = appDescription;
        completion(nil, result);
    }];
}

+ (BOOL)storeAppInKeyChain:(RelayrApp*)app
{
    if (!app.uid || !app.oauthClientSecret || !app.redirectURI) { [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; return NO; }
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

#pragma mark Users

- (NSArray*)loggedUsers
{
    return (_users.count>0) ? [NSMutableArray arrayWithArray:_users] : nil ;
}

- (RelayrUser*)loggedUserWithRelayrID:(NSString*)relayrID
{
    if (!relayrID || relayrID.length==0) { [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; return nil; }
    
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
    if (!_uid.length || !_redirectURI.length || !_oauthClientSecret.length) { if (completion) { completion(RelayrErrorMissingExpectedValue, nil); } return; }
    
    __weak RelayrApp* weakSelf = self;
    [RLAAPIService requestOAuthCodeWithOAuthClientID:_uid redirectURI:_redirectURI completion:^(NSError* error, NSString* tmpCode) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        [RLAAPIService requestOAuthTokenWithOAuthCode:tmpCode OAuthClientID:weakSelf.uid OAuthClientSecret:weakSelf.oauthClientSecret redirectURI:weakSelf.redirectURI completion:^(NSError* error, NSString* token) {
            if (error) { if (completion) { completion(error, nil); } return; }
            if (!token.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
            
            RelayrUser* serverUser = [[RelayrUser alloc] initWithToken:token];
            if (!serverUser) { if (completion) { completion(RelayrErrorMissingExpectedValue,nil); } return; }
            serverUser.app = self;
            
            // If the user wasn't logged, retrieve the basic information.
            [serverUser queryCloudForUserInfo:^(NSError* error, NSString* previousName, NSString* previousEmail) {
                if (error) { if (completion) { completion(error, nil); } return; }
                
                __strong RelayrApp* strongSelf = weakSelf;  // If the user was already logged, return that user.
                RelayrUser* user = [strongSelf loggedUserWithRelayrID:serverUser.uid];
                if (user)
                {
                    user.app = serverUser.app;
                    user.name = serverUser.name;
                    user.email = serverUser.email;
                }
                else
                {
                    user = serverUser;
                    [strongSelf.users addObject:user];
                }
                
                if (completion) { completion(nil, user); }
            }];
        }];
    }];
}

- (void)signOutUser:(RelayrUser*)user
{
    NSString* userID = user.uid;
    if (userID.length == 0) { return; }
    
    NSUInteger const userCount = _users.count;
    for (NSUInteger i=0; i<userCount; ++i)
    {
        if ( [userID isEqualToString:((RelayrUser*)_users[i]).uid] ) { return [_users removeObjectAtIndex:i]; }
    }
}

- (void)setWith:(RelayrApp*)app
{
    if (![_uid isEqualToString:app.uid]) { return; }
    
    if (app.name) { _name = app.name; }
    if (app.appDescription) { _appDescription = app.appDescription; }
    if (app.oauthClientSecret) { _oauthClientSecret = app.oauthClientSecret; }
    if (app.redirectURI) { _redirectURI = app.redirectURI; }
    if (app.publisherID) { _publisherID = app.publisherID; }
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
        [_users addObjectsFromArray:[decoder decodeObjectForKey:kCodingUsers]];
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

/*!
 *  @abstract It retrieves all currently stored Relayr Apps.
 *  @discussion If there are none, it returns <code>nil</code>.
 */
+ (NSMutableArray*)storedRelayrApps
{
    NSObject<NSCoding> * obj = [RLAKeyChain objectForKey:kRelayrAppStorageKey];
    return ([obj isKindOfClass:[NSMutableArray class]] && ((NSMutableArray*)obj).count>0) ? (NSMutableArray*)obj : nil;
}

/*!
 *  @abstract It returns the index of the Relayr Application with the specified ID (or <code>nil</code>), within an array of RelayrApp objects.
 */
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
