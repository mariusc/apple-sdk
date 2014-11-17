#import "RLAMQTTService.h"          // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrErrors.h"            // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RelayrDevice_Setup.h"      // Relayr.framework (Private)
#import "RLAAPIService.h"           // Relayr.framework (Private)
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

- (void)queryDataFromDevice:(RelayrDevice*)device completion:(void (^)(NSError* error, id value, NSDate * date))completion
{
    // TODO:
}

- (void)subscribeToDataFromDevice:(RelayrDevice*)device completion:(void (^)(NSError* error))completion
{
    debug("Device asking for subscription");
    
    BOOL isDeviceBeingSubscribed = NO;
    for (RelayrDevice* tmpDevice in [[_subscribingDevices keyEnumerator] allObjects]) { if (tmpDevice==device) { isDeviceBeingSubscribed = YES; break; } }
    
    if ( isDeviceBeingSubscribed )
    {
        if (completion)
        {
            NSMutableSet* blocks = [_subscribingDevices objectForKey:device];
            [blocks addObject:completion];
        }
        return;
    }
    
    if ( [_subscribedDevices containsObject:device] )
    {
        if (completion) { completion(nil); }
        return;
    }
    
    if (self.connectionState==RelayrConnectionStateConnected || self.connectionState==RelayrConnectionStateConnecting)
    {
        NSMutableSet* blocks = (completion) ? [NSMutableSet setWithObject:completion] : [NSMutableSet setWithObject:[NSNull null]];
        [_subscribingDevices setObject:blocks forKey:device];
        if (self.connectionState==RelayrConnectionStateConnected) { [self susbribeToDevice:device withQualityOfService:dRLAMQTT_QoS]; }
    }
    else if (completion) { completion(RelayrErrorMQTTUnableToConnect); }
}

- (void)unsubscribeToDataFromDevice:(RelayrDevice*)device
{
    // TODO:
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
        [self clearSubscriptionsAndNotifyError:RelayrErrorMQTTUnableToConnect at:[NSDate date]];
        return MQTTASYNC_FAILURE;
    }
    
    debug("Connecting to broker...\n");
    
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
    dispatch_async(dispatch_get_main_queue(), ^{
        debug("Connection to broker failed!\n");
        
        RLAMQTTServiceConnectingState* connectingState = context;
        RLAMQTTService* service = (__bridge RLAMQTTService*)connectingState->mqttService;
        
        service.connectionState = RelayrConnectionStateDisconnected;
        [service connectToBrokerWith:connectingState];
    });
}

void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        debug("Connection to broker succeeded!\n");
        
        RLAMQTTServiceConnectingState* connectingState = context;
        free((void*)connectingState->username);
        free((void*)connectingState->password);
        free(connectingState);
        
        RLAMQTTService* service = (__bridge RLAMQTTService*)connectingState->mqttService;
        if (!service) { return; }
        
        service.connectionState = RelayrConnectionStateConnected;
        for (RelayrDevice* device in [[service.subscribingDevices keyEnumerator] allObjects]) { [service susbribeToDevice:device withQualityOfService:dRLAMQTT_QoS]; }
    });
}

void connectionToBrokerLost(void* context, char* cause)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        debug("Connection to broker lost!\n");
        
        RLAMQTTService* service = (__bridge RLAMQTTService*)context;
        service.connectionState = RelayrConnectionStateDisconnected;
        [service clearSubscriptionsAndNotifyError:RelayrErrorMQTTConnectionLost at:[NSDate date]];
    });
}

- (void)susbribeToDevice:(RelayrDevice*)device withQualityOfService:(NSInteger)qos
{
    if ( [_subscribedDevices containsObject:device] ) { return; }
    
    MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
    opts.onSuccess = subscriptionSucceded;
    opts.onFailure = subscriptionFailed;
    opts.context = (__bridge void*)self;
    
    NSString* tmp_topic = dRLAMQTT_topic(device.uid);
    NSUInteger const length_topic = [tmp_topic lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    char topic[length_topic];
    [tmp_topic getCString:topic maxLength:length_topic encoding:NSUTF8StringEncoding];
    topic[length_topic] = '\0';
    
    int const status = MQTTAsync_subscribe(_client, topic, (int)qos, &opts);
    if (status != MQTTASYNC_SUCCESS)
    {
        NSMutableSet* blockSet = [_subscribingDevices objectForKey:device];
        if (!blockSet) { return; }
        [_subscribingDevices removeObjectForKey:device];
        
        for (id block in blockSet)
        {
            if (block != [NSNull null])
            {
                void (^completion)(NSError* error) = block;
                completion(RelayrErrorMQTTSubscriptionFailed);
            }
        }
        
        [self clearDevice:device fromSubscribingWith:RelayrErrorMQTTSubscriptionFailed];
    }
}

void subscriptionSucceded(void* context, MQTTAsync_successData* response)
{
    
}

void subscriptionFailed(void* context, MQTTAsync_failureData* response)
{
    
}


void disconnectionFromBrokerSucceeded(void* context, MQTTAsync_successData* response)
{
    MQTTAsync_destroy(&context);
}

void disconnectionFromBrokerFailed(void* context, MQTTAsync_failureData* response)
{
    MQTTAsync_destroy(&context);
}

int messageArrived(void* context, char* topicName, int topicLen, MQTTAsync_message* message)
{
    return 0;
}

- (void)clearSubscriptionsAndNotifyError:(NSError*)error at:(NSDate*)date
{
    NSArray* subscribedDevices = [_subscribedDevices allObjects];
    NSDictionary* subscribingDevices = [_subscribingDevices dictionaryRepresentation];
    [_subscribedDevices removeAllObjects];
    [_subscribingDevices removeAllObjects];
    
    for (RelayrDevice* device in subscribedDevices) { [device valueReceived:error at:date]; }
    [subscribingDevices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        RelayrDevice* device = ([key isKindOfClass:[RelayrDevice class]]) ? key : nil;
        if (!device) { return; }
        
        NSMutableSet* blockSet = ([key isKindOfClass:[NSMutableSet class]]) ? obj : nil;
        for (id block in blockSet)
        {
            if (block == [NSNull null]) { continue; }
            
            void (^completion)(NSError* error) = block;
            completion(error);
        }
    }];
}

- (void)clearDevice:(RelayrDevice*)device fromSubscribingWith:(NSError*)error
{
    if (!device) { return; }
    NSMutableSet* blockSet = [_subscribingDevices objectForKey:device];
    if (!blockSet) { return; }
    [_subscribingDevices removeObjectForKey:device];
    
    for (id block in blockSet)
    {
        if (block == [NSNull null]) { continue; }
        
        void (^completion)(NSError* error) = block;
        completion(error);
    }
}

@end
