#import "RelayrUser.h"                  // Header

#import "RelayrApp.h"                   // Relayr.framework (Public)
#import "RelayrTransmitter.h"           // Relayr.framework (Public)
#import "RelayrDevice.h"                // Relayr.framework (Public)
#import "RelayrPublisher.h"             // Relayr.framework (Public)

#import "RelayrApp_Setup.h"             // Relayr.framework (Private)
#import "RelayrUser_Setup.h"            // Relayr.framework (Private)
#import "RelayrPublisher_Setup.h"       // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h"     // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"          // Relayr.framework (Private)

#import "RLAWebService.h"               // Relayr.framework (Web)
#import "RLAWebService+User.h"          // Relayr.framework (Web)
#import "RLAWebService+Transmitter.h"   // Relayr.framework (Web)
#import "RLAWebService+Device.h"        // Relayr.framework (Web)
#import "RelayrErrors.h"                // Relayr.framework (Utilities)
#import "RLALog.h"                      // Relayr.framework (Utilities)

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
        if (!strongSelf.uid) { strongSelf.uid = uid; }
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

- (void)queryCloudForIoTs:(void (^)(NSError*))completion
{
    [RLALog debug:@"Start the queryCloudForIoT: method..."];
    
    __weak RelayrUser* weakSelf = self;
    [_webService requestUserTransmitters:^(NSError* transmitterError, NSSet* transmitters) {
        if (transmitterError) { if (completion) { completion(transmitterError); } return; }
        [RLALog debug:@"Transmitters received"];
        [weakSelf.webService requestUserDevices:^(NSError* deviceError, NSSet* devices) {
            if (deviceError) { if (completion) { completion(deviceError); } return ; }
            [RLALog debug:@"Devices received"];
            [weakSelf.webService requestUserBookmarkedDevices:^(NSError* bookmarkError, NSSet* devicesBookmarked) {
                if (bookmarkError) { if (completion) { completion(bookmarkError); } return; }
                [RLALog debug:@"Devices bookmarked received"];
                [weakSelf processIoTTreeWithTransmitters:transmitters devices:devices bookmarkDevices:devicesBookmarked completion:completion];
            }];
        }];
    }];
}

- (void)queryCloudForPublishersAndAuthorisedApps:(void (^)(NSError* error))completion
{
    __weak RelayrUser* weakSelf = self;
    [_webService requestUserAuthorisedApps:^(NSError* appError, NSSet* apps) {
        if (appError) { if (completion) { completion(appError); } return; }
        [weakSelf.webService requestUserPublishers:^(NSError* publisherError, NSSet* publishers) {
            if (publisherError) { if (completion) { completion(publisherError); } return; }
            [self replaceAuthorisedApps:apps];
            [self replacePublishers:publishers];
            if (completion) { completion(nil); }
        }];
    }];
}

- (void)registerTransmitterWithModelID:(NSString*)modelID firmwareVerion:(NSString*)firmwareVersion name:(NSString*)name completion:(void (^)(NSError* error, RelayrTransmitter* transmitter))completion
{
    if (!name) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    __weak RelayrUser* weakSelf = self;
    [_webService registerTransmitterWithName:name ownerID:_uid model:modelID firmwareVersion:firmwareVersion completion:^(NSError* error, RelayrTransmitter* transmitter) {
        if (error) { if (completion) { completion(error, nil); } return; }
        RelayrTransmitter* result = [weakSelf addTransmitter:transmitter];
        if (!completion) { return; }
        return (result) ? completion(nil, result) : completion(RelayrErrorMissingExpectedValue, nil);
    }];
}

- (void)registerDeviceWithModelID:(NSString*)modelID firmwareVerion:(NSString*)firmwareVersion name:(NSString*)name completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!modelID || !firmwareVersion || !name) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    __weak RelayrUser* weakSelf = self;
    [_webService registerDeviceWithName:name owner:_uid model:modelID firmwareVersion:firmwareVersion completion:^(NSError* error, RelayrDevice* device) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        RelayrDevice* futureDevice = [weakSelf addDevice:device];
        if (!completion) { return; }
        return (futureDevice) ? completion(nil, futureDevice) : completion(RelayrErrorMissingExpectedValue, nil);
    }];
}

