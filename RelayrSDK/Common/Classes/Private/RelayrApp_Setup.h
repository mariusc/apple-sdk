#import "RelayrApp.h"       // Header

/*!
 *  @abstract It represents a Relayr Application and through it, you can interact with the Relayr cloud.
 *  @discussion Relayr applications allow your mobile app to access information on the Relayr cloud. They are the starting point on any Relayr information retrieval or information pushing into the cloud.
 */
@interface RelayrApp () <NSCoding>

/*!
 *  @abstract It returns (or set) the given name of this Relayr application.
 */
@property (readwrite,nonatomic) NSString* name;

/*!
 *  @abstract Relayr Application description.
 *  @discussion This value must be first retrieved asynchronously from the Relayr Cloud. If you don't query the server, this property is <code>nil</code>.
 */
@property (readwrite,nonatomic) NSString* appDescription;

/*!
 *  @abstract Creator of the Relayr Application ID.
 *  @discussion This value must be first retrieved asynchronously from the Relayr Cloud. If you don't query the server, this property is <code>nil</code>.
 */
@property (readwrite,nonatomic) NSString* publisherID;

/*!
 *  @abstract This is a security password used to check the procedence of the server messages.
 *  @discussion The <code>redirectURI</code> is specified at the Relayr App creation time.
 */
@property (readwrite,nonatomic) NSString* redirectURI;

@end
