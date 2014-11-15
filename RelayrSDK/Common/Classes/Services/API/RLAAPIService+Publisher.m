#import "RLAAPIService+Publisher.h" // Header

#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrPublisher.h"         // Relayr.framework (Public)
#import "RLAAPIConstants.h"         // Relayr.framework (Service/API)
#import "RLAAPIService+Parsing.h"   // Relayr.framework (Service/API)
#import "RelayrErrors.h"            // Relayr.framework (Utilities)

@implementation RLAAPIService (Publisher)

#pragma mark - Public API

+ (void)requestAllRelayrPublishers:(void (^)(NSError* error, NSSet* publishers))completion
{
    if (!completion) { return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:dRLAAPI_Host relativeString:dRLAAPI_PublishersCloud_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:nil];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_PublishersCloud_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in result) { RelayrPublisher* pub = [RLAAPIService parsePublisherFromJSONDictionary:dict]; if (pub) { [result addObject:pub]; } }
        return completion(nil, (result.count) ? [NSSet setWithSet:result] : nil);
    }];
    [task resume];
}

- (void)registerPublisherWithName:(NSString*)publisherName ownerID:(NSString*)ownerID completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion
{
    if (!publisherName.length || !ownerID.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_PublisherRegistration_RelativePath];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePOST authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }
    
    NSDictionary* body = @{ dRLAAPI_Publisher_RequestKey_Name : publisherName, dRLAAPI_Publisher_RequestKey_Owner : ownerID };
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError, nil); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_PublisherRegistration_ResponseCode, nil);
        
        RelayrPublisher* result = [RLAAPIService parsePublisherFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)requestPublisher:(NSString*)publisherID completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion
{
    if (!completion) { return; }
    if (!publisherID.length) { return completion(RelayrErrorMissingArgument, nil); }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_PublisherInfo_RelativePath(publisherID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_PublisherInfo_ResponseCode, nil);
        
        RelayrPublisher* result = [RLAAPIService parsePublisherFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)setPublisher:(NSString*)publisherID withName:(NSString*)futurePublisherName completion:(void (^)(NSError* error, RelayrPublisher* publisher))completion
{
    if (!publisherID.length || !futurePublisherName.length) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_PublisherSet_RelativePath(publisherID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModePATCH authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure, nil); } return; }

    NSDictionary* body = @{ dRLAAPI_Publisher_RequestKey_Name : futurePublisherName };
    
    NSError* serializationError;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&serializationError];
    if (serializationError) { if (completion) { completion(serializationError, nil); } return; }
    [request setValue:dRLAAPIRequest_HeaderValue_ContentType_JSON forHTTPHeaderField:dRLAAPIRequest_HeaderField_ContentType];
    request.HTTPBody = jsonData;
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* json = RLAAPI_processHTTPresponse(dRLAAPI_PublisherSet_ResponseCode, nil);
        
        RelayrPublisher* result = [RLAAPIService parsePublisherFromJSONDictionary:json];
        return (!result) ? completion(RelayrErrorRequestParsingFailure, nil) : completion(nil, result);
    }];
    [task resume];
}

- (void)deletePublisher:(NSString*)publisherID completion:(void (^)(NSError* error))completion
{
    if (!publisherID.length) { if (completion) { completion(RelayrErrorMissingArgument); }return; }

    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_PublisherDelete_RelativePath(publisherID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { if (completion) { completion(RelayrErrorWebRequestFailure); } return; }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) { return completion(error); }
        return completion( (((NSHTTPURLResponse*)response).statusCode!=dRLAAPI_PublisherDelete_ResponseCode) ? RelayrErrorWebRequestFailure : nil );
    }];
    [task resume];
}

- (void)requestAppsFromPublisher:(NSString*)publisherID completion:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    if (!publisherID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_PublisherApps_RelativePath(publisherID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_PublisherApps_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrApp* app = [RLAAPIService parseAppFromJSONDictionary:dict]; if (app) { [result addObject:app]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

- (void)requestAppsWithExtendedInfoFromPublisher:(NSString*)publisherID completion:(void (^)(NSError* error, NSSet* apps))completion
{
    if (!completion) { return; }
    if (!publisherID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    NSURL* absoluteURL = [RLAAPIService buildAbsoluteURLFromHost:self.hostString relativeString:dRLAAPI_PublisherGetExtended_RelativePath(publisherID)];
    NSMutableURLRequest* request = [RLAAPIService requestForURL:absoluteURL HTTPMethod:kRLAAPIRequestModeGET authorizationToken:self.user.token];
    if (!request) { return completion(RelayrErrorWebRequestFailure, nil); }

    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSArray* json = RLAAPI_processHTTPresponse(dRLAAPI_PublisherGetExtended_ResponseCode, nil);
        
        NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:json.count];
        for (NSDictionary* dict in json) { RelayrApp* app = [RLAAPIService parseAppFromJSONDictionary:dict]; if (app) { [result addObject:app]; } }
        return completion(nil, [NSSet setWithSet:result]);
    }];
    [task resume];
}

@end
