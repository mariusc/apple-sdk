#import "RLANavigationRootController.h" // Header

@interface RLANavigationRootController ()
@end

@implementation RLANavigationRootController

#pragma mark - Public API

#pragma mark UIViewController methods

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue with identifier: %@ triggered", segue.identifier);
}

@end
