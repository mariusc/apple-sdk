#import "RLAMQTTService.h"          // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RLAMQTTConstants.h"        // Relayr.framework (Protocols/MQTT)
#import "RLAIdentifierGenerator.h"  // Relayr.framework (Utilities)

#import <MQTT/MQTTAsync.h>

@interface RLAMQTTService ()
@property (readwrite,nonatomic) RelayrConnectionState connectionState;
@end

#pragma mark - Definitions

#define RLAMQTTSERVICE_NUM_CONNECTION_TRIES 2
#define RLAMQTTSERVICE_USERNAME             "relayr"
#define RLAMQTTSERVICE_PASSWORD             "relayr"

struct RLAMQTTServiceConnectingState {
    NSUInteger numRetries;
    void* mqttService;
};

#pragma mark - Private prototypes

void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response);
void connectionToBrokerFailed(void* context, MQTTAsync_failureData* response);
void connectionToBrokerLost(void* context, char const* cause);
int messageArrived(void* context, char const* topicName, size_t topicLen, MQTTAsync_message* message);
void messageDelivered(void* context, MQTTAsync_token token);

@implementation RLAMQTTService
{
    MQTTAsync* _client;
}

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUser:(RelayrUser*)user
{
    if (!user.uid) { return nil; }
    
    self = [super init];
    if (self)
    {
        _user = user;
        _hostString = dRLAMQTT_Host;
        _port = [NSNumber numberWithUnsignedInteger:dRLAMQTT_PortUnencripted];
        _connectionState = RelayrConnectionStateDisconnected;
        _client = NULL;
        
        NSString* clientIdentifier = [RLAIdentifierGenerator generateIDFromUserID:user.uid withMaximumRandomNumber:dRLAMQTT_ClientIDMaxRandomNum];
        MQTTAsync_create(_client, [_hostString cStringUsingEncoding:NSUTF8StringEncoding], [clientIdentifier cStringUsingEncoding:NSUTF8StringEncoding], MQTTCLIENT_PERSISTENCE_NONE, NULL);
        if (_client == NULL) { return nil; }
        
        MQTTAsync_setCallbacks(*_client, (__bridge void*)self, connectionToBrokerLost, messageArrived, messageDelivered);
        
        struct RLAMQTTServiceConnectingState* connectingState = malloc(sizeof(struct RLAMQTTServiceConnectingState));
        connectingState->numRetries = RLAMQTTSERVICE_NUM_CONNECTION_TRIES;
        connectingState->mqttService = (__bridge void*)self;
        MQTTCode const connectionAcceptedStatus = [self connectToBrokerWith:connectingState];
        
        if (connectionAcceptedStatus != MQTTCODE_SUCCESS)
        {
            MQTTAsync_destroy(_client);
            _client = NULL;
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_client != NULL)
    {
        MQTTAsync_destroy(_client);
        _client = NULL;
    }
}

#pragma mark RLAService protocol

- (void)queryDataFromDevice:(RelayrDevice*)device completion:(void (^)(NSError* error, id value, NSDate * date))completion
{
    
}

- (void)subscribeToDataFromDevice:(RelayrDevice*)device completion:(void (^)(NSError* error))completion
{
    
}

- (void)unsubscribeToDataFromDevice:(RelayrDevice*)device
{
    
}

#pragma mark - Private functionality

- (MQTTCode)connectToBrokerWith:(struct RLAMQTTServiceConnectingState*)connectingState
{
    if (connectingState==NULL || connectingState->numRetries==0)
    {
        free(connectingState);
        return MQTTCODE_FAILURE;
    }
    
    _connectionState = RelayrConnectionStateConnecting;
    connectingState->numRetries--;
    
    MQTTAsync_connectOptions opts = MQTTAsync_connectOptions_initializer;
    opts.keepAliveInterval = 20;
    opts.cleansession = 1;
    opts.onSuccess = connectionToBrokerSucceeded;
    opts.onFailure = connectionToBrokerFailed;
    opts.context = connectingState;
    opts.username = RLAMQTTSERVICE_USERNAME;
    opts.password = RLAMQTTSERVICE_PASSWORD;
    
    MQTTCode const connectionAcceptedStatus = MQTTAsync_connect(_client, &opts);
    if (connectionAcceptedStatus != MQTTCODE_SUCCESS)
    {
        _connectionState = RelayrConnectionStateDisconnected;
        free(connectingState);
    }
    
    return connectionAcceptedStatus;
}

void connectionToBrokerFailed(void* context, MQTTAsync_failureData* response)
{
    if (context == NULL) { return; }
    struct RLAMQTTServiceConnectingState* connectingState = context;
    
    RLAMQTTService* service = (__bridge RLAMQTTService*)connectingState->mqttService;
    if (!service) { return; }
    service.connectionState = RelayrConnectionStateDisconnected;
    
    [service connectToBrokerWith:connectingState];
}

void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response)
{
    if (context == NULL) { return; }
    struct RLAMQTTServiceConnectingState* connectingState = context;
    
    RLAMQTTService* service = (__bridge RLAMQTTService*)connectingState->mqttService;
    if (!service) { return; }
    service.connectionState = RelayrConnectionStateConnected;
}

void connectionToBrokerLost(void* context, char const* cause)
{
    
}

int messageArrived(void* context, char const* topicName, size_t topicLen, MQTTAsync_message* message)
{
    return 0;
}

void messageDelivered(void* context, MQTTAsync_token token)
{
    
}

@end
