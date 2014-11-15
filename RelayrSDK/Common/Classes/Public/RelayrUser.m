#import "RelayrUser.h"                  // Header

#import "RelayrApp.h"                   // Relayr.framework (Public)
#import "RelayrTransmitter.h"           // Relayr.framework (Public)
#import "RelayrDevice.h"                // Relayr.framework (Public)
#import "RelayrPublisher.h"             // Relayr.framework (Public)
#import "RelayrErrors.h"                // Relayr.framework (Public)
#import "RelayrApp_Setup.h"             // Relayr.framework (Private)
#import "RelayrUser_Setup.h"            // Relayr.framework (Private)
#import "RelayrPublisher_Setup.h"       // Relayr.framework (Private)
#import "RelayrTransmitter_Setup.h"     // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"          // Relayr.framework (Private)
#import "RLAAPIService.h"               // Relayr.framework (Service/API)
#import "RLAAPIService+User.h"          // Relayr.framework (Service/API)
#import "RLAAPIService+Publisher.h"     // Relayr.framework (Service/API)
#import "RLAAPIService+Transmitter.h"   // Relayr.framework (Service/API)
#import "RLAAPIService+Device.h"        // Relayr.framework (Service/API)

static NSString* const kCodingToken = @"tok";
static NSString* const kCodingApp = @"app";
static NSString* const kCodingID = @"uid";
static NSString* const kCodingName = @"nam";
static NSString* const kCodingEmail = @"ema";
static NSString* const kCodingTransmitters = @"tra";
static NSString* const kCodingDevices = @"dev";
static NSString* const kCodingBookmarks = @"bok";
static NSString* const kCodingApps = @"AuthApp";
static NSString* const kCodingPublishers = @"pub";

@implementation RelayrUser

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setNameWith:(NSString *)name completion:(void (^)(NSError* error, NSString* previousName))completion
{
    __weak RelayrUser* weakSelf = self;
    [_apiService setUserName:name email:nil completion:^(NSError* error) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        __strong RelayrUser* strongSelf = weakSelf;
        NSString* pName = strongSelf.name;
        strongSelf.name = name;
        if (completion) { completion(nil, pName); }
    }];
}

- (void)setEmail:(NSString*)email completion:(void (^)(NSError* error, NSString* previousEmail))completion
{
    __weak RelayrUser* weakSelf = self;
    [_apiService setUserName:nil email:email completion:^(NSError *error) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        __strong RelayrUser* strongSelf = weakSelf;
        NSString* pEmail = strongSelf.email;
        strongSelf.email = email;
        if (completion) { completion(nil, pEmail); }
    }];
}

