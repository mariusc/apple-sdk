#import "RLAWebService+App.h"   // Header
#import "RLAWebRequest.h"       // Relayr.framework (Web)
#import "RLAWebConstants.h"     // Relayr.framework (Web)
#import "RLAError.h"            // Relayr.framework (Utilities)

@implementation RLAWebService (App)

+ (void)requestAppInfoFor:(NSString*)appID completion:(void (^)(NSError*, NSString*, NSString*, NSString*))completion
{
    if (!completion) { return; }
    if (!appID.length) { return completion(RLAErrorMissingArgument, nil, nil, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHostURL:[NSURL URLWithString:Web_Host]];
    request.relativePath = Web_RequestRelativePath_AppInfo(appID);
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_AppInfo, nil, nil, nil);
        completion(nil, json[Web_RespondKey_AppID], json[Web_RespondKey_AppName], json[Web_RespondKey_AppDescription]);
    }];
}

@end
