#import "RelayrApp.h"       // Header

/*!
 *  @class RelayrApp
 *
 *  @abstract It represents a Relayr Application and through it, you can interact with the Relayr cloud.
 *  @discussion Relayr applications allow your mobile app to access information on the Relayr cloud. They are the starting point on any Relayr information retrieval or information pushing into the cloud.
 */
@interface RelayrApp ()

/*!
 *  @method initWithID:publisherID:
 *
 *  @abstract It initialises a <code>RelayrApp</code> with a Relayr application ID and a Relayr publisher ID.
 *  @discussion If any of the argument is not valid, the initialiser returns <code>nil</code>.
 *
 *  @param appID <code>NSString</code> representing the Relayr application ID.
 *  @param publisherID <code>NSString</code> representing the Relayr publisher ID.
 *	@return Fully initialised <code>RelayrApp</code> instance or <code>nil</code>.
 *
 *  @see RelayrUser
 *  @see RelayrPublisher
 */
- (instancetype)initWithID:(NSString*)appID publisherID:(NSString*)publisherID;

/*!
 *  @property name
 *
 *  @abstract It returns (or set) the given name of this Relayr application.
 */
@property (readwrite,nonatomic) NSString* name;

@end
