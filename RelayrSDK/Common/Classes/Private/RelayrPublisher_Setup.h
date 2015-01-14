#import "RelayrPublisher.h"     // Header

/*!
 *  @abstract Each instance of this class represent a <i>publisher</i> Relayr entity.
 *  @discussion A <i>publisher</i> is a Relayr user that can create Relayr applications.
 *
 *  @see RelayrUser
 *  @see RelayrApp
 */
@interface RelayrPublisher () <NSCoding>

/*!
 *  @abstract It initialises a <code>RelayrPublisher</code> entity with an ID and a <code>RelayrUser</code>.
 *  @discussion Both arguments must be valid for this method to return an initialised instance.
 *
 *  @param uid <code>NSString</code> representing an unique value identifing the Publisher in the Relayr cloud.
 *	@return A fully initialised <code>RelayrPublisher</code> entity or <code>nil</code> (if there was an error).
 *
 *  @see RelayrUser
 */
- (instancetype)initWithPublisherID:(NSString*)uid;

/*!
 *  @abstract The owner of the publisher entity. This is the User by whom the Publisher was created.
 */
@property (readwrite,nonatomic) NSString* owner;

/*!
 *  @abstract It lets you write the name of a Relayr publisher.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract Relayr apps owned by this publisher entity.
 *  @discussion A <code>NSSet</code> containing <code>NSString</code>s with the Relayr ID of the Relayr Apps entities.
 */
@property (readwrite,nonatomic) NSSet* apps;

/*!
 *  @abstract It sets the instance where this object is being called with the properties of the object passed as the argument.
 *  @discussion The object passed as the argument is considered new and thus the properties have more priority.
 *
 *  @param publisher The newer instance of this object.
 */
- (void)setWith:(RelayrPublisher*)publisher;

@end
