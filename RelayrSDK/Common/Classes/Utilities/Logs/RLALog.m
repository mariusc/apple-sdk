#import "RLALog.h" // Header

@implementation RLALog

#pragma mark - Public API

+ (void)debug:(NSString*)format, ...
{
    #ifdef DEBUG
    va_list args;
    va_start(args, format);
    NSString* msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [RLALog logWithPrefix:nil logCallStack:YES message:msg];
    #endif
}

+ (void)error:(NSString*)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [RLALog logWithPrefix:@"Error" logCallStack:YES message:msg];
}

#pragma mark - Private methods

+ (void)logWithPrefix:(NSString*)prefix logCallStack:(BOOL)logCallStack message:(NSString*)msg
{
    printf("Relayr.framework: ");
    
    if (prefix) {
        printf("%s: ", [prefix cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    if (msg) {
        printf("%s\n", [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    if (logCallStack) {
        printf("%s\n", [[NSThread callStackSymbols].description cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

@end