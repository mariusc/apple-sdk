#import "RLAWebService+Publisher.h" // Header
#import "RLAWebService+Parsing.h"   // Relayr.framework (Protocols/Web)

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RLAWebRequest.h"           // Relayr.framework (Protocols/Web)
#import "RLAWebConstants.h"         // Relayr.framework (Protocols/Web)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)

@implementation RLAWebService (Publisher)

#pragma mark - Public API

+ (void)requestAllRelayrPublishers:(void (^)(NSError* error, NSSet* publishers))completion
{
    if (!completion) { return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:Web_Host];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_Publishers;
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSArray* json = processRequest(Web_RequestResponseCode_Publishers, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in result)
        {
            RelayrPublisher* pub = [RLAWebService parsePublisherFromJSONDictionary:dict];
            if (pub) { [result addObject:pub]; }
        }
        
        return completion(nil, (result.count) ? [NSSet setWithSet:result] : nil);
    }];
}

- (void)registerPublisherWithName:(NSString*)publisherName ownerID:(NSString*)ownerID completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion
{
    if (!publisherName.length || !ownerID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_PublisherRegistration;
    request.body = @{ Web_RequestBodyKey_PublisherName : publisherName, Web_RequestBodyKey_PublisherOwner : ownerID };
    
    [request executeInHTTPMode:kRLAWebRequestModePOST completion:(!completion) ? nil : ^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_PublisherRegistration, nil);
        
        RelayrPublisher* result = [RLAWebService parsePublisherFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)requestPublisher:(NSString*)publisherID completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion
{
    if (!completion) { return; }
    if (!publisherID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_Publisher(publisherID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError *error, NSNumber *responseCode, NSData *data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_Publisher, nil);
        
        RelayrPublisher* result = [RLAWebService parsePublisherFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)setPublisher:(NSString*)publisherID withName:(NSString*)futurePublisherName completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion
{
    if (!publisherID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict[Web_RequestBodyKey_PublisherName] = futurePublisherName;
    if (!tmpDict.count) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    request.relativePath = Web_RequestRelativePath_PublisherSet(publisherID);
    request.body = [NSDictionary dictionaryWithDictionary:tmpDict];
    
    [request executeInHTTPMode:kRLAWebRequestModePATCH completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSDictionary* json = processRequest(Web_RequestResponseCode_PublisherSet, nil);
        
        RelayrPublisher* result = [RLAWebService parsePublisherFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
}

- (void)deletePublisher:(NSString*)publisherID completion:(void (^)(NSError* error))completion
{
    if (!publisherID.length) { if (completion) { completion(RelayrErrorMissingArgument); }return; }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure); }
    request.relativePath = Web_RequestRelativePath_PublishersDelete(publisherID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:(!completion) ? nil : ^(NSError* error, NSNumber* responseCode, NSData* data) {
        if (error) { return completion(error); }
        return completion((responseCode.unsignedIntegerValue!=Web_RequestResponseCode_PublishersApps) ? RelayrErrorWebRequestFailure : nil);
    }];
}

- (void)requestAppsFromPublisher:(NSString*)publisherID completion:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    if (!publisherID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_PublishersApps(publisherID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_PublishersApps, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrApp* app = [RLAWebService parseAppFromJSONDictionary:dict];
            if (app) { [result addObject:app]; }
        }
        
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

- (void)requestAppsWithExtendedInfoFromPublisher:(NSString*)publisherID completion:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    if (!publisherID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    RLAWebRequest* request = [[RLAWebRequest alloc] initWithHost:self.hostString timeout:nil oauthToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }
    request.relativePath = Web_RequestRelativePath_PublishersAppsEx(publisherID);
    
    [request executeInHTTPMode:kRLAWebRequestModeGET completion:^(NSError* error, NSNumber* responseCode, NSData* data) {
        NSArray* json = processRequest(Web_RequestResponseCode_PublishersAppsEx, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json)
        {
            RelayrApp* app = [RLAWebService parseAppFromJSONDictionary:dict];
            if (app) { [result addObject:app]; }
        }
        
        return completion(nil, [NSSet setWithSet:result]);
    }];
}

@end
