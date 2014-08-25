#import "RLAWebModal.h"         // Header
#import "CPlatforms.h"          // Relayr.framework (Utilities)

static NSString* const kRLAWebModalViewControllerTitle = @"Relayr";

#if defined(OS_APPLE_IOS) || defined (OS_APPLE_IOS_SIMULATOR)
@import UIKit;

@interface RLAWebModal () <UIWebViewDelegate>
@end
#elif defined(OS_APPLE_OSX)
@import Cocoa;
@import WebKit;
#endif

@implementation RLAWebModal

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithRequest:(RLAWebRequest*)request
{
    if (!request) { return nil; }
    
    self = [super init];
    if (self)
    {
        _request = request;
    }
    return self;
}

// TODO: Fill up
- (BOOL)presentModally
{
    #if defined(OS_APPLE_IOS) || defined (OS_APPLE_IOS_SIMULATOR)
    return [self presentModallyIniOS];
    #elif defined(OS_APPLE_OSX)
    return [self presentModallyInOSX];
    #else
    return NO;
    #endif
}

#pragma mark - Private methods

#if defined(OS_APPLE_IOS) || defined (OS_APPLE_IOS_SIMULATOR)
- (BOOL)presentModallyIniOS
{
    // Retrieve the rootViewController
    UIApplication* app = [UIApplication sharedApplication];
    UIWindow* window = (app.keyWindow) ? app.keyWindow : app.windows.firstObject;
    UIViewController* rootViewController = window.rootViewController;
    rootViewController.title = kRLAWebModalViewControllerTitle;
    if (!rootViewController) { return NO; }
    
    // Build webView
//    UIViewController*
    
//    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:];
//    navigationController.navigationBar.translucent = NO;
    return YES;
}
#endif

/*
 [[theWebView mainFrame] loadRequest:
 [NSURLRequest requestWithURL:
 [NSURL fileURLWithPath:
 [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"]]]];
 */

#if defined(OS_APPLE_OSX)
static NSString* const kRLAWebModalFrameName = @"RelayrWebframe";

- (BOOL)presentModallyInOSX
{
    NSSize const minimumSize = NSMakeSize(450.0f, 600.0f);
    NSRect const windowRect = NSMakeRect(0.0f, 0.0f, 450.0f, 700.0f);
    NSUInteger const windowStyle = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask;
    
    NSWindow* window = [[NSWindow alloc] initWithContentRect:windowRect styleMask:windowStyle backing:NSBackingStoreRetained defer:YES];
    [window setMinSize:minimumSize];
    
//    WebView* webView = [[WebView alloc] initWithFrame:windowRect frameName:kRLAWebModalFrameName groupName:nil];
//    [webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]]];
//    [[webView mainFrame] loadHTMLString:@"<html><head></head><body><h1>Hello</h1></body></html>" baseURL:nil];
//    [window setContentView:webView];
    
    NSView* view = [[NSView alloc] initWithFrame:windowRect];
    [window setContentView:view];
    
    [NSApp runModalForWindow:window];
    
    return YES;
}
#endif

@end
