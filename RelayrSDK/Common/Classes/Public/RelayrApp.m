#import "RelayrApp.h"       // Header

#import "RelayrCloud.h"     // Relayr.framework (Public)
#import "RelayrUser.h"      // Relayr.framework (Public)
#import "RelayrUser_Setup.h"// Relayr.framework (Private)
#import "RLAWebService.h"   // Relayr.framework (Web)
#import "RLAError.h"        // Relayr.framework (Utilities)
#import "RLALog.h"          // Relayr.framework (Utilities)
#import "RLAKeyChain.h"     // Relayr.framework (Utilities)

@interface RelayrApp ()
@property (readwrite,nonatomic) NSString* oauthClientID;
@property (readwrite,nonatomic) NSString* oauthClientSecret;
@property (readwrite,nonatomic) NSString* redirectURI;
@property (readwrite,nonatomic) NSString* name;
@property (readwrite,nonatomic) NSString* appDescription;
@property (readwrite,nonatomic) NSString* publisherID;
@end

@implementation RelayrApp

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithID:(NSString*)appID OAuthClientID:(NSString*)clientID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI
{
    if (!appID || !clientID || !clientSecret || !redirectURI) { [RLALog debug:dRLAErrorMessageMissingArgument]; return nil; }
    
    self = [super init];
    if (self)
    {
        _uid = appID;
        _oauthClientID = clientID;
        _oauthClientSecret = clientSecret;
        _redirectURI = redirectURI;
    }
    return self;
}

// TODO: Fill up
- (void)queryCloudForAppInfo:(void (^)(NSError*, NSString*, NSString*, NSString*))completion
{
    
    
    
    
}

- (NSArray*)loggedUsers
{
    NSObject <NSCoding> * retrievedObj = [RLAKeyChain objectForKey:kRLAKeyChainKeyUser];
    if ( !retrievedObj || ![retrievedObj isKindOfClass:[NSArray class]] ) { return nil; }
    NSArray* users = (NSArray*)retrievedObj;
    
    return (users.count) ? users : nil;
}

- (void)signUserStoringCredentialsIniCloud:(BOOL)sendCredentialsToiCloud completion:(void (^)(NSError*, RelayrUser*))completion
{
    [RLAWebService requestOAuthCodeWithOAuthClientID:self.oauthClientID redirectURI:self.redirectURI completion:^(NSError* error, NSString* tmpCode) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        [RLAWebService requestOAuthTokenWithOAuthCode:tmpCode OAuthClientID:self.oauthClientID OAuthClientSecret:self.oauthClientSecret redirectURI:self.redirectURI completion:^(NSError *error, NSString *token) {
            if (error) { if (completion) { completion(error, nil); } return; }
            if (!token.length) { if (completion) { completion(RLAErrorMissingArgument, nil); } return; }
            
            RelayrUser* serverUser = [[RelayrUser alloc] initWithToken:token];
            if (!serverUser) { if (completion) { completion(RLAErrorMissingExpectedValue,nil); } return; }
            
            // If the user wasn't logged, retrieve the basic information.
            [serverUser queryCloudForUserInfo:^(NSError *error, NSString* previousName, NSString* previousEmail) {
                if (error) { if (completion) { completion(error, nil); } return; }
                
                // If the user was already logged, return that user.
                RelayrUser* localUser = [self loggedUserWithRelayrID:serverUser.uid];
                if (localUser) { if (completion) { completion(nil, localUser); } return; }
                
                // If not, add it to the keyChain
                [self addUserToICloud:serverUser];
                if (completion) { completion(nil, serverUser); }
            }];
        }];
    }];
}

- (void)signOutUser:(RelayrUser*)user
{
    NSString* userToken = user.token;
    NSArray* storedUsers = self.loggedUsers;
    
    NSUInteger const userCount = storedUsers.count;
    for (NSUInteger i=0; i<userCount; ++i)
    {
        RelayrUser* tmpUser = storedUsers[i];
        if ( [userToken isEqualToString:tmpUser.token] )
        {
            if (userCount > 1)
            {
                NSMutableArray* users = [NSMutableArray arrayWithArray:self.loggedUsers];
                [users removeObjectAtIndex:i];
                [RLAKeyChain setObject:[NSArray arrayWithArray:users] forKey:kRLAKeyChainKeyUser];
            }
            else
            {
                [RLAKeyChain removeObjectForKey:kRLAKeyChainKeyUser];
            }
            break;
        }
    }
}

- (RelayrUser*)loggedUserWithRelayrID:(NSString*)relayrID
{
    if (!relayrID || relayrID.length==0) { [RLALog debug:RLAErrorMissingArgument.localizedDescription]; return nil; }

    RelayrUser* result;
    NSArray* loggedUsers = self.loggedUsers;
    
    for (RelayrUser* user in loggedUsers)
    {
        if (user.uid == relayrID) { result=user; break; }
    }
    
    return result;
}

#pragma mark - Private methods

/*******************************************************************************
 * It adds a user to the logged Relayr User shared with iCloud.
 ******************************************************************************/
- (void)addUserToICloud:(RelayrUser*)user
{
    NSString* uid = user.uid;
    if (!uid) { return; }
    
    NSMutableArray* iCloudUsers = [NSMutableArray arrayWithArray:self.loggedUsers];
    
    for (RelayrUser* loggedUser in iCloudUsers)
    {
        if ([loggedUser.uid isEqualToString:uid]) { return; }
    }
    
    [iCloudUsers addObject:user];
    [RLAKeyChain setObject:[NSArray arrayWithArray:iCloudUsers] forKey:kRLAKeyChainKeyUser];
}

@end
