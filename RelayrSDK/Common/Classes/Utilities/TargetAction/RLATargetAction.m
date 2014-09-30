#import "RLATargetAction.h"

@implementation RLATargetAction

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithTarget:(__weak NSObject*)target action:(SEL)action
{
    if (!target || ![target respondsToSelector:action]) { return nil; }
    
    self = [super init];
    if (self)
    {
        _target = target;
        _action = action;
    }
    return self;
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"{\n\tTarget:\t%@\n\tAction:\t%s\n}", _target, sel_getName(_action)];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
    return [[RLATargetAction alloc] initWithTarget:_target action:_action];
}

@end
