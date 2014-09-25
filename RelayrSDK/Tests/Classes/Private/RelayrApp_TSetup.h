#import <Relayr/Relayr.h>       // Relayr.framework

@interface RelayrApp ()

/*!
 *  @abstract The users currently logged in in the application.
 */
@property (readonly,nonatomic) NSMutableArray* users;

@end
