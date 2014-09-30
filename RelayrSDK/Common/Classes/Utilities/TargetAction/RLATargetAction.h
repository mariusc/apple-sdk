@import Foundation;

/*!
 *  @abstract It stores a target-action par for future use.
 *  @discussion The target is stored weakly; thus be sure to store the target object strongly somewhere else.
 */
@interface RLATargetAction : NSObject <NSCopying>

/*!
 *  @abstract Initialises a pair target-action.
 *  @discussion If the target is <code>nil</code>, the method returns <code>nil</code>.
 *
 *  @param target The target that will receive an action.
 *  @param action The action that will be executed on the <code>target</code>.
 *	@return Fully initialised object or <code>nil</code>.
 */
- (instancetype)initWithTarget:(__weak NSObject*)target action:(SEL)action;

/*!
 *  @abstract The target that will receive the action.
 */
@property (weak,nonatomic) NSObject* target;

/*!
 *  @abstract The action to be executed on the <code>target</code>.
 */
@property (nonatomic) SEL action;

@end
