#import "RelayrUser.h"                  // Header

#import "RelayrApp.h"                   // Relayr.framework (Public)
#import "RelayrTransmitter.h"           // Relayr.framework (Public)
#import "RelayrDevice.h"                // Relayr.framework (Public)
#import "RelayrPublisher.h"             // Relayr.framework (Public)

#import "RelayrUser_Setup.h"            // Relayr.framework (Private)
#import "RelayrPublisher_Setup.h"       // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h"     // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"          // Relayr.framework (Private)

#import "RLAWebService.h"               // Relayr.framework (Web)
#import "RLAWebService+User.h"          // Relayr.framework (Web)
#import "RLAWebService+Transmitter.h"   // Relayr.framework (Web)
#import "RLAWebService+Device.h"        // Relayr.framework (Web)
#import "RelayrErrors.h"                    // Relayr.framework (Utilities)

static NSString* const kCodingToken = @"tok";
static NSString* const kCodingID = @"uid";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingEmail = @"ema";
static NSString* const kCodingTransmitters = @"tra";
static NSString* const kCodingDevices = @"dev";
static NSString* const kCodingBookmarks = @"bok";
static NSString* const kCodingApps = @"app";
static NSString* const kCodingPublishers = @"pub";

@implementation RelayrUser

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(instancetype)initWithToken:(NSString*)token
{
    if (!token.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _token = token;
        _webService = [[RLAWebService alloc] initWithUser:self];
    }
    return self;
}

- (void)queryCloudForUserInfo:(void (^)(NSError* error, NSString* previousName, NSString* previousEmail))completion
{
    __weak RelayrUser* weakSelf = self;
    [_webService requestUserInfo:^(NSError* error, NSString* uid, NSString* name, NSString* email) {
        if (error) { if (completion) { completion(error, nil, nil); } return; }
        if (!uid.length) { if (completion) { completion(RelayrErrorWrongRelayrUser, nil, nil); } return; }
        
        __strong RelayrUser* strongSelf = weakSelf;
        if (!strongSelf.uid)
        {
            strongSelf.uid = uid;
        }
        else if ( ![strongSelf.uid isEqualToString:uid] )
        {
            if (completion) { completion(RelayrErrorWrongRelayrUser, nil, nil); }
            return;
        }
        
        NSString* pName = strongSelf.name, * pEmail = strongSelf.email;
        strongSelf.name = name; strongSelf.email = email;
        if (completion) { completion(nil, pName, pEmail); }
    }];
}

- (void)queryCloudForIoTs:(void (^)(NSError* error, NSNumber* isThereChanges))completion
{
    __weak RelayrUser* weakSelf = self;
    [_webService requestUserTransmitters:^(NSError* transmitterError, NSArray* transmitters) {
        if (transmitterError) { if (completion) { completion(transmitterError, nil); } return; }
        [weakSelf.webService requestUserDevices:^(NSError* deviceError, NSArray* devices) {
            if (deviceError) { if (completion) { completion(deviceError, nil); } return ; }
            [weakSelf.webService requestUserBookmarkedDevices:^(NSError* bookmarkError, NSArray* bookDevices) {
                if (bookmarkError) { if (completion) { completion(bookmarkError, nil); } return; }
                BOOL const result = [weakSelf setUsersIoTsFromServerTransmitterArray:transmitters deviceArray:devices bookmarkDeviceArray:bookDevices];
                if (completion) { completion(nil, [NSNumber numberWithBool:result]); }
            }];
        }];
    }];
}

- (void)queryCloudForPublishersAndAuthorisedApps:(void (^)(NSError* error, NSNumber* isThereChanges))completion
{
    __weak RelayrUser* weakSelf = self;
    [_webService requestUserAuthorisedApps:^(NSError *appError, NSArray *apps) {
        if (appError) { if (completion) { completion(appError, nil); } return; }
        [weakSelf.webService requestUserPublishers:^(NSError* publisherError, NSArray* publishers) {
            if (publisherError) { if (completion) { completion(publisherError, nil); } return; }
            BOOL const result = [weakSelf setUsersAppsFromServerArray:apps publishersFrom:publishers];
            if (completion) { completion(nil, [NSNumber numberWithBool:result]); }
        }];
    }];
}

- (void)registerTransmitterWithModelID:(NSString*)modelID firmwareVerion:(NSString*)firmwareVersion name:(NSString*)name completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    if (!name) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    __weak RelayrUser* weakSelf = self;
    [_webService registerTransmitterWithName:name ownerID:_uid model:modelID firmwareVersion:firmwareVersion completion:^(NSError* error, RelayrTransmitter* transmitter) {
        if (error) { if (completion) { completion(error, nil); } return; }
        [weakSelf addTransmitter:transmitter];
        if (completion) { completion(nil, transmitter); }
    }];
}

