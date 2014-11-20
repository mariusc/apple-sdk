#import "RLAMQTTService.h"          // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrErrors.h"            // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)
#import "RLAAPIService.h"           // Relayr.framework (Private)
#import "RLAServiceHolder.h"        // Relayr.framework (Service)
#import "RLAMQTTConstants.h"        // Relayr.framework (Service/MQTT)
#import "RLAIdentifierGenerator.h"  // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)

#import <MQTT/MQTTAsync.h>          // MQTT (Public)
#import <CBasics/CMacros.h>         // CBasics (Utilities)
#import <CBasics/CDebug.h>          // CBasics (Utilities)

@interface RLAMQTTService ()
@property (readwrite,nonatomic) RelayrConnectionState connectionState;
@property (readonly,nonatomic) NSHashTable* subscribedDevices;
@property (readonly,nonatomic) NSMapTable* subscribingDevices;
@property (readonly,nonatomic) NSMapTable* queryingDevices;
@property (unsafe_unretained,nonatomic) MQTTAsync client;
@end

#pragma mark - Definitions

#define RLAMQTTSERVICE_NUM_CONNECTION_TRIES 2

typedef struct RLAMQTTServiceConnectingState {
    NSUInteger numConnectionTries;
    void* mqttService;
    char const* username;
    char const* password;
} RLAMQTTServiceConnectingState;

#pragma mark - Private prototypes

void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response);
void connectionToBrokerFailed(void* context, MQTTAsync_failureData* response);
void connectionToBrokerLost(void* context, char* cause);
void subscriptionSucceded(void* context, MQTTAsync_successData* response);
void subscriptionFailed(void* context, MQTTAsync_failureData* response);
void disconnectionFromBrokerSucceeded(void* context, MQTTAsync_successData* response);
void disconnectionFromBrokerFailed(void* context, MQTTAsync_failureData* response);

int messageArrived(void* context, char* topicName, int topicLen, MQTTAsync_message* message);
//void messageDelivered(void* context, MQTTAsync_token token);

@implementation RLAMQTTService

@synthesize user = _user;
@synthesize connectionState = _connectionState;
@synthesize connectionScope = _connectionScope;

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUser:(RelayrUser*)user
{
    return nil;
}

