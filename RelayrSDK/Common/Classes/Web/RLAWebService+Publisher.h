#import "RLAWebService.h"   // Base class
@class RelayrPublisher;     // Relayr.framework (Public)

@interface RLAWebService (Publisher)

/*!
 *  @abstract Registers a publisher entity in the Relayr cloud.
 *
 *  @param publisherName The given name for the publisher.
 *  @param ownerID The Relayr user owner of this publisher entity.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrPublisher
 */
- (void)registerPublisherWithName:(NSString*)publisherName
                          ownerID:(NSString*)ownerID
                       completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion;

/*!
 *  @abstract Retrieves all the publishers in the Relayr cloud.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrPublisher
 */
- (void)requestAllRelayrPublishers:(void (^)(NSError* error, NSArray* publishers))completion;

/*!
 *  @abstract Set some properties of the Relayr publisher entity in the Relayr cloud.
 *
 *  @param publisherID <code>NSString</code> representing the unique Relayr identifier for a given publisher.
 *  @param futurePublisherName The name that will be writen in the Relayr publisher entity in the Relayr cloud.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrPublisher
 */
- (void)setPublisher:(NSString*)publisherID
            withName:(NSString*)futurePublisherName
          completion:(void (^)(NSError* error))completion;

@end