- (RelayrTransmitter*)addTransmitter:(RelayrTransmitter*)transmitter
{
    if (!transmitter) { return nil; }
    
    // Devices need to be added first.
    if (transmitter.devices.count)
    {
        NSMutableSet* transmitterDevices = [[NSMutableSet alloc] initWithCapacity:transmitter.devices.count];
        for (RelayrDevice* tmpDevice in transmitter.devices)
        {
            RelayrDevice* device = [self addDevice:tmpDevice];
            if (device) { [transmitterDevices addObject:device]; }
        }
        transmitter.devices = [NSSet setWithSet:transmitterDevices];
    }
    
    // Then the transmitter is check for existance.
    if (_transmitters)
    {
        RelayrTransmitter* matchedTransmitter;
        NSString* transmitterID = transmitter.uid;
        for (RelayrTransmitter* previousTransmitter in _transmitters)
        {
            if (previousTransmitter.uid == transmitterID) { matchedTransmitter = previousTransmitter; break; }
        }
        
        if (!matchedTransmitter)
        {
            NSMutableSet* tmpSet = [NSMutableSet setWithSet:_transmitters];
            [tmpSet addObject:transmitter];
            _transmitters = [NSSet setWithSet:tmpSet];
        }
        else { [matchedTransmitter setWith:transmitter]; return matchedTransmitter; }
    }
    else { _transmitters = [NSSet setWithObject:transmitter]; }
    
    return transmitter;
}

- (RelayrDevice*)addDevice:(RelayrDevice*)device
{
    if (!device) { return nil; }
    
    if (_devices)
    {
        NSString* deviceID = device.uid;
        for (RelayrDevice* previousDevice in _devices)
        {
            if (previousDevice.uid == deviceID) { [previousDevice setWith:device]; return previousDevice; }
        }
        
        NSMutableSet* tmpSet = [NSMutableSet setWithSet:_devices];
        [tmpSet addObject:device];
        _devices = [NSSet setWithSet:tmpSet];
    }
    else { _devices = [NSSet setWithObject:device]; }
    
    return device;
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
- (void)processIoTTreeWithTransmitters:(NSSet*)transmitters devices:(NSSet*)devices bookmarkDevices:(NSSet*)bookDevices completion:(void (^)(NSError*))completion
{
    if (bookDevices.count)
    {   // There could be bookmark devices that are not devices owned by this user
        [RLALog debug:@"There were bookmarked devices. Hooking them up to the tree..."];
        NSMutableSet* bookResult = [[NSMutableSet alloc] initWithCapacity:bookDevices.count];
        for (RelayrDevice* bookDevice in bookDevices)
        {
            RelayrDevice* selectedDevice;
            NSString* bookID = bookDevice.uid;
            
            for (RelayrDevice* dev in devices)
            {
                if ([dev.uid isEqualToString:bookID]) { selectedDevice = dev; break; }
            }
            
            if (!selectedDevice) { selectedDevice = bookDevice; }
            [bookResult addObject:selectedDevice];
        }
        bookDevices = [NSSet setWithSet:bookResult];
        [RLALog debug:@"Bookmarked devices on tree!"];
    }
    
    if (transmitters.count == 0)
    {
        [RLALog debug:@"There are no transmitters. Thus the tree is completed and set up."];
        _transmitters = transmitters;
        _devices = devices;
        _devicesBookmarked = bookDevices;
        if (completion) { completion(nil); }
        return;
    }
    
    __block NSError* error;
    __block NSUInteger count = transmitters.count;  // Be careful with race conditions (main thread only, so far).
    [RLALog debug:@"There are %lu transmitters", transmitters.count];
    
    __weak RelayrUser* weakSelf = self;
    void (^flagChecker)(NSError*, RelayrTransmitter*, NSSet*) = ^(NSError* connectedError, RelayrTransmitter* transmitter, NSSet* transDevices){
        if (!error)
        {
            if (!connectedError)
            {
                NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:transDevices.count];
                for (RelayrDevice* tDevice in transDevices)
                {
                    NSString* tDevID = tDevice.uid;
                    for (RelayrDevice* dev in devices)
                    {
                        if ([dev.uid isEqualToString:tDevID]) { [result addObject:dev]; break; }
                    }
                }
                transmitter.devices = [NSSet setWithSet:result];
            }
            else { error = connectedError; }
        }
        
        count = count - 1;
        [RLALog debug:@"%lu transmitter remainings...", count];
        if (count == 0)
        {
            [RLALog debug:@"Setting up final tree..."];
            if (error) { if (completion) { completion(error); } return; }
            
            __strong RelayrUser* strongSelf = weakSelf;
            if (!strongSelf) { return; }
            
            strongSelf.transmitters = transmitters;
            strongSelf.devices = devices;
            strongSelf.devicesBookmarked = bookDevices;
            [RLALog debug:@"Setup done!"];
            if (completion) { completion(nil); }
        }
    };
    
    for (RelayrTransmitter* transmitter in transmitters)
    {
        [RLALog debug:@"Asking for transmitter's devices"];
        [_webService requestDevicesFromTransmitter:transmitter.uid completion:^(NSError* error, NSSet* devices) {
            flagChecker(error, transmitter, devices);
        }];
    }
}

