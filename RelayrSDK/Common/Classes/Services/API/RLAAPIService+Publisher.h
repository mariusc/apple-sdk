#import "RLAAPIService.h"   // Base class
@class RelayrPublisher;     // Relayr.framework (Public)

@interface RLAAPIService (Publisher)

/*!
 *  @abstract Retrieves all the publishers in the Relayr cloud.
 *
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrPublisher
 */
+ (void)requestAllRelayrPublishers:(void (^)(NSError* error, NSSet* publishers))completion;

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
 *  @abstract Retrieves the information of a specific publisher.
 *
 *  @param publisherID <code>NSString</code> representing the unique Relayr identifier for a given publisher.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrPublisher
 */
- (void)requestPublisher:(NSString*)publisherID
             completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion;

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
          completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion;

/*!
 *  @abstract Deletes the publisher entity from the Relayr Cloud.
 *
 *  @param publisherID <code>NSString</code> representing the unique Relayr identifier for the Publisher.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrTransmitter
 */
- (void)deletePublisher:(NSString*)publisherID
             completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Retrieves all the Relayr Applications under a publisher.
 *
 *  @param publisherID The Relayr unique identifer for a given publisher.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrPublisher
 *  @see RelayrApp
 */
- (void)requestAppsFromPublisher:(NSString*)publisherID
                     completion:(void (^)(NSError* error, NSSet* apps))completion;

/*!
 *  @abstract Retrieves all the Relayr Applications under a publisher.
 *  @discussion This request provides more information than the regular @link requestAppsFromPublisher:completion: @/link
 *
 *  @param publisherID The Relayr unique identifer for a given publisher.
 *  @param completion Block indicating the result of the server query.
 *
 *  @see RelayrPublisher
 *  @see RelayrApp
 */
- (void)requestAppsWithExtendedInfoFromPublisher:(NSString*)publisherID
                                      completion:(void (^)(NSError* error, NSSet* apps))completion;

@end
