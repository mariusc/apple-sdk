#import "RLAWebOAuthControllerOSX.h"    // Header
#import "RLAError.h"                    // Relayr.framework (Utilities)

#define dRLAWebViewWindowStyle                  NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask
#define dRLAWebViewOAuthOSX_DefaultWindowSize   NSMakeRect(0.0f, 0.0f, 1050.0f, 710.0f)
#define dRLAWebViewOAuthOSX_MinimumWindowSize   NSMakeSize(350.0f, 450.0f)

@interface RLAWebOAuthControllerOSX () <NSWindowDelegate>
@end

@implementation RLAWebOAuthControllerOSX
{
    __strong RLAWebOAuthControllerOSX* _retainedSelf;
}

@synthesize urlRequest=_urlRequest;
@synthesize redirectURI=_redirectURI;
@synthesize completion=_completion;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithWindow:(NSWindow *)window
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithURLRequest:(NSURLRequest*)urlRequest redirectURI:(NSString *)redirectURI completion:(void (^)(NSError *, NSString *))completion
{
    if (!completion) { return nil; }
    if (!urlRequest || !redirectURI) { completion(RLAErrorMissingArgument, nil); return nil; }
    
    // [super initWithFrame:dRLAWebViewOAuthOSX_DefaultWindowSize frameName:nil groupName:nil];
    NSWindow* window = [[NSWindow alloc] initWithContentRect:dRLAWebViewOAuthOSX_DefaultWindowSize styleMask:dRLAWebViewWindowStyle backing:NSBackingStoreBuffered defer:YES];
    [window setMinSize:dRLAWebViewOAuthOSX_MinimumWindowSize];
    [window setTitle:dRLAWebOAuthControllerTitle];
    
    self = [super initWithWindow:window];
    if (self)
    {
        _urlRequest = urlRequest;
        _redirectURI = redirectURI;
        _completion = completion;
        
        window.delegate = self;
        WebView* webView = [[WebView alloc] initWithFrame:dRLAWebViewOAuthOSX_DefaultWindowSize frameName:nil groupName:nil];
        [webView setPolicyDelegate:self];
        [webView setFrameLoadDelegate:self];
        [window setContentView:webView];
    }
    return self;
}

- (BOOL)presentModally
{
    _retainedSelf = self;
    
    NSWindow* window = self.window;
    [((WebView*)window.contentView).mainFrame loadRequest:[NSURLRequest requestWithURL:_url]];
    [self showWindow:window];
    [window center];
    
    return YES;
}

- (BOOL)presentAsPopOverInViewController:(id)viewController witTipLocation:(NSValue*)location
{
    return NO;
}

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification*)notification
{
    _retainedSelf = nil;
}

#pragma mark WebPolicyDelegate



#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame
{
    
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame*)frame
{
    
}

@end
