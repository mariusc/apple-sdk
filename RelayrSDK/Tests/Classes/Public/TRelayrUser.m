@import Cocoa;              // Apple
@import XCTest;             // Apple
#import <Relayr/Relayr.h>   // Relayr.framework

/*!
 *  @abstract Test the high-level methods of <code>RelayrUser</code> objects.
 *
 *  @see RelayrApp
 */
@interface TRelayrUser : XCTestCase
@end

@implementation TRelayrUser

#pragma mark - Setup

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

#pragma mark - Unit tests

- (void)testExample
{
    // This is an example of a functional test case.
    XCTFail(nil);
}

#pragma mark - Performance

- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
