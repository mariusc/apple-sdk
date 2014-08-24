@import Foundation;

/*!
 *  @class RelayrUser
 *
 *  @abstract Each instance of this class represent a Relayr User that is associated with the Relayr Application that created.
 */
@interface RelayrUser : NSObject <NSCoding>

/*!
 *  @property token
 *
 *  @abstract The representation of a Relayr User and its Relayr Application.
 *  @discussion It doesn't change along the lifetime of the <code>RelayrUser</code>
 */
@property (readonly,nonatomic) NSString* token;

/*!
 *  @property uid
 *
 *  @abstract Relyar idenfier for the <code>RelayrUser</code>'s instance.
 */
@property (readonly,nonatomic) NSString* uid;

@property (readonly,nonatomic) NSString* name;

@property (readonly,nonatomic) NSString* email;

@property (readonly,nonatomic) NSArray* apps;

@property (readonly,nonatomic) NSArray* transmitter;

@property (readonly,nonatomic) NSArray* devices;

@property (readonly,nonatomic) NSArray* devicesBookmarked;

@property (readonly,nonatomic) NSArray* publishers;

- (void)queryCloudForUserInfo:(void (^)(NSError* error, NSString* previousName, NSString* previousEmail))completion;

- (void)queryCloudForIoTs:(void (^)(NSError* error, BOOL isThereChanges))completion;

@end
