#import "NSSet+RelayrID.h"      // Header
#import "RelayrID.h"            // Relayr.framework (Public)

@implementation NSSet (RelayrID)

- (id <RelayrID>)objectForKeyedSubscript:(NSString*)key
{
    if (!self.count || !key.length) { return nil; }
    
    id result;
    for (id <RelayrID> relayrObj in self)
    {
        if ( [key isEqualToString:relayrObj.uid] )
        {
            result = relayrObj;
            break;
        }
    }
    return result;
}

@end