- (void)queryCloudForUserInfo:(void (^)(NSError* error, NSString* previousName, NSString* previousEmail))completion
{
    __weak RelayrUser* weakSelf = self;
    [_apiService requestUserInfo:^(NSError* error, NSString* uid, NSString* name, NSString* email) {
        if (error) { if (completion) { completion(error, nil, nil); } return; }
        if (!uid.length) { if (completion) { completion(RelayrErrorWrongRelayrUser, nil, nil); } return; }
        
        RelayrUser* strongSelf = weakSelf;
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

- (void)queryCloudForIoTs:(void (^)(NSError*))completion
{
    __weak RelayrUser* weakSelf = self;
    [_apiService requestUserTransmitters:^(NSError* transmitterError, NSSet* transmitters) {
        if (transmitterError) { if (completion) { completion(transmitterError); } return; }
        if (!weakSelf) { return; }
        
        [weakSelf.apiService requestUserDevices:^(NSError* deviceError, NSSet* devices) {
            if (deviceError) { if (completion) { completion(deviceError); } return ; }
            if (!weakSelf) { return; }
            
            [weakSelf.apiService requestUserBookmarkedDevices:^(NSError* bookmarkError, NSSet* devicesBookmarked) {
                if (bookmarkError) { if (completion) { completion(bookmarkError); } return; }
                if (!weakSelf) { return; }

                __block NSUInteger count = transmitters.count;
                if (count == 0) { return [weakSelf processIoTTreeWithTransmitters:transmitters devices:devices bookmarkDevices:devicesBookmarked completion:completion]; }
                
                __block NSError* intermediateError;
                for (RelayrTransmitter* transmitter in transmitters)
                {
                    [_apiService requestDevicesFromTransmitter:transmitter.uid completion:^(NSError* transmitterDevicesError, NSSet* transmitterDevices) {
                        if (!intermediateError)
                        {
                            if (transmitterDevicesError) { intermediateError = transmitterDevicesError; }
                            else { transmitter.devices = transmitterDevices; }
                        }
                        
                        if (--count == 0)
                        {
                            if (intermediateError) { if (completion) { completion(intermediateError); } return; }
                            [weakSelf processIoTTreeWithTransmitters:transmitters devices:devices bookmarkDevices:devicesBookmarked completion:completion];
                        }
                    }];
                }
            }];
        }];
    }];
}

- (void)queryCloudForPublishersAndAuthorisedApps:(void (^)(NSError* error))completion
{
    __weak RelayrUser* weakSelf = self;
    [_apiService requestUserAuthorisedApps:^(NSError* appError, NSSet* apps) {
        if (appError) { if (completion) { completion(appError); } return; }
        [weakSelf.apiService requestUserPublishers:^(NSError* publisherError, NSSet* publishers) {
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
    [_apiService registerTransmitterWithName:name ownerID:_uid model:modelID firmwareVersion:firmwareVersion completion:^(NSError* error, RelayrTransmitter* transmitter) {
        if (error) { if (completion) { completion(error, nil); } return; }
        RelayrTransmitter* result = [weakSelf addTransmitter:transmitter];
        if (!completion) { return; }
        return (result) ? completion(nil, result) : completion(RelayrErrorMissingExpectedValue, nil);
    }];
}

- (void)deleteTransmitter:(RelayrTransmitter*)transmitter completion:(void (^)(NSError* error))completion
{
    if (!transmitter.uid.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    __weak RelayrUser* weakSelf = self;
    [_apiService deleteTransmitter:transmitter.uid completion:^(NSError* error) {
        if (error) { if (completion) { completion(error); } return; }
        
        [weakSelf removeTransmitter:transmitter];
        if (completion) { completion(nil); }
    }];
}

- (void)registerDeviceWithModelID:(NSString*)modelID firmwareVerion:(NSString*)firmwareVersion name:(NSString*)name completion:(void (^)(NSError* error, RelayrDevice* device))completion
{
    if (!modelID || !firmwareVersion || !name) { if (completion) { completion(RelayrErrorMissingArgument, nil); } return; }
    
    __weak RelayrUser* weakSelf = self;
    [_apiService registerDeviceWithName:name owner:_uid model:modelID firmwareVersion:firmwareVersion completion:^(NSError* error, RelayrDevice* device) {
        if (error) { if (completion) { completion(error, nil); } return; }
        
        RelayrDevice* futureDevice = [weakSelf addDevice:device];
        if (!completion) { return; }
        return (futureDevice) ? completion(nil, futureDevice) : completion(RelayrErrorMissingExpectedValue, nil);
    }];
}

- (void)deleteDevice:(RelayrDevice*)device completion:(void (^)(NSError* error))completion
{
    if (!device.uid.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    __weak RelayrUser* weakSelf = self;
    [_apiService deleteDevice:device.uid completion:^(NSError *error) {
        if (error) { if (completion) { completion(error); } return; }
        
        [weakSelf removeDevice:device];
        if (completion) { completion(nil); }
    }];
}

#pragma mark Setup extension

-(instancetype)initWithToken:(NSString*)token
{
    if (!token.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _token = token;
        _apiService = [[RLAAPIService alloc] initWithUser:self];
    }
    return self;
}

- (RelayrTransmitter*)addTransmitter:(RelayrTransmitter*)transmitter
{
    NSString* transmitterID = transmitter.uid;
    if (!transmitterID.length) { return nil; }
    transmitter.user = self;
    
    if (transmitter.devices.count)  // Devices need to be added first.
    {
        NSMutableSet* transmitterDevices = [[NSMutableSet alloc] initWithCapacity:transmitter.devices.count];
        for (RelayrDevice* tmpDevice in transmitter.devices)
        {
            RelayrDevice* device = [self addDevice:tmpDevice];
            if (device) { [transmitterDevices addObject:device]; }
        }
        transmitter.devices = [NSSet setWithSet:transmitterDevices];
    }
    
    if (_transmitters)
    {   // If there were other transmitters, check if the newly added is among them.
        RelayrTransmitter* matchedTransmitter;
        for (RelayrTransmitter* pTransmitter in _transmitters)
        {
            if ([pTransmitter.uid isEqualToString:transmitterID]) { matchedTransmitter = pTransmitter; break; }
        }
        
        if (!matchedTransmitter)
        {
            NSMutableSet* tmpSet = [NSMutableSet setWithSet:_transmitters];
            [tmpSet addObject:transmitter];
            _transmitters = [NSSet setWithSet:tmpSet];
        }
        else
        {
            [matchedTransmitter setWith:transmitter];
            transmitter = matchedTransmitter;
        }
    }
    else { _transmitters = [NSSet setWithObject:transmitter]; }
    
    return transmitter;
}

- (void)removeTransmitter:(RelayrTransmitter*)transmitter
{
    NSString* transmitterID = transmitter.uid;
    if (!transmitterID.length) { return; }
    
    RelayrTransmitter* matchedTransmitter;
    for (RelayrTransmitter* tmpTrans in self.transmitters)
    {
        if ([transmitterID isEqualToString:tmpTrans.uid]) { matchedTransmitter = tmpTrans; break; }
    }
    
    if (!matchedTransmitter) { return; }
    matchedTransmitter.devices = nil;
    
    NSMutableSet* tmpTrans = [NSMutableSet setWithSet:self.transmitters];
    [tmpTrans removeObject:matchedTransmitter];
    self.transmitters = [NSSet setWithSet:tmpTrans];
}

- (RelayrDevice*)addDevice:(RelayrDevice*)device
{
    NSString* deviceID = device.uid;
    if (!deviceID.length) { return nil; }
    device.user = self;
    
    if (_devices)
    {
        for (RelayrDevice* pDevice in _devices)
        {
            if ([pDevice.uid isEqualToString:deviceID]) { [pDevice setWith:device]; return pDevice; }
        }
        
        NSMutableSet* tmpSet = [NSMutableSet setWithSet:_devices];
        [tmpSet addObject:device];
        _devices = [NSSet setWithSet:tmpSet];
    }
    else { _devices = [NSSet setWithObject:device]; }
    
    return device;
}

- (void)removeDevice:(RelayrDevice*)device
{
    NSString* deviceID = device.uid;
    if (!deviceID.length || !_devices.count) { return; }
    
    if (_devices.count)   // Look for the device in _devices...
    {
        RelayrDevice* matchedDevice;
        for (RelayrDevice* pDevice in _devices)
        {
            if ([pDevice.uid isEqualToString:deviceID]) { matchedDevice = pDevice; break; }
        }
        
        if (matchedDevice)
        {
            [matchedDevice removeAllSubscriptions];     // This method is added here to erase unwanted retain cycles (in case the user messed up)
            NSMutableSet* tmpDevices = [NSMutableSet setWithSet:_devices];
            [tmpDevices removeObject:matchedDevice];
            _devices = [NSSet setWithSet:tmpDevices];
        }
    }
    
    if (_devicesBookmarked.count)   // Look for the device in _devicesBookmarked...
    {
        RelayrDevice* matchedDevice;
        for (RelayrDevice* pDevice in _devicesBookmarked)
        {
            if ([pDevice.uid isEqualToString:deviceID]) { matchedDevice = pDevice; break; }
        }
        
        if (matchedDevice)
        {
            [matchedDevice removeAllSubscriptions];     // This method is added here to erase unwanted retain cycles (in case the user messed up)
            NSMutableSet* tmpDevices = [NSMutableSet setWithSet:_devicesBookmarked];
            [tmpDevices removeObject:matchedDevice];
            _devicesBookmarked = [NSSet setWithSet:tmpDevices];
        }
    }
    
    if (_transmitters.count)    // Look for the device within all the transmitters...
    {
        for (RelayrTransmitter* transmitter in _transmitters)
        {
            RelayrDevice* matchedDevice;
            for (RelayrDevice* pDevice in transmitter.devices)
            {
                if ([pDevice.uid isEqualToString:deviceID]) { matchedDevice = pDevice; break; }
            }
            
            if (matchedDevice)
            {
                [matchedDevice removeAllSubscriptions]; // This method is added here to erase unwanted retain cycles (in case the user messed up)
                NSMutableSet* tmpDevices = [NSMutableSet setWithSet:transmitter.devices];
                [tmpDevices removeObject:matchedDevice];
                transmitter.devices = [NSSet setWithSet:tmpDevices];
            }
        }
    }
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithToken:[decoder decodeObjectForKey:kCodingToken]];
    if (self)
    {
        _app = [decoder decodeObjectForKey:kCodingApp];
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
    [coder encodeObject:_app forKey:kCodingApp];
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
 * It sets the user's IoTs with the server query. The transmitters set brings the devices of transmitters, although these devices are not the same object as the devices set.
 * The parameter can never be <code>nil</code>. If they don't contain any object, they will be an empty set.
 ******************************************************************************/
- (void)processIoTTreeWithTransmitters:(NSSet*)transmitters devices:(NSSet*)devices bookmarkDevices:(NSSet*)bookDevices completion:(void (^)(NSError*))completion
{
    NSMutableSet* result = [[NSMutableSet alloc] init];
    __weak RelayrUser* user = self;
    
    // First: compile the current list of devices. Keep the used old objects and add the new ones (the non-used any more, will be deleted)...
    if (_devices)
    {
        for (RelayrDevice* nDevice in devices)  // Always loop through the newer set
        {
            NSString* nDeviceID = nDevice.uid;
            RelayrDevice* matchedDevice = nDevice;
            for (RelayrDevice* pDevice in _devices)
            {
                if ([pDevice.uid isEqualToString:nDeviceID]) { matchedDevice = pDevice; [matchedDevice setWith:nDevice]; break; }
            }
            matchedDevice.user = user;
            [result addObject:matchedDevice];
        }
        devices = [NSSet setWithSet:result];
    }
    
    // Second: Check bookmarked devices for already set up devices...
    [result removeAllObjects];
    for (RelayrDevice* bDevice in bookDevices)
    {
        NSString* bDeviceID = bDevice.uid;
        RelayrDevice* matchedDevice = bDevice;
        for (RelayrDevice* pDevice in devices)
        {
            if ([pDevice.uid isEqualToString:bDeviceID]) { matchedDevice = pDevice; break; }
        }
        matchedDevice.user = user;
        [result addObject:matchedDevice];
    }
    bookDevices = [NSSet setWithSet:result];
    
    // Third: Compile list between previous bookmarked devices and current ones...
    if (_devicesBookmarked)
    {
        [result removeAllObjects];
        for (RelayrDevice* bDevice in bookDevices)  // Always loop through the newer set
        {
            NSString* bDeviceID = bDevice.uid;
            RelayrDevice* matchedDevice = bDevice;
            for (RelayrDevice* pDevice in _devicesBookmarked)
            {
                if ([pDevice.uid isEqualToString:bDeviceID]) { matchedDevice = pDevice; [matchedDevice setWith:bDevice]; break; }
            }
            [result addObject:matchedDevice];
        }
        bookDevices = [NSSet setWithSet:result];
    }
    
    // Fourth: Go through the transmitter's devices and substitude them with the devices in <code>devices</code>
    for (RelayrTransmitter* transmitter in transmitters)
    {
        [result removeAllObjects];
        for (RelayrDevice* nDevice in transmitter.devices)
        {
            NSString* nDeviceID = nDevice.uid;
            RelayrDevice* matchedDevice = nDevice;
            for (RelayrDevice* pDevice in devices)
            {
                if ([pDevice.uid isEqualToString:nDeviceID]) { matchedDevice = pDevice; [matchedDevice setWith:nDevice]; break; }
            }
            matchedDevice.user = user;
            [result addObject:matchedDevice];
        }
        transmitter.user = user;
        transmitter.devices = [NSSet setWithSet:result];
    }
    
    // Fifth: Compile list between previous transmitters and current ones...
    if (_transmitters)
    {
        [result removeAllObjects];
        for (RelayrTransmitter* nTransmitter in transmitters)
        {
            NSString* nTransmitterID = nTransmitter.uid;
            RelayrTransmitter* matchedTransmitter = nTransmitter;
            for (RelayrTransmitter* pTransmitter in _transmitters)
            {
                if ([pTransmitter.uid isEqualToString:nTransmitterID]) { matchedTransmitter = pTransmitter; [matchedTransmitter setWith:nTransmitter]; break; }
            }
            matchedTransmitter.user = user;
            [result addObject:matchedTransmitter];
        }
        transmitters = [NSSet setWithSet:result];
    }
    
    _devices = devices;
    _devicesBookmarked = bookDevices;
    _transmitters = transmitters;
    if (completion) { completion(nil); }
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
    else if (apps.count == 0 || _authorisedApps.count == 0) { _authorisedApps = apps; return; }
    
    NSMutableSet* result = [[NSMutableSet alloc] init];
    for (RelayrApp* app in apps)
    {
        NSString* appID = app.uid;

        RelayrApp* matchedApp = app;
        for (RelayrApp* previousApp in _authorisedApps)
        {
            if ([previousApp.uid isEqualToString:appID])
            {
                [previousApp setWith:app];
                matchedApp = previousApp;
                break;
            }
        }
        
        [result addObject:matchedApp];
    }
    
    _authorisedApps = [NSSet setWithSet:result];
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
    else if (publishers.count == 0 || _publishers.count == 0) { _publishers = publishers; return; }
    
    NSMutableSet* result = [[NSMutableSet alloc] init];
    
    for (RelayrPublisher* publisher in publishers)
    {
        NSString* publisherID = publisher.uid;
        
        RelayrPublisher* matchedPublisher = publisher;
        for (RelayrPublisher* previousPublisher in _authorisedApps)
        {
            if ([previousPublisher.uid isEqualToString:publisherID])
            {
                [previousPublisher setWith:publisher];
                matchedPublisher = previousPublisher;
                break;
            }
        }
        
        [result addObject:matchedPublisher];
    }
    
    _publishers = [NSSet setWithSet:result];
}

@end
