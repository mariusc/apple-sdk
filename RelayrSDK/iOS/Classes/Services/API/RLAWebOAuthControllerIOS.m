#import "RLAWebOAuthControllerIOS.h"    // Header
#import "RLAAPIConstants.h"             // Relayr (Services/API)
#import "RelayrErrors.h"                // Relayr (Utilities)

@interface RLAWebOAuthControllerIOS () <UIWebViewDelegate>
@property (strong,nonatomic) UIActivityIndicatorView* spinner;
@end

@implementation RLAWebOAuthControllerIOS

@synthesize urlRequest=_urlRequest;
@synthesize redirectURI=_redirectURI;
@synthesize completion=_completion;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithURLRequest:(NSURLRequest*)urlRequest redirectURI:(NSString*)redirectURI completion:(void (^)(NSError* error, NSString* tmpCode))completion
{
    if (!urlRequest) { return nil; }
    
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _urlRequest = urlRequest;
        _redirectURI = redirectURI;
        _completion = completion;
        self.title = dRLAWebOAuthController_Title;
    }
    return self;
}

- (BOOL)presentModally
{
    UIApplication* app = [UIApplication sharedApplication];
    UIWindow* window = (app.keyWindow) ? app.keyWindow : app.windows.firstObject;
    UIViewController* rootViewController = window.rootViewController;
    if (!rootViewController) { return NO; }
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:self];
    navController.navigationBar.translucent = YES;
    
    [rootViewController presentViewController:navController animated:YES completion:nil];
    [((UIWebView*)self.view) loadRequest:_urlRequest];
    
    return YES;
}

- (BOOL)presentAsPopOverInViewController:(id)viewController witTipLocation:(NSValue*)location
{
    return NO;
}

#pragma mark UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)loadView
{
    UIWebView* webView = [[UIWebView alloc] init];
    [webView setKeyboardDisplayRequiresUserAction:NO];
    webView.delegate = self;
    self.view = webView;
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self showSpinner];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed)];
}

#pragma mark UIWebDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* tmpCode = [RLAWebOAuthController OAuthTemporalCodeFromRequest:request withRedirectURI:_redirectURI];
    if (!tmpCode) { return YES; }
    
    if (_completion) { _completion(nil, tmpCode); }
    [self dismiss];
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [self showSpinner];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [self hideSpinner];
    // Activate email text field and show keyboard on first page display. This is only done once since error messages are displayed at the top of the page and the user will not see them if the webview constantly jumps to the textfields
    /*if (!self.RLA_isFocusOnTextfieldDisabled)
    {
        self.RLA_isFocusOnTextfieldDisabled = YES;
        NSString *script = @"document.getElementById('email').focus();";
        [webView stringByEvaluatingJavaScriptFromString:script];
    }*/
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideSpinner];
}

#pragma mark - Private methods

- (void)cancelPressed
{
    if (_completion) { _completion(RelayrErrorUserStoppedProcess, nil); }
    [self dismiss];
}

- (void)showSpinner
{
    if (![self isViewLoaded]) { return; }
    
    if (!_spinner.superview)
    {
        UIView* view = self.view;
        [view addSubview:_spinner];
        if (_spinner.constraints.count == 0)
        {
            [view addConstraints:@[
                [NSLayoutConstraint constraintWithItem:_spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f],
                [NSLayoutConstraint constraintWithItem:_spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]
            ]];
        }
        
        _spinner.alpha = 0.1f;
        UIActivityIndicatorView* spinner = _spinner;
        [UIView animateWithDuration:dRLAWebOAuthControllerIOS_Spinner_Animation animations:^{ spinner.alpha = 1.0f; }];
    }
    
    [_spinner startAnimating];
}

- (void)hideSpinner
{
    if (![self isViewLoaded]) { return; }
    
    if (_spinner.superview)
    {
        UIActivityIndicatorView* spinner = _spinner;
        [UIView animateWithDuration:dRLAWebOAuthControllerIOS_Spinner_Animation animations:^{
            spinner.alpha = 0.1f;
        } completion:^(BOOL finished) {
            [spinner stopAnimating];
            [spinner removeFromSuperview];
        }];
    }
}

- (void)dismiss
{
    if ([self isViewLoaded]) { [((UIWebView*)self.view) stopLoading]; }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    _completion = nil;
}

@end
