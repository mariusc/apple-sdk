@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "TestConstants.h"       // Tests
#import "RelayrApp_TSetup.h"    // Tests

/*!
 *  @abstract Test the high-level methods of <code>RelayrApp</code> objects.
 *
 *  @see RelayrApp
 */
@interface TRelayrApp : XCTestCase
@property (readonly,nonatomic) RelayrApp* app;
@property (readonly,nonatomic) RelayrUser* user;
@end

@implementation TRelayrApp

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    
    _app = [[RelayrApp alloc] initWithID:kTestsAppID OAuthClientSecret:kTestsAppSecret redirectURI:kTestsAppRedirect];
    _user = [[RelayrUser alloc] initWithToken:kTestsUserToken];
    _user.uid = kTestsUserID;
    _user.name = kTestsUserName;
    _user.email = kTestsUserEmail;
    [_app.users addObject:_user];
}

- (void)tearDown {
    [RelayrApp removeAppFromKeyChain:_app];
    [_app signOutUser:_user];
    _user = nil;
    _app = nil;
    [super tearDown];
}

#pragma mark - Unit tests

- (void)test_queryForAppInfo
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_app queryForAppInfoWithUserCredentials:_user completion:^(NSError* error, NSString* previousName, NSString* previousDescription) {
        XCTAssertNil(error);
        XCTAssertNotNil(_app.name);
        XCTAssertNotNil(_app.appDescription);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)test_loggedUsers
{
    RelayrApp* tmpApp = [[RelayrApp alloc] initWithID:kTestsAppID OAuthClientSecret:kTestsAppSecret redirectURI:kTestsAppRedirect];
    XCTAssertNil(tmpApp.loggedUsers);
    
    RelayrUser* tmpUser = [[RelayrUser alloc] initWithToken:kTestsUserToken];
    [tmpApp.users addObject:tmpUser];
    XCTAssertGreaterThanOrEqual(tmpApp.loggedUsers.count, 1);
    
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [tmpUser queryCloudForUserInfo:^(NSError* error, NSString* previousName, NSString* previousEmail) {
        XCTAssertNil(error);
        XCTAssertNotNil(tmpUser.uid);
        XCTAssertNotNil(tmpUser.name);
        XCTAssertNotNil(tmpUser.email);
        
        XCTAssertNotNil([tmpApp loggedUserWithRelayrID:tmpUser.uid]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)test_SignOut
{
    [_app signOutUser:_user];
    XCTAssertNil([_app loggedUserWithRelayrID:_user.uid]);
}

- (void)test_keyChain
{
    XCTAssertTrue([RelayrApp removeAppFromKeyChain:_app]);
    XCTAssertNil([RelayrApp retrieveAppFromKeyChain:kTestsAppID]);
    XCTAssertTrue([RelayrApp storeAppInKeyChain:_app]);
    
    RelayrApp* tmpApp = [RelayrApp retrieveAppFromKeyChain:_app.uid];
    XCTAssertNotNil(tmpApp);
    RelayrUser* tmpUser = [tmpApp loggedUserWithRelayrID:kTestsUserID];
    XCTAssertNotNil(tmpUser);
    XCTAssertTrue([tmpUser.uid isEqualToString:kTestsUserID]);
    XCTAssertTrue([tmpUser.name isEqualToString:kTestsUserName]);
    XCTAssertTrue([tmpUser.email isEqualToString:kTestsUserEmail]);
}

@end
