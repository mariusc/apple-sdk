@import Cocoa;              // Apple
@import XCTest;             // Apple
#import <Relayr/Relayr.h>   // Relayr.framework

/*!
 *  @abstract Test the high-level methods of <code>RelayrApp</code> objects.
 *
 *  @see RelayrApp
 */
@interface TRelayrApp : XCTestCase
@end

RelayrApp* app;
NSString* appID;
NSString* oauthSecret;
NSString* redirectURI;

@implementation TRelayrApp

#pragma mark - Setup

+ (void)setUp
{
    //app = [RelayrApp ];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Unit tests

- (void)test_keyChain
{
    // This is an example of a functional test case.
    XCTFail(nil);
}

#pragma mark - Performance

- (void)testPerformance_keyChain
{
    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
}

@end
