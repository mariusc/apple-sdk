#import "RLAWebViewOAuthIOS.h"      // Header
#import "RLAError.h"                // Relayr.framework (Utilities)

@interface RLAWebViewOAuthIOS () <UIWebViewDelegate>
@property (readonly,nonatomic) UIActivityIndicatorView* spinnerView;
@end

@implementation RLAWebViewOAuthIOS

@synthesize url=_url;
@synthesize completion=_completion;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithURL:(NSURL*)absoluteURL completion:(void (^)(NSError*, NSString*))completion
{
    if (!completion) { return nil; }
    if (!absoluteURL) { completion(RLAErrorMissingArgument, nil); return nil; }
    
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _url = absoluteURL;
        _completion = completion;
    }
    return self;
}

- (BOOL)presentModally
{
    UIApplication* app = [UIApplication sharedApplication];
    UIWindow* window = (app.keyWindow) ? app.keyWindow : app.windows.firstObject;
    UIViewController* rootViewController = window.rootViewController;
    if (!rootViewController) { return NO; }
    
    
    return YES;
}

- (BOOL)presentAsPopOverInViewController:(id)viewController witTipLocation:(NSValue *)location
{
    return NO;
}

#pragma mark UIViewController

- (void)loadView
{
    [super loadView];
    self.title = dRLAWebViewOAuthTitle;
    
    _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
//    _webView = [[UIWebView alloc] initWithFrame:<#(CGRect)#>];
//    _webView.delegate = self;
}

@end