/*******************************************************************************
 * It replaces/set the current authorised apps with a new set of authorised apps.
 * If <code>apps</code> is <code>nil</code>, the authorisedApps are unknown and thus no further work is performed.
 * If <code>apps</code> is an empty set, there are no authorised apps.
 * If <code>apps</code> contains <code>RelayrApp</code> objects, a replacing process will be launched.
 ******************************************************************************/
- (void)replaceAuthorisedApps:(NSSet*)apps
{
    if (!apps) { return; }
    else if (apps.count == 0) { _authorisedApps = [[NSSet alloc] init]; return; }
    else if (_authorisedApps.count == 0) { _authorisedApps = apps; return; }
    
    NSMutableSet* result = [[NSMutableSet alloc] init];
    for (RelayrApp* app in apps)
    {
        NSString* futureID = app.uid;
        BOOL matchedApp = NO;
        
        for (RelayrApp* previousApp in _authorisedApps)
        {
            if ([previousApp.uid isEqualToString:futureID])
            {
                [previousApp setWith:app];
                [result addObject:previousApp];
                matchedApp = YES;
                break;
            }
        }
        
        if (!matchedApp) { [result addObject:app]; }
    }
    
    if (result.count == 0) { _authorisedApps = [[NSSet alloc] init]; }
    else { _authorisedApps = [NSSet setWithSet:result]; }
}

/*******************************************************************************
 * It replaces/set the current publishers with a new set of publishers
 * If <code>publisher</code> is <code>nil</code>, the publishers are unknown and thus no further work is performed.
 * If <code>publisher</code> is an empty set, there are no publishers.
 * If <code>publisher</code> contains <code>RelayrApp</code> objects, a replacing process will be launched.
 ******************************************************************************/
- (void)replacePublishers:(NSSet*)publishers
{
    if (!publishers) { return; }
    else if (publishers.count == 0) { _publishers = [[NSSet alloc] init]; return; }
    else if (_publishers.count == 0) { _publishers = publishers; return; }
    
    NSMutableSet* result = [[NSMutableSet alloc] init];
    
    for (RelayrPublisher* publisher in publishers)
    {
        NSString* futureID = publisher.uid;
        BOOL matchedPublisher = NO;
        
        for (RelayrPublisher* previousPublisher in _authorisedApps)
        {
            if ([previousPublisher.uid isEqualToString:futureID])
            {
                [previousPublisher setWith:publisher];
                [result addObject:previousPublisher];
                matchedPublisher = YES;
                break;
            }
        }
        
        if (!matchedPublisher) { [result addObject:publisher]; }
    }
    
    if (result.count == 0) { _publishers = [[NSSet alloc] init]; }
    else { _publishers = [NSSet setWithSet:result]; }
}

@end