- (void)registerDeviceWithModelID:(NSString*)modelID firmwareVerion:(NSString*)firmwareVersion name:(NSString*)name completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!modelID || !firmwareVersion || !name) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    __weak RelayrUser* weakSelf = self;
    [_webService registerDeviceWithName:name owner:_uid model:modelID firmwareVersion:firmwareVersion completion:^(NSError* error, RelayrDevice* device) {
        if (error) { if (completion) { completion(error, nil); } return; }
        [weakSelf addDevice:device];
        if (completion) { completion(nil, device); }
    }];
}

- (void)addTransmitter:(RelayrTransmitter*)transmitter
{
    if (!_transmitters)
    {
        _transmitters = [NSSet setWithObject:transmitter];
    }
    else
    {
        NSString* transmitterID = transmitter.uid;
        for (RelayrTransmitter* storedTransmitter in _transmitters)
        {
            if (storedTransmitter.uid == transmitterID) { return [storedTransmitter setWith:transmitter]; }
        }
        
        NSMutableSet* tmpSet = [NSMutableSet setWithSet:_transmitters];
        [tmpSet addObject:transmitter];
        _transmitters = [NSSet setWithSet:tmpSet];
    }
}

- (void)addDevice:(RelayrDevice*)device
{
    if (!_devices)
    {
        _devices = [NSSet setWithObject:device];
    }
    else
    {
        NSString* deviceID = device.uid;
        for (RelayrDevice* storedDevice in _devices)
        {
            if (storedDevice.uid == deviceID) { return [storedDevice setWith:device]; }
        }
        
        NSMutableSet* tmpSet = [NSMutableSet setWithSet:_devices];
        [tmpSet addObject:device];
        _devices = [NSSet setWithSet:tmpSet];
    }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithToken:[decoder decodeObjectForKey:kCodingToken]];
    if (self)
    {
        _uid = [decoder decodeObjectForKey:kCodingID];
        _name = [decoder decodeObjectForKey:kCodingName];
        _email = [decoder decodeObjectForKey:kCodingEmail];
        _transmitters = [decoder decodeObjectForKey:kCodingTransmitters];
        _devices = [decoder decodeObjectForKey:kCodingDevices];
        _devicesBookmarked = [decoder decodeObjectForKey:kCodingDevices];
        _authorisedApps = [decoder decodeObjectForKey:kCodingApps];
        _publishers = [decoder decodeObjectForKey:kCodingPublishers];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_token forKey:kCodingToken];
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_email forKey:kCodingEmail];
    [coder encodeObject:_transmitters forKey:kCodingTransmitters];
    [coder encodeObject:_devices forKey:kCodingDevices];
    [coder encodeObject:_devicesBookmarked forKey:kCodingBookmarks];
    [coder encodeObject:_authorisedApps forKey:kCodingApps];
    [coder encodeObject:_publishers forKey:kCodingPublishers];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"Relayr User:\n{\n\t ID:\t%@\n\t Token:\t%@\n\t Name:\t%@\n\t Email:\t%@\n\t Number of transmitters:\t\t%@\n\t Number of devices:\t\t\t\t%@\n\t Number of bookmarked devices:\t%@\n\t Number of publishers under this user:\t%@\n}", _uid, _token, _name, _email, (!_transmitters) ? @"?" : [NSString stringWithFormat:@"%lu", (unsigned long)_transmitters.count], (!_devices) ? @"?" : [NSString stringWithFormat:@"%lu", (unsigned long)_devices.count], (!_devicesBookmarked) ? @"?" : [NSString stringWithFormat:@"%lu", (unsigned long)_devicesBookmarked.count], (!_publishers) ? @"?" : [NSString stringWithFormat:@"%lu", (unsigned long)_publishers.count]];
}

#pragma mark - Private methods

/*******************************************************************************
 * It sets the user's IoTs with the server query.
 * If there were previous transmitters, devices, or bookmarks, those are removed.
 ******************************************************************************/
- (BOOL)setUsersIoTsFromServerTransmitterArray:(NSArray*)serverTransmitters deviceArray:(NSArray*)serverDevices bookmarkDeviceArray:(NSArray*)serverBookmarks
{
    BOOL isThereChanges = NO;
    
    // TODO: Fill up
    
    return isThereChanges;
}

/*******************************************************************************
 * It sets the user's applications and publishers with the server query.
 * If there were previous apps or publishers; those are removed.
 ******************************************************************************/
- (BOOL)setUsersAppsFromServerArray:(NSArray*)serverApps publishersFrom:(NSArray*)serverPublishers
{
    BOOL isThereChanges = NO;
    
    // TODO: Fill up
    
    return isThereChanges;
}

@end
