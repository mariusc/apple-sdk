// Apple
@import Foundation;

@interface RLALog : NSObject

# pragma mark - Logging (Debug)

+ (void)debug:(NSString *)format, ...;

# pragma mark - Logging (Error)

+ (void)error:(NSString *)format, ...;

@end
