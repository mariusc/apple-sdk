#import "RLAAPIService.h"           // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)

@implementation RLAAPIService

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUser:(RelayrUser*)user
{
    if (!user.token.length) { return nil; }

    self = [super init];
    if (self)
    {
        _user = user;
        _hostString = Web_Host;
    }
    return self;
}

- (void)setHostString:(NSString*)hostString
{
    _hostString = (hostString) ? hostString : Web_Host;
}

@end
