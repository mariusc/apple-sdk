#import "RLAKickoffController.h"   // Header

#import "RLAStoryboardIDs.h"        // TestApp (Controllers)
#import <Relayr/Relayr.h>           // Relayr

@interface RLAKickoffController ()
@property (weak, nonatomic) IBOutlet UILabel* explanationLabel;
@property (weak, nonatomic) IBOutlet UIButton* retryButton;
@end

@implementation RLAKickoffController

#pragma mark - Public API

- (IBAction)connectionRetryPressed:(UIButton*)sender
{
    _explanationLabel.text = @"hecking connection to the Relayr Cloud...";
    _retryButton.hidden = YES;
    _retryButton.enabled = NO;
    
    [RelayrCloud isReachable:^(NSError* error, NSNumber* isReachable) {
        if (!isReachable.boolValue)
        {
            _explanationLabel.text = [NSString stringWithFormat:@"The Relayr Cloud seems not to be reachable.\nError: %@", error.localizedDescription];
            _retryButton.hidden = NO;
            _retryButton.enabled = YES;
            return;
        }
        
        _explanationLabel.text = @"Connection to Relayr Cloud successfully stablished";
        _retryButton.hidden = YES;
        [self performSegueWithIdentifier:RLAStoryboardIDs_KickoffSegue sender:self];
    }];
}

#pragma mark UIViewController methods

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self connectionRetryPressed:_retryButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