// FIXME: Delete this as soon as the server guys finish.
- (instancetype)initWithUser:(RelayrUser *)user device:(RelayrDevice *)device
{
    RelayrTransmitter* transmitter = device.transmitter;
    if (!transmitter.uid) { return nil; }
    
    self = [super init];
    {
        // Set up iVars
        _user = user;
        _connectionState = RelayrConnectionStateUnknown;
        _connectionScope = RelayrConnectionScopeUnknown;
        _hostString = [NSString stringWithFormat:@"%@%@", dRLAMQTT_ProtocolSSL, dRLAMQTT_Host];
        _port = [NSNumber numberWithUnsignedInteger:dRLAMQTT_PortSSL];
        _client = NULL;
        _subscribedDevices = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        _subscribingDevices = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        _queryingDevices = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        
        // Set up Paho MQTT service
        NSString* tmp_serverURI = [NSString stringWithFormat:@"%@:%lu", _hostString, _port.unsignedLongValue];
        NSUInteger const length_serverURI = [tmp_serverURI lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
        char serverURI[length_serverURI];
        [tmp_serverURI getCString:serverURI maxLength:length_serverURI encoding:NSUTF8StringEncoding];
        serverURI[length_serverURI] = '\0';
        
        NSString* tmp_clientID = [RLAIdentifierGenerator generateIDFromBaseString:@"APPLE" withMaximumRandomNumber:65535];
        NSUInteger const length_clientID = [tmp_clientID lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
        char clientID[length_clientID];
        [tmp_clientID getCString:clientID maxLength:length_clientID encoding:NSUTF8StringEncoding];
        clientID[length_clientID] = '\0';
        
        NSString* tmp_username = transmitter.uid;
        NSUInteger const length_userName = [tmp_username lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
        char username[length_userName];
        [tmp_username getCString:username maxLength:length_userName encoding:NSUTF8StringEncoding];
        username[length_userName] = '\0';
        
        NSString* tmp_password = transmitter.secret;
        NSUInteger const length_password = [tmp_password lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
        char password[length_password];
        [tmp_password getCString:password maxLength:length_password encoding:NSUTF8StringEncoding];
        password[length_password] = '\0';
        
        int status = MQTTAsync_create(&_client, serverURI, clientID, MQTTCLIENT_PERSISTENCE_NONE, NULL);
        if (status!=MQTTASYNC_SUCCESS || _client==NULL) { return nil; }
        
        MQTTAsync_setCallbacks(_client, (__bridge void*)self, connectionToBrokerLost, messageArrived, NULL);
        
        RLAMQTTServiceConnectingState* connectingState = malloc_sizeof(RLAMQTTServiceConnectingState);
        *connectingState = (RLAMQTTServiceConnectingState){
            .numConnectionTries = RLAMQTTSERVICE_NUM_CONNECTION_TRIES,
            .mqttService = (__bridge void*)self,
            .username = strdup(username),
            .password = strdup(password)
        };
        
        status = [self connectToBrokerWith:connectingState];
        if (status != MQTTASYNC_SUCCESS) { MQTTAsync_destroy(&_client); return nil; }
    }
    return self;
}

- (void)dealloc
{
    if (_client != NULL)
    {
        MQTTAsync_disconnectOptions opts = MQTTAsync_disconnectOptions_initializer;
        opts.onSuccess = disconnectionFromBrokerSucceeded;
        opts.onFailure = disconnectionFromBrokerFailed;
        opts.context = _client;
        MQTTAsync_disconnect(_client, &opts);
        _client = NULL;
    }
}

#pragma mark RLAService protocol

- (void)queryDataFromDevice:(RelayrDevice*)device completion:(RLAServiceBlockQuery)completion
{
    if (!completion) { return; }
    
    NSMutableSet* blocks = [_queryingDevices objectForKey:device];
    if (blocks) { return [blocks addObject:completion]; }
    
    if (self.connectionState==RelayrConnectionStateConnected || self.connectionState==RelayrConnectionStateConnecting)
    {
        [_queryingDevices setObject:[NSMutableSet setWithObject:completion] forKey:device];
        if (![_subscribedDevices containsObject:device] && ![_subscribingDevices objectForKey:device]) { [self susbribeToDevice:device withQualityOfService:dRLAMQTT_QoS]; }
    }
    else { completion(RelayrErrorMQTTUnableToConnect, nil, [NSDate date]); }
}

- (void)subscribeToDataFromDevice:(RelayrDevice*)device completion:(RLAServiceBlockError)completion
{
    NSMutableSet* blocks = [_subscribingDevices objectForKey:device];
    if (blocks) { return (completion) ? [blocks addObject:completion] : [blocks addObject:[NSNull null]]; }
    
    if ( [_subscribedDevices containsObject:device] ) { if (completion) { completion(nil); } return; }
    
    if (self.connectionState==RelayrConnectionStateConnected || self.connectionState==RelayrConnectionStateConnecting)
    {
        [_subscribingDevices setObject:((completion) ? [NSMutableSet setWithObject:completion] : [NSMutableSet setWithObject:[NSNull null]]) forKey:device];
        
        if (self.connectionState==RelayrConnectionStateConnected && ![_queryingDevices objectForKey:device])
        { [self susbribeToDevice:device withQualityOfService:dRLAMQTT_QoS]; }
    }
    else if (completion) { completion(RelayrErrorMQTTUnableToConnect); }
}

- (void)unsubscribeToDataFromDevice:(RelayrDevice*)device
{
    [_subscribingDevices removeObjectForKey:device];
    [_subscribedDevices removeObject:device];
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"\n\
{\n\
\thost: %@\n\
\tport: %@\n\
\tNum subscribed devices: %@\n\
\tNum subscribing devices: %@\n\
}\n", _hostString, _port, @(_subscribedDevices.count), @(_subscribingDevices.count)];
}

#pragma mark - Private functionality

- (int)connectToBrokerWith:(RLAMQTTServiceConnectingState*)connectingState
{
    if (connectingState==NULL) { return MQTTASYNC_FAILURE; }
    if (connectingState->numConnectionTries==0)
    {
        free((void*)connectingState->username);
        free((void*)connectingState->password);
        free(connectingState);
        [self clearSubsAndQueriesAndNotifyError:RelayrErrorMQTTUnableToConnect at:[NSDate date]];
        return MQTTASYNC_FAILURE;
    }
    
    debug("MQTT: Connecting to broker...\n\tUsername: %s\n\tPassword %s", connectingState->username, connectingState->password);
    
    _connectionState = RelayrConnectionStateConnecting;
    connectingState->numConnectionTries--;
    
    MQTTAsync_connectOptions opts = MQTTAsync_connectOptions_initializer;
    opts.keepAliveInterval = 20;
    opts.cleansession = 1;
    opts.username = connectingState->username;
    opts.password = connectingState->password;
    opts.onSuccess = connectionToBrokerSucceeded;
    opts.onFailure = connectionToBrokerFailed;
    opts.context = connectingState;
    
    static MQTTAsync_SSLOptions opts_ssl = MQTTAsync_SSLOptions_initializer;
    opts_ssl.enableServerCertAuth = 0;
    opts.ssl = &opts_ssl;
    
    int const connectionAcceptedStatus = MQTTAsync_connect(_client, &opts);
    if (connectionAcceptedStatus != MQTTASYNC_SUCCESS)
    {
        _connectionState = RelayrConnectionStateDisconnected;
        free((void*)connectingState->username);
        free((void*)connectingState->password);
        free(connectingState);
    }
    
    return connectionAcceptedStatus;
}

void connectionToBrokerFailed(void* context, MQTTAsync_failureData* response)
{
    RLAMQTTServiceConnectingState* connectingState = context;
    RLAMQTTService* weakService = (__bridge RLAMQTTService*)connectingState->mqttService;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        debug("MQTT: Connection to the broker failed!!");
        
        RLAMQTTService* service = weakService;
        if (!service) { return; }
        
        service.connectionState = RelayrConnectionStateDisconnected;
        [service connectToBrokerWith:connectingState];
    });
}

void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response)
{
    RLAMQTTServiceConnectingState* connectingState = context;
    RLAMQTTService* weakService = (__bridge RLAMQTTService*)connectingState->mqttService;
    free((void*)connectingState->username);
    free((void*)connectingState->password);
    free(connectingState);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        debug("MQTT: Connection to broker succeeded!!");
        
        RLAMQTTService* service = weakService;
        if (!service) { return; }
        
        service.connectionState = RelayrConnectionStateConnected;
        
        NSArray* subscribingDev = [[service.subscribingDevices keyEnumerator] allObjects];
        for (RelayrDevice* device in subscribingDev) { [service susbribeToDevice:device withQualityOfService:dRLAMQTT_QoS]; }
        
        NSArray* queryingDev = [[service.queryingDevices keyEnumerator] allObjects];
        for (RelayrDevice* device in queryingDev) { if (![subscribingDev containsObject:device]) { [service susbribeToDevice:device withQualityOfService:dRLAMQTT_QoS]; } }
    });
}

