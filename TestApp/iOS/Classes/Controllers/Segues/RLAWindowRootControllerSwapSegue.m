#import "RLAWindowRootControllerSwapSegue.h"         // Header

#import "AppDelegate.h"             // TestApp

@implementation RLAWindowRootControllerSwapSegue

- (void)perform
{
    [UIApplication sharedApplication].keyWindow.rootViewController = self.destinationViewController;
}

@end
