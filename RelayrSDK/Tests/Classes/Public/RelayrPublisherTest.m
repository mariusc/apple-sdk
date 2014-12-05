@import Cocoa;                  // Apple
@import XCTest;                 // Apple
#import <Relayr/Relayr.h>       // Relayr.framework
#import "RelayrApp_Setup.h"     // Relayr.framework (Private)
#import "RelayrUser_Setup.h"    // Relayr.framework (Private)
#import "RLATestsConstants.h"   // Tests

/*!
 *  @abstract Test the high-level methods of <code>RelayrPublisher</code> objects.
 *
 *  @see RelayrApp
 */
@interface RelayrPublisherTest : XCTestCase
@property (readonly,nonatomic) RelayrApp* app;
@property (readonly,nonatomic) RelayrUser* user;
@end

@implementation RelayrPublisherTest

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

- (void)testPublisherInstance
{
    XCTestExpectation* expectation = [self expectationWithDescription:nil];
    
    __weak RelayrUser* user = self.user;
    [_user queryCloudForPublishersAndAuthorisedApps:^(NSError *error) {
        XCTAssertNil(error);
        XCTAssertGreaterThanOrEqual(_user.publishers.count, 1);
        XCTAssertGreaterThanOrEqual(_user.authorisedApps.count, 1);
        
        RelayrPublisher* publisher = user.publishers.anyObject;
        XCTAssertNotNil(publisher);
        XCTAssertGreaterThan(publisher.uid.length, 0);
        XCTAssertGreaterThan(publisher.name.length, 0);
        XCTAssertGreaterThan(publisher.owner.length, 0);
        //XCTAssertGreaterThan(publisher.apps.count, 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestsTimeout handler:nil];
}

@end
