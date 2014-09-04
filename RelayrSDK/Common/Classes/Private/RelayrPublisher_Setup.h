#import "RelayrPublisher.h"     // Header

/*!
 *  @abstract Each instance of this class represent a <i>publisher</i> Relayr entity.
 *  @discussion A <i>publisher</i> is a Relayr user that can create Relayr applications.
 *
 *  @see RelayrUser
 *  @see RelayrApp
 */
@interface RelayrPublisher ()

/*!
 *  @abstract It initialises a <code>RelayrPublisher</code> entity with an ID and a <code>RelayrUser</code>.
 *  @discussion Both arguments must be valid for this method to return an initialised instance.
 *
 *  @param uid <code>NSString</code> representing an unique value identifing the Publisher in the Relayr cloud.
 *  @param owner <code>NSString</code> representing the Relayr User ID owner of this publisher entity.
 *	@return A fully initialised <code>RelayrPublisher</code> entity or <code>nil</code> (if there was an error).
 *
 *  @see RelayrUser
 */
- (instancetype)initWithPublisherID:(NSString*)uid owner:(NSString*)owner;

/*!
 *  @abstract It lets you write the name of a Relayr publisher.
 */
@property (readwrite,nonatomic) NSString* name;

@end
