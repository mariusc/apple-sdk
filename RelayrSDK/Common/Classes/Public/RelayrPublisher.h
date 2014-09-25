@class RelayrUser;      // Relayr.framework (Public)
@import Foundation;     // Apple

/*!
 *  @abstract Every instance of this class represents a <i>publisher</i> entity.
 *  @discussion A Publisher is a basic entity in the relayr platform. 
 *	Each user can choose to have the option to publish apps on the relayr platform and they are then assigned a publisherId.
 *
 *  @see RelayrUser
 *  @see RelayrApp
 */
@interface RelayrPublisher : NSObject <NSCoding>

/*!
 *  @abstract Uniquely represents a Publisher on the relayr platform.
 *  @discussion Cannot be <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract Represents the publisher name. 
 *  @discussion Can be <code>nil</code>.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract The owner of the publisher entity. This is the User by whom the Publisher was created. 
 */
@property (readonly,nonatomic) NSString* owner;

/*!
 *  @abstract relayr apps owned by this publisher entity.
 *  @discussion An <code>NSSet</code> containing <code>RelayrApp</code> entities.
 */
@property (readonly,nonatomic) NSSet* apps;

@end
