#import "RelayrApp.h"       // Header
#import "RelayrCloud.h"     // Relayr.framework (Public)
#import "RelayrUser.h"      // Relayr.framework (Public)
#import "RLAError.h"        // Relayr.framework (Utilities)
#import "RLALog.h"          // Relayr.framework (Utilities)
#import "RLAKeyChain.h"     // Relayr.framework (Utilities)

@implementation RelayrApp

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithID:(NSString*)appID OAuthClientID:(NSString*)clientID OAuthClientSecret:(NSString*)clientSecret redirectURI:(NSString*)redirectURI
{
    if (!appID || !clientID || !clientSecret || redirectURI) { [RLALog debug:RLAErrorMessageMissingArgument]; return nil; }
    
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
    if (!completion) { return [RLALog debug:RLAErrorMessageMissingArgument]; }
    
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

// TODO: Fill up
- (void)signUserStoringCredentialsIniCloud:(BOOL)sendCredentialsToiCloud completion:(void (^)(RelayrUser*, NSError*))completion
{
    
    
    
    
    
    
}

- (void)signOutUser:(RelayrUser*)user
{
    if (!user) { return; }
    
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
