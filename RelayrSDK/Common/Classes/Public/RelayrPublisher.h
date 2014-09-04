@class RelayrUser;      // Relayr.framework (Public)
@import Foundation;     // Apple

/*!
 *  @abstract Each instance of this class represent a <i>publisher</i> Relayr entity.
 *  @discussion A <i>publisher</i> is a Relayr user that can create Relayr applications.
 *
 *  @see RelayrUser
 *  @see RelayrApp
 */
@interface RelayrPublisher : NSObject <NSCoding>

/*!
 *  @abstract It represents uniquely a Publisher in the Relayr cloud.
 *  @discussion It cannot be <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract It give a human friendly name to a Relayr publisher.
 *  @discussion It can be <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract Relayr User ID of this publisher entity.
 */
@property (readonly,nonatomic) NSString* owner;

@end
