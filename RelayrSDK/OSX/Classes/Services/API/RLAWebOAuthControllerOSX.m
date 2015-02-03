#import "RLAWebOAuthControllerOSX.h"    // Header
#import "RLAAPIConstants.h"             // Relayr (Services/API)
#import "RelayrErrors.h"                // Relayr (Utilities)

@interface RLAWebOAuthControllerOSX () <NSWindowDelegate>
@property (strong,nonatomic) RLAWebOAuthControllerOSX* selfRetained;
@end

@implementation RLAWebOAuthControllerOSX
{
    NSProgressIndicator* _spinner;
    WebView* _webView;
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

- (instancetype)initWithURLRequest:(NSURLRequest*)urlRequest redirectURI:(NSString*)redirectURI completion:(void (^)(NSError*, NSString*))completion
{
    if (!urlRequest || !redirectURI) { return nil; }
    
    // [super initWithFrame:dRLAWebOAuthControllerOSX_WindowSize frameName:nil groupName:nil];
    NSWindow* window = [[NSWindow alloc] initWithContentRect:dRLAWebOAuthControllerOSX_WindowSize styleMask:dRLAWebOAuthControllerOSX_WindowStyle backing:NSBackingStoreBuffered defer:YES];
    [window setMinSize:dRLAWebOAuthControllerOSX_WindowSizeMin];
    [window setTitle:dRLAWebOAuthController_Title];
    
    self = [super initWithWindow:window];
    if (self)
    {
        _urlRequest = urlRequest;
        _redirectURI = redirectURI;
        _completion = completion;
        
        window.delegate = self;
        _webView = [[WebView alloc] initWithFrame:dRLAWebOAuthControllerOSX_WindowSize frameName:nil groupName:nil];
        [_webView setPolicyDelegate:self];
        [_webView setFrameLoadDelegate:self];
        [window setContentView:_webView];
        
        _spinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(20, 20, 30, 30)];
        [_spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        _spinner.style = NSProgressIndicatorSpinningStyle;
    }
    return self;
}

- (BOOL)presentModally
{
    _selfRetained = self;
    
    NSWindow* window = self.window;
    [((WebView*)window.contentView).mainFrame loadRequest:_urlRequest];
    [self showSpinner];
    
    [self showWindow:window];
    [window center];
    
    return YES;
}

- (BOOL)presentAsPopOverInViewController:(id)viewController witTipLocation:(NSValue*)location
{
    return NO;
}

#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame
{
    [self hideSpinner];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame*)frame
{
    [self hideSpinner];
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView*)webView decidePolicyForNavigationAction:(NSDictionary*)actionInformation request:(NSURLRequest*)request frame:(WebFrame*)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSString* tmpCode = [RLAWebOAuthController OAuthTemporalCodeFromRequest:request withRedirectURI:_redirectURI];
    if (!tmpCode) { return [listener use]; }
    
    if (_completion)
    {
        _completion(nil, tmpCode);
        [self close];
        _completion = nil;
    }
}

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification*)notification
{
    NSWindow* window = self.window;
    window.delegate = nil;
    
    [_webView setPolicyDelegate:nil];
    [_webView setFrameLoadDelegate:nil];
    [window setContentView:nil];
    _webView = nil;
    
    //_selfRetained = nil;
    // FIXME: This is a retain cycle
}

#pragma mark - Private methods

- (void)showSpinner
{
    if (!_spinner.superview)
    {
        NSView* view = self.window.contentView;
        [view addSubview:_spinner];
        
        if (_spinner.constraints.count == 0)
        {
            [view addConstraints:@[
                [NSLayoutConstraint constraintWithItem:_spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f],
                [NSLayoutConstraint constraintWithItem:_spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]
            ]];
        }
        
        [_spinner startAnimation:nil];
    }
}

- (void)hideSpinner
{
    if (_spinner.superview)
    {
        [_spinner stopAnimation:nil];
        [_spinner removeFromSuperview];
    }
}

@end
