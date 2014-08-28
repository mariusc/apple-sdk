#import "RLAWebViewOAuthOSX.h"      // Header
@import Cocoa;                      // Apple
#import "RLAError.h"                // Relayr.framework (Utilities)

#define dRLAWebViewOAuthOSX_DefaultWindowSize   NSMakeRect(0.0f, 0.0f, 450.0f, 700.0f)
#define dRLAWebViewOAuthOSX_MinimumWindowSize   NSMakeSize(350.0f, 450.0f)

@implementation RLAWebViewOAuthOSX

@synthesize url=_url;
@synthesize completion=_completion;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithURL:(NSURL *)absoluteURL completion:(void (^)(NSError* error, NSString* tmpCode))completion
{
    if (!completion) { return nil; }
    if (!absoluteURL) { completion(RLAErrorMissingArgument, nil); return nil; }
    
    self = [super initWithFrame:dRLAWebViewOAuthOSX_DefaultWindowSize frameName:nil groupName:nil];
    if (self)
    {
        _url = absoluteURL;
        _completion = completion;
    }
    return self;
}

- (BOOL)presentModally
{
    /* WebView that works when added to the current window */
//    NSWindow* window = [NSApplication sharedApplication].windows.firstObject;
//    [self.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]]];
//    [window.contentView addSubview:self];
    
    NSUInteger const windowStyle = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask;
    NSWindow* window = [[NSWindow alloc] initWithContentRect:dRLAWebViewOAuthOSX_DefaultWindowSize styleMask:windowStyle backing:NSBackingStoreBuffered defer:YES];
    [window setMinSize:dRLAWebViewOAuthOSX_MinimumWindowSize];
    [window setTitle:dRLAWebViewOAuthTitle];
    [window.contentView addSubview:self];
    
    [[NSApplication sharedApplication].windows.firstObject addChildWindow:window ordered:NSWindowAbove];
    [window center];
    
    [self.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]]];
    
//    NSModalSession session = [NSApp beginModalSessionForWindow:window];
//    NSInteger result = NSRunContinuesResponse;
//    
//    [self.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]]];
//    [window setContentView:self];
//    
//    // Loop until some result other than continues:
//    while (result == NSRunContinuesResponse)
//    {
//        result = [NSApp runModalSession:session];
//        [[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];
//    }
//    
//    [NSApp endModalSession:session];
    
//    [[self mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]]];
//    NSString* filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"html"];
//    [[self mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
//    [NSApp runModalForWindow:window];
    //[[webView mainFrame] loadHTMLString:@"<html><head></head><body><h1>Hello</h1></body></html>" baseURL:nil];
    
    return YES;
}

// TODO: Fill up
- (BOOL)presentAsPopOverInViewController:(id)viewController witTipLocation:(NSValue *)location
{
    return NO;
}

@end
