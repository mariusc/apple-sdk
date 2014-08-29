#import "RLAWebOAuthControllerOSX.h"    // Header
#import "RLAWebConstants.h"             // Relayr.framework (Web)
#import "RLAError.h"                    // Relayr.framework (Utilities)

@interface RLAWebOAuthControllerOSX () <NSWindowDelegate>
@property (strong,nonatomic) RLAWebOAuthControllerOSX* retainedSelf;
@end

@implementation RLAWebOAuthControllerOSX
{
    NSProgressIndicator* _spinner;
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
        WebView* webView = [[WebView alloc] initWithFrame:dRLAWebOAuthControllerOSX_WindowSize frameName:nil groupName:nil];
        [webView setPolicyDelegate:self];
        [webView setFrameLoadDelegate:self];
        [window setContentView:webView];
        
        _spinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(20, 20, 30, 30)];
        [_spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        _spinner.style = NSProgressIndicatorSpinningStyle;
    }
    return self;
}

- (BOOL)presentModally
{
    _retainedSelf = self;
    
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

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification*)notification
{
    _retainedSelf = nil;
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
        void (^completion)(NSError*, NSString*) = _completion;
        _completion = nil;
        
        [self close];
        completion(nil, tmpCode);
        //_retainedSelf = nil;
    }
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
