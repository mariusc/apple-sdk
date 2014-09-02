@import Foundation;

FOUNDATION_EXPORT NSString* const kRLAKeyChainService;

/*!
 *  @class RLAKeyChain
 *
 *  @abstract Interface between the Apple KeyChain and the Relayr framework.
 *  @discussion Apple's KeyChain is a simple dictionary where the objects you want to store must be of <code>NSData</code> type. In this class, we simplify things by asking for objects that support the <code>NSCoding</code> protocol and then transforming that object into an <code>NSData</code> binary.
 */
@interface RLAKeyChain : NSObject

/*!
 *  @method objectForKey:
 *
 *  @abstract It retrieves an object for the provided key from the KeyChain.
 *  @discussion If unsuccessful, it returns <code>nil</code>.
 *
 *  @param key <code>NSString</code> key that should be used to look up the value in the KeyChain.
 *	@return <code>NSObject</code> or <code>nil</code>.
 */
+ (NSObject <NSCoding>*)objectForKey:(NSString*)key;

/*!
 *  @method setObject:forKey:
 *
 *  @abstract It stores an object for the provided key in the KeyChain.
 *  @discussion Existing data will be overwritten.
 *
 *  @param obj <code>NSObject</code> to be stored in the KeyChain.
 *  @param key <code>NSString</code> to use as a key.
 */
+ (void)setObject:(NSObject <NSCoding>*)obj forKey:(NSString*)key;

/*!
 *  @method removeObjectForKey:
 *
 *  @abstract It removes an object assigned to the provided key from the KeyChain.
 *  @discussion If the object was not there, no operation is performed.
 *
 *  @param key <code>NSString</code> with the key for which the stored value should be erased.
 */
+ (void)removeObjectForKey:(NSString*)key;

@end