void connectionToBrokerLost(void* context, char* cause)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        debug("MQTT: Connection to the broker lost!!");
        
        RLAMQTTService* service = (__bridge RLAMQTTService*)context;
        service.connectionState = RelayrConnectionStateDisconnected;
        [service clearSubsAndQueriesAndNotifyError:RelayrErrorMQTTConnectionLost at:[NSDate date]];
    });
}

- (void)susbribeToDevice:(RelayrDevice*)device withQualityOfService:(NSInteger)qos
{
    if ( [_subscribedDevices containsObject:device] ) { return; }
    
    MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
    opts.onSuccess = subscriptionSucceded;
    opts.onFailure = subscriptionFailed;
    opts.context = (__bridge_retained void*)[[RLAServiceHolder alloc] initWithService:self device:device];
    
    NSString* tmp_topic = dRLAMQTT_topic(device.uid);
    NSUInteger const length_topic = [tmp_topic lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    char topic[length_topic];
    [tmp_topic getCString:topic maxLength:length_topic encoding:NSUTF8StringEncoding];
    topic[length_topic] = '\0';
    
    int const status = MQTTAsync_subscribe(_client, topic, (int)qos, &opts);
    if (status != MQTTASYNC_SUCCESS)
    {
        RLAServiceHolder* holder = (__bridge_transfer RLAServiceHolder*)opts.context;
        holder = nil;
        
        [self clearDevice:device fromSubscribingWith:RelayrErrorMQTTSubscriptionFailed];
        [self clearDevice:device fromQueryingWithError:RelayrErrorMQTTSubscriptionFailed value:nil date:nil];
    }
}

void subscriptionSucceded(void* context, MQTTAsync_successData* response)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        RLAServiceHolder* holder = (__bridge_transfer RLAServiceHolder*)context;
        debug("MQTT: Device subscription succeeded!!\n\tDeviceID: %s", [holder.device.uid cStringUsingEncoding:NSUTF8StringEncoding]);
        
        __weak RLAMQTTService* service = holder.service;
        __weak RelayrDevice* device = holder.device;
        if ([service.subscribingDevices objectForKey:device])
        {
            [service clearDevice:device fromSubscribingWith:nil];
            [service.subscribedDevices addObject:device];
        }
        holder = nil;
    });
}

