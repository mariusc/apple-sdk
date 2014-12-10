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
#import "RLALog.h"                  // Relayr.framework (Utilities)

#define RelayrApp_FSFolder  @"/io.relayr.sdk"

// NSCoding variables
static NSString* const kCodingID = @"uid";
static NSString* const kCodingClientSecret = @"cse";
static NSString* const kCodingRedirectURI = @"uri";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingDescription = @"des";
static NSString* const kCodingPublisherID = @"pub";
static NSString* const kCodingUsers = @"usr";

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
        _users = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithID:(NSString*)appID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI
{
    if (!clientSecret.length || !redirectURI.length) { return nil; }
    
    self = [self initWithID:appID];
    if (self)
    {
        _oauthClientSecret = clientSecret;
        _redirectURI = redirectURI;
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
        [strongSelf setWith:app];
        completion(nil, pName, pDesc);
    }];
}

#pragma mark Lifecycle

+ (void)appWithID:(NSString*)appID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI completion:(void (^)(NSError*, RelayrApp*))completion
{
    if (!completion) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    if (appID.length==0) { return completion(RelayrErrorMissingArgument, nil); }
    
    RelayrApp* result = [[RelayrApp alloc] initWithID:appID OAuthClientSecret:clientSecret redirectURI:redirectURI];
    if (!result) { return completion(RelayrErrorMissingArgument, nil); }
    
    [RLAAPIService requestAppInfoFor:result.uid completion:^(NSError* error, NSString* appID, NSString* appName, NSString* appDescription) {
        if ( ![result.uid isEqualToString:appID] ) { return completion(RelayrErrorWebRequestFailure, nil); }
        result.name = appName;
        result.appDescription = appDescription;
        completion(nil, result);
    }];
}

+ (BOOL)persistAppInFileSystem:(RelayrApp*)app
{
    if (!app.uid.length) { return NO; }
    
    NSData* appData = [NSKeyedArchiver archivedDataWithRootObject:app];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (!appData || !manager) { return NO; }
    
    NSString* folderPath = [RelayrApp absoluteRelayrAppFolderPath];
    if ( ![manager fileExistsAtPath:folderPath] )
    {
        NSError* error;
        BOOL operationStatus = [manager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!operationStatus || error) { return NO; }
    }
    
    NSString* path = [folderPath stringByAppendingPathComponent:app.uid];
    return [manager createFileAtPath:path contents:appData attributes:nil];
}

+ (RelayrApp*)retrieveAppWithIDFromFileSystem:(NSString*)appID
{
    if (!appID.length) { return nil; }
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[RelayrApp absoluteRelayrAppFolderPath] stringByAppendingPathComponent:appID]];
}

+ (BOOL)removeAppFromFileSystem:(RelayrApp*)app
{
    if (!app.uid.length) { return NO; }
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSString* path = [RelayrApp absoluteRelayrAppFolderPath];
    if (![manager fileExistsAtPath:path]) { return YES; }
    
    return [manager removeItemAtPath:path error:nil];
}

#pragma mark Users

- (NSArray*)loggedUsers
{
    return (_users.count) ? _users : nil;
}

- (RelayrUser*)loggedUserWithRelayrID:(NSString*)relayrID
{
    if (!relayrID.length) { [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; return nil; }
    
    RelayrUser* result;
    for (RelayrUser* user in _users)
    {
        if ( [user.uid isEqualToString:relayrID] ) { result=user; break; }
    }
    return result;
}

- (void)signInUser:(void (^)(NSError*, RelayrUser*))completion
{
    if (!_uid.length || !_redirectURI.length || !_oauthClientSecret.length) { if (completion) { completion(RelayrErrorMissingExpectedValue, nil); } return; }
    
    [RLAAPIService requestOAuthCodeWithOAuthClientID:_uid redirectURI:_redirectURI completion:^(NSError* error, NSString* tmpCode) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        [RLAAPIService requestOAuthTokenWithOAuthCode:tmpCode OAuthClientID:_uid OAuthClientSecret:_oauthClientSecret redirectURI:_redirectURI completion:^(NSError* error, NSString* token) {
            if (error) { if (completion) { completion(error, nil); } return; }
            if (!token.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
            
            RelayrUser* serverUser = [[RelayrUser alloc] initWithToken:token];
            if (!serverUser) { if (completion) { completion(RelayrErrorMissingExpectedValue,nil); } return; }
            serverUser.app = self;
            
            // If the user wasn't logged, retrieve the basic information.
            [serverUser queryCloudForUserInfo:^(NSError* error, NSString* previousName, NSString* previousEmail) {
                if (error) { if (completion) { completion(error, nil); } return; }

                RelayrUser* user = [self loggedUserWithRelayrID:serverUser.uid];
                if (user)
                {
                    user.app = serverUser.app;
                    user.name = serverUser.name;
                    user.email = serverUser.email;
                }
                else
                {
                    user = serverUser;
                    [_users addObject:serverUser];
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
        
        NSArray* tmp = [decoder decodeObjectForKey:kCodingUsers];
        if (tmp) { [_users addObjectsFromArray:tmp]; }
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
    if (_users.count) { [coder encodeObject:[NSArray arrayWithArray:_users] forKey:kCodingUsers]; }
}

#pragma mark NSCopying & NSMutableCopying

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
    return self;
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"RelayrApp\n{\n\t ID:\t%@\n\t Name:\t%@\n\t Description: %@\n\t Num logged users: %@\n}\n", _uid, _name, _appDescription, @(_users.count)];
}

#pragma mark - Private functionality

+ (NSString*)absoluteRelayrAppFolderPath
{
    static NSString* folderPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        folderPath = [(NSString*)paths.firstObject stringByAppendingPathComponent:RelayrApp_FSFolder];
    });
    return folderPath;
}

@end
