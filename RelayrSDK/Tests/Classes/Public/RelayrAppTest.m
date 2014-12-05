@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLATestsConstants.h"   // Tests

/*!
 *  @abstract Test the high-level methods of <code>RelayrApp</code> objects.
 *
 *  @see RelayrApp
 */
@interface RelayrAppTest : XCTestCase
@property (readonly,nonatomic) RelayrApp* app;
@property (readonly,nonatomic) RelayrUser* user;
@end

@implementation RelayrAppTest

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    
    _app = [[RelayrApp alloc] initWithID:kTestsAppID OAuthClientSecret:kTestsAppSecret redirectURI:kTestsAppRedirect];
    _user = [[RelayrUser alloc] initWithToken:kTestsUserToken];
    _user.uid = kTestsUserID;
    _user.name = kTestsUserName;
    _user.email = kTestsUserEmail;
    _user.app = _app;
    [_app.users addObject:_user];
}

- (void)tearDown
{
    [RelayrApp removeAppFromFileSystem:_app];
    [_app signOutUser:_user];
    _user = nil;
    _app = nil;
    [super tearDown];
}

#pragma mark - Unit tests

- (void)testQueryForAppInfo
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

- (void)testSetName
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];

    [_app setName:kTestsAppName withUserCredentials:_user completion:^(NSError* error, NSString* previousName) {
        XCTAssertNil(error);
        XCTAssertNotNil(_app.name);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testSetDescription
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [_app setDescription:kTestsAppDescription withUserCredentials:_user completion:^(NSError* error, NSString* previousDescription) {
        XCTAssertNil(error);
        XCTAssertNotNil(_app.appDescription);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

- (void)testLoggedUsers
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

- (void)testStorage
{
    RelayrApp* tmpApp = [RelayrApp retrieveAppWithIDFromFileSystem:kTestsAppID];
    XCTAssertNil(tmpApp);
    
    tmpApp = [[RelayrApp alloc] initWithID:kTestsAppID OAuthClientSecret:kTestsAppSecret redirectURI:kTestsAppRedirect];
    RelayrUser* tmpUser = [[RelayrUser alloc] initWithToken:kTestsUserToken];
    [tmpApp.users addObject:tmpUser];
    
    BOOL status = [RelayrApp persistAppInFileSystem:tmpApp];
    XCTAssertTrue(status);
    
    tmpApp = nil;
    tmpApp = [RelayrApp retrieveAppWithIDFromFileSystem:kTestsAppID];
    XCTAssertNotNil(tmpApp);
    
    status = [RelayrApp removeAppFromFileSystem:tmpApp];
    XCTAssertTrue(tmpApp);
}

- (void)testSignIn
{
    RelayrApp* tmpApp = [[RelayrApp alloc] initWithID:kTestsAppID OAuthClientSecret:kTestsAppSecret redirectURI:kTestsAppRedirect];
    XCTAssertNotNil(tmpApp);
    
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    [tmpApp signInUser:^(NSError* error, RelayrUser* user) {
        XCTAssertNil(error);
        XCTAssertNotNil(user);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testSignOut
{
    [_app signOutUser:_user];
    XCTAssertNil([_app loggedUserWithRelayrID:_user.uid]);
}

@end
