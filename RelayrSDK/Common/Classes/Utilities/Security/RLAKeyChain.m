#import "RLAKeyChain.h"

@implementation RLAKeyChain

#pragma mark - Public API

+ (NSObject*)objectForKey:(NSString*)key
{
    RLAErrorAssertTrueAndReturnNil(key, RLAErrorCodeMissingArgument);
    
    // Build keychain query dictionary
    NSDictionary* tmpDict = [RLAKeyChain keychainQueryWithKey:key];
    RLAErrorAssertTrueAndReturnNil(tmpDict, RLAErrorCodeMissingExpectedValue);
    
    NSMutableDictionary* queryDict = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
    RLAErrorAssertTrueAndReturnNil(queryDict, RLAErrorCodeMissingExpectedValue);
    
    // Append fetch parameters
    queryDict[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    queryDict[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    // Fetch data from keychain
    NSObject* object = nil;
    CFDataRef keyData = NULL;
    CFDictionaryRef dict = (__bridge CFDictionaryRef)queryDict;
    OSStatus success = SecItemCopyMatching(dict, (CFTypeRef*)&keyData);
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
    RLAErrorAssertTrueAndReturn(object, RLAErrorCodeMissingArgument);
    RLAErrorAssertTrueAndReturn(key, RLAErrorCodeMissingArgument);
    
    // Delete any previously stored value
    NSDictionary* queryDict = [RLAKeyChain keychainQueryWithKey:key];
    RLAErrorAssertTrueAndReturn(queryDict, RLAErrorCodeMissingExpectedValue);
    SecItemDelete((__bridge CFDictionaryRef)queryDict);
    
    // Append data which should be stored to query dictionary
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:object];
    RLAErrorAssertTrueAndReturn(data, RLAErrorCodeMissingExpectedValue);
    NSMutableDictionary* mQueryDict = [queryDict mutableCopy];
    RLAErrorAssertTrueAndReturn(mQueryDict, RLAErrorCodeMissingExpectedValue);
    mQueryDict[(__bridge id)kSecValueData] = data;
    SecItemAdd((__bridge CFDictionaryRef)mQueryDict, NULL);
}

+ (void)removeObjectForKey:(NSString *)key
{
    // Check arguments
    RLAErrorAssertTrueAndReturn(key, RLAErrorCodeMissingArgument);
    
    // Delete stored value
    NSDictionary* queryDict = [RLAKeyChain keychainQueryWithKey:key];
    RLAErrorAssertTrueAndReturn(queryDict, RLAErrorCodeMissingExpectedValue);
    SecItemDelete((__bridge CFDictionaryRef)queryDict);
}

#pragma mark - Private methods

+ (NSDictionary *)keychainQueryWithKey:(NSString *)key
{
    NSDictionary *queryDict =
    @{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
      (__bridge id)kSecAttrGeneric : key};
    return queryDict;
}

@end
