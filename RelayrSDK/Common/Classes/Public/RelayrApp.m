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

- (void)isValid:(void (^)(NSError* error, BOOL isValid))completion
{
    if (!completion) { return [RLALog debug:dRLAErrorMessageMissingArgument]; }
    
    [RelayrCloud isApplicationID:_uid valid:completion];
}

// TODO: Fill up
- (void)queryCloudForAppInfo:(void (^)(NSError*, NSString*, NSString*, NSString*))completion
{
    
    
    
    
}

- (NSArray*)loggedUsers
{
    NSObject <NSCoding> * retrievedObj = [RLAKeyChain objectForKey:kRLAKeyChainUsers];
    if ( !retrievedObj || ![retrievedObj isKindOfClass:[NSArray class]] ) { return nil; }
    NSArray* users = (NSArray*)retrievedObj;
    
    return (users.count) ? users : nil;
}

- (void)signUserStoringCredentialsIniCloud:(BOOL)sendCredentialsToiCloud completion:(void (^)(NSError* error, RelayrUser* user))completion
{
    NSString* const clientID = _oauthClientID, *const clientSecret = _oauthClientSecret, *const redirectURI = _redirectURI;
    __weak RelayrApp* weakApp = self;
    
    [RLAWebService requestOAuthCodeWithOAuthClientID:clientID redirectURI:redirectURI completion:^(NSError* error, NSString* tmpCode) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        [RLAWebService requestOAuthTokenWithOAuthCode:tmpCode OAuthClientID:clientID OAuthClientSecret:clientSecret redirectURI:redirectURI completion:^(NSError *error, NSString *token) {
            if (error) { if (completion) { completion(error, nil); } return; }
            if (!token.length) { if (completion) { completion(RLAErrorMissingArgument, nil); } return; }
            
            NSArray* loggedUsers = weakApp.loggedUsers;
            
            // Look if a user with this token was already stored, and if so, return it.
            for (RelayrUser* user in loggedUsers)
            {
                if ([user.token isEqualToString:token])
                {
                    if (completion) { completion(nil, user); }
                    return;
                }
            }
            
            RelayrUser* user = [[RelayrUser alloc] initWithToken:token];
            if (!user) { if (completion) { completion(RLAErrorMissingExpectedValue,nil); } return; }
            
            NSMutableArray* endUsers = [NSMutableArray arrayWithArray:loggedUsers];
            [endUsers addObject:user];
            
            [RLAKeyChain setObject:[NSArray arrayWithArray:endUsers] forKey:kRLAKeyChainUsers];
            if (completion) { completion(nil, user); }
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
                [RLAKeyChain setObject:[NSArray arrayWithArray:users] forKey:kRLAKeyChainUsers];
            }
            else { [RLAKeyChain removeObjectForKey:kRLAKeyChainUsers]; }
            
            break;
        }
    }
}

@end
