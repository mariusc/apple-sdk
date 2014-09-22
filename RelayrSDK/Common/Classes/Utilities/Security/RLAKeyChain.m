#import "RLAKeyChain.h"     // Header
#import "RelayrErrors.h"    // Relayr.framework (Utilities)
#import "RLALog.h"          // Relayr.framework (Utilities)

NSString* const kRLAKeyChainService = @"io.relayr.framework";

@implementation RLAKeyChain

#pragma mark - Public API

+ (NSObject <NSCoding>*)objectForKey:(NSString*)key
{
    if (!key) { [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; return nil; }
    
    // Build keychain query dictionary (the key identifying the data stored is added to the query)
    NSMutableDictionary* queryDict = [NSMutableDictionary dictionaryWithDictionary:[RLAKeyChain keychainQueryWithKey:key]];
    
    // Append fetch parameters
    queryDict[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    queryDict[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    
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
    if (!key || !object) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    
    // Delete any previously stored value
    NSDictionary* queryDict = [RLAKeyChain keychainQueryWithKey:key];
    SecItemDelete((__bridge CFDictionaryRef)queryDict);
    
    // Append data which should be stored to query dictionary
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:object];
    if (!data) { return [RLALog debug:RelayrErrorMissingExpectedValue.localizedDescription]; }
    
    NSMutableDictionary* mutableQuery = queryDict.mutableCopy;
    mutableQuery[(__bridge id)kSecValueData] = data;
    OSStatus const addStatus = SecItemAdd((__bridge CFDictionaryRef)[NSDictionary dictionaryWithDictionary:mutableQuery], NULL);
    
    if (addStatus != errSecSuccess) { [RLALog debug:RelayrErrorMissingExpectedValue.localizedDescription]; }
}

+ (void)removeObjectForKey:(NSString *)key
{
    // Check arguments
    if (!key) { return [RLALog debug:RelayrErrorMissingArgument.localizedDescription]; }
    
    // Delete stored value
    SecItemDelete((__bridge CFDictionaryRef)[RLAKeyChain keychainQueryWithKey:key]);
}

#pragma mark - Private methods

+ (NSDictionary*)keychainQueryWithKey:(NSString*)key
{
    return @{
        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword, // The class of the KeyChain Item we will be storing/removing
        (__bridge id)kSecAttrService : kRLAKeyChainService,
        (__bridge id)kSecAttrAccount : key,
        (__bridge id)kSecAttrGeneric : key
    };
}

@end
