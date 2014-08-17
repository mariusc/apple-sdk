#import "RLAOutput.h"   // Header

@implementation RLAOutput

#pragma mark - Public API

- (void)setData:(NSData*)data
{
    [self willChangeValueForKey:@"data"];
    _data = data;
    [self didChangeValueForKey:@"data"];
}

- (NSString*)uid
{
    RLAAssertAbstractMethodAndReturnNil;
}

- (NSString *)type
{
    RLAAssertAbstractMethodAndReturnNil;
}

#pragma mark NSCopying

#warning WTF
- (instancetype)copyWithZone:(NSZone*)zone
{
//    typeof(self) copy = [[[self class] alloc] init];
//    return copy;
    return nil;
}

@end
