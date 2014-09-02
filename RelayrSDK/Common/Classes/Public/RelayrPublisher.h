@class RelayrUser;      // Relayr.framework
@import Foundation;     // Apple

/*!
 *  @class RelayrPublisher
 *
 *  @abstract Each instance of this class represent a <i>publisher</i> Relayr entity.
 *  @discussion A <i>publisher</i> is a Relayr user that can create Relayr applications.
 *
 *  @see RelayrUser
 *  @see RelayrApp
 */
@interface RelayrPublisher : NSObject <NSCoding>

/*!
 *  @property uid
 *
 *  @abstract It represents uniquely a Publisher in the Relayr cloud.
 *  @discussion It cannot be <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @property name
 *
 *  @abstract It give a human friendly name to a Relayr publisher.
 *  @discussion It can be <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @property owner
 *
 *  @abstract It returns a weak link to the user who owns this publisher entity.
 *  @discussion It cannot be <code>nil</code>.
 */
@property (readonly,weak,nonatomic) RelayrUser* owner;

@end
