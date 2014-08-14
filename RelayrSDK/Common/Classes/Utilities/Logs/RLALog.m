// Header
#import "RLALog.h"

@implementation RLALog

# pragma mark - Logging (Debug)

+ (void)debug:(NSString *)format, ...
{
  #ifdef DEBUG
  
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
  
    [[self class] RLA_logWithPrefix:nil
                       logCallStack:NO
                            message:msg];
  #endif
}

# pragma mark - Logging (Error)

+ (void)error:(NSString *)format, ...
{
  va_list args;
  va_start(args, format);
  NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);
  
  [[self class] RLA_logWithPrefix:@"Error"
                     logCallStack:YES
                          message:msg];
}

# pragma mark - Private helpers

+ (void)RLA_logWithPrefix:(NSString *)prefix
             logCallStack:(BOOL)logCallStack
                  message:(NSString *)msg
{
  const char *arch = [[[self class] RLA_arch] cStringUsingEncoding:NSUTF8StringEncoding];
  printf("Relayr.framework(%s): ", arch);
  if (prefix) printf("%s: ", [prefix cStringUsingEncoding:NSUTF8StringEncoding]);
  if (msg) printf("%s\n", [msg cStringUsingEncoding:NSUTF8StringEncoding]);
  if (logCallStack) printf("%s\n", [[self class] RLA_callStackSymbols]);
}

+ (const char *)RLA_callStackSymbols
{
  NSArray *symbols = [NSThread callStackSymbols];
  NSString *str = [symbols description];
  const char *cStr = [str cStringUsingEncoding:NSUTF8StringEncoding];
  return cStr;
}

+ (NSString *)RLA_arch
{
  NSString *arch;
  #if __LP64__
    arch = @"64";
  #else
    arch = @"32";
  #endif
  
  return arch;
}

@end