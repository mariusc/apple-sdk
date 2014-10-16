#import "RLAWebService.h"           // Header
#import "RLAWebConstants.h"         // Relayr.framework (Web)

@implementation RLAWebService

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUser:(RelayrUser*)user
{
    if (!user) { return nil; }
    
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