void subscriptionFailed(void* context, MQTTAsync_failureData* response)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        RLAServiceHolder* holder = (__bridge_transfer RLAServiceHolder*)context;
        debug("MQTT: Device subscription failed!!\n\tDeviceID %s", [holder.device.uid cStringUsingEncoding:NSUTF8StringEncoding]);
        
        RLAMQTTService* service = holder.service;
        RelayrDevice* device = holder.device;
        holder = nil;
        
        [service clearDevice:device fromSubscribingWith:RelayrErrorMQTTSubscriptionFailed];
        [service clearDevice:device fromQueryingWithError:RelayrErrorMQTTSubscriptionFailed value:nil date:nil];
    });
}

int messageArrived(void* context, char* topicName, int topicLen, MQTTAsync_message* message)
{
    char* position = NULL;
    char const* restrict delimiter = "/";
    char* result = strtok_r(topicName, delimiter, &position);
    result = strtok_r(NULL, delimiter, &position);
    NSString* deviceID = [NSString stringWithUTF8String:result];
    NSDate* currentDate = [NSDate date];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        RLAMQTTService* service = (__bridge RLAMQTTService*)context;
        if (!service || !deviceID) { return; }
        
        RelayrDevice* matchedDevice;
        for (RelayrDevice* device in [service.subscribedDevices allObjects]) { if ([deviceID isEqualToString:device.uid]) { matchedDevice = device; break; } }
        
        if (!matchedDevice)
        {
            MQTTAsync_unsubscribe(service.client, topicName, NULL);
            
            if (service.queryingDevices.count)
            {
                for (RelayrDevice* device in [[service.queryingDevices dictionaryRepresentation] allKeys])
                {
                    if ([deviceID isEqualToString:device.uid]) { matchedDevice = device; break; }
                }
                [service clearDevice:matchedDevice fromQueryingWithError:nil value:[NSData dataWithBytes:message->payload length:message->payloadlen] date:currentDate];
            }
        }
        else { [matchedDevice handleBinaryValue:[NSData dataWithBytes:message->payload length:message->payloadlen] fromService:service atDate:currentDate withError:nil]; }
        
        MQTTAsync_free(topicName);
        MQTTAsync_freeMessage((MQTTAsync_message**)&message);
    });
    
    return 1;
}

- (void)clearSubsAndQueriesAndNotifyError:(NSError*)error at:(NSDate*)date
{
    NSArray* subscribedDevices = [_subscribedDevices allObjects];
    [_subscribedDevices removeAllObjects];
    NSDictionary* subscribingDevices = [_subscribingDevices dictionaryRepresentation];
    [_subscribingDevices removeAllObjects];
    NSDictionary* queryingDevices = [_queryingDevices dictionaryRepresentation];
    [_queryingDevices removeAllObjects];
    
    for (RelayrDevice* device in subscribedDevices) { [device handleBinaryValue:nil fromService:self atDate:date withError:error]; }
    
    [subscribingDevices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        RelayrDevice* device = ([key isKindOfClass:[RelayrDevice class]]) ? key : nil;
        if (!device) { return; }
        
        NSMutableSet* blockSet = ([key isKindOfClass:[NSMutableSet class]]) ? obj : nil;
        for (id block in blockSet)
        {
            if (block == [NSNull null]) { continue; }
            ((RLAServiceBlockError)block)(error);
        }
    }];
    
    [queryingDevices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        RelayrDevice* device = ([key isKindOfClass:[RelayrDevice class]]) ? key : nil;
        if (!device) { return; }
        
        NSMutableSet* blockSet = ([key isKindOfClass:[NSMutableSet class]]) ? obj : nil;
        for (id block in blockSet)
        {
            if (block == [NSNull null]) { continue; }
            ((RLAServiceBlockQuery)block)(error, nil, date);
        }
    }];
}

- (void)clearDevice:(RelayrDevice*)device fromSubscribingWith:(NSError*)error
{
    NSMutableSet* blockSet = (device) ? [_subscribingDevices objectForKey:device] : nil;
    if (!blockSet) { return; }
    
    [_subscribingDevices removeObjectForKey:device];
    for (id block in blockSet) { if (block != [NSNull null]) { ((RLAServiceBlockError)block)(error); } }
}

- (void)clearDevice:(RelayrDevice*)device fromQueryingWithError:(NSError*)error value:(id)value date:(NSDate*)date
{
    NSMutableSet* blockSet = (device) ? [_queryingDevices objectForKey:device] : nil;
    if (!blockSet) { return; }
    
    [_queryingDevices removeObjectForKey:device];
    for (id block in blockSet) { ((RLAServiceBlockQuery)block)(error, value, date); }
}

void disconnectionFromBrokerSucceeded(void* context, MQTTAsync_successData* response)
{
    MQTTAsync_destroy(&context);
}

void disconnectionFromBrokerFailed(void* context, MQTTAsync_failureData* response)
{
    MQTTAsync_destroy(&context);
}

@end
