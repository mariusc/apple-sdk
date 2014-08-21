#import "RLAKeyChain.h"     // Header
#import "RLAError.h"        // Relayr.framework
#import "RLALog.h"          // Relayr.framework

NSString* const kRLAKeyChainUserTokens = @"Relayr.userTokens";

@implementation RLAKeyChain

#pragma mark - Public API

+ (NSObject <NSCoding>*)objectForKey:(NSString*)key
{
    if (!key)
    {
        [RLALog error:RLAErrorMessageMissingArgument];
        return nil;
    }
    
    // Build keychain query dictionary (the key identifying the data stored is added to the query)
    NSMutableDictionary* queryDict = [NSMutableDictionary dictionaryWithDictionary:[RLAKeyChain keychainQueryWithKey:key]];
    
    // Append fetch parameters
    queryDict[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    queryDict[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    // Fetch data from keychain
    CFDataRef keyData = NULL;
    OSStatus const success = SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, (CFTypeRef*)&keyData);
    
    NSObject <NSCoding>* object = nil;
    if (success == noErr)
    {   // Convert data to string
        object = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
    }
    
    if (keyData) { CFRelease(keyData); }
    return object;
}

+ (void)setObject:(NSObject <NSCoding>*)object forKey:(NSString*)key
{
    // Check arguments
    if (!key || !object) { return [RLALog error:RLAErrorMessageMissingArgument]; }
    
    // Delete any previously stored value
    NSDictionary* queryDict = [RLAKeyChain keychainQueryWithKey:key];
    SecItemDelete((__bridge CFDictionaryRef)queryDict);
    
    // Append data which should be stored to query dictionary
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:object];
    if (!data) { return [RLALog error:RLAErrorMessageMissingExpectedValue]; }
    
    NSMutableDictionary* mutableQuery = queryDict.mutableCopy;
    mutableQuery[(__bridge id)kSecValueData] = data;
    SecItemAdd((__bridge CFDictionaryRef)mutableQuery.copy, NULL);
}

+ (void)removeObjectForKey:(NSString *)key
{
    // Check arguments
    if (!key) { return [RLALog error:RLAErrorMessageMissingArgument]; }
    
    // Delete stored value
    SecItemDelete((__bridge CFDictionaryRef)[RLAKeyChain keychainQueryWithKey:key]);
}

#pragma mark - Private methods

+ (NSDictionary*)keychainQueryWithKey:(NSString*)key
{
    return @{
        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrGeneric : key
    };
}

@end
