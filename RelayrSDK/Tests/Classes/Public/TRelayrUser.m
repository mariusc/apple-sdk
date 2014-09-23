@import Cocoa;              // Apple
@import XCTest;             // Apple
#import <Relayr/Relayr.h>   // Relayr.framework
#import "RLALog.h"          // Relayr.framework (Utilities)
#import "RelayrUser_Setup.h"// Relayr.framework (Private)

/*!
 *  @abstract Test the high-level methods of <code>RelayrUser</code> objects.
 *
 *  @see RelayrApp
 */
@interface TRelayrUser : XCTestCase
@end

//RelayrApp* _relayrApp;
//#define RelayrAppID
//#define RelayrAppSecret
//#define RelayrRedirectURI
#define dRelayrUserToken     @""

@implementation TRelayrUser

#pragma mark - Setup

//+ (void)setUp
//{
//    [RelayrApp appWithID:RelayrAppID OAuthClientSecret:RelayrAppSecret redirectURI:RelayrRedirectURI completion:^(NSError* error, RelayrApp* app) {
//        if (error) { return [RLALog debu]; }
//        _relayrApp = app;
//    }];
//}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//+ (void)tearDown
//{
//    _relayrApp = nil;
//}

#pragma mark - Unit tests

- (void)test_registerDevice
{
//    RelayrUser* user = [[RelayrUser alloc] initWithToken:dRelayrUserToken];
//    [user registerDeviceWithModelID:@"ecf6cf94-cb07-43ac-a85e-dccf26b48c86" firmwareVerion:@"1.0.0" name:@"Random name" completion:^(NSError* error, RelayrDevice* device) {
//        XCTAssertNil(error);
//        XCTAssertNotNil(device);
//    }];
}

@end
