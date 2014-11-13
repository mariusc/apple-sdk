#import "RLAMQTTService.h"          // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RLAMQTTConstants.h"        // Relayr.framework (Service/MQTT)
#import "RLAIdentifierGenerator.h"  // Relayr.framework (Utilities)
#import "RLALog.h"                  // Relayr.framework (Utilities)

#import <MQTT/MQTTAsync.h>          // MQTT (Public)
#import <CBasics/CMacros.h>         // CBasics (Utilities)
#import <CBasics/CDebug.h>          // CBasics (Utilities)

@interface RLAMQTTService ()
@property (readwrite,nonatomic) RelayrConnectionState connectionState;
@end

#pragma mark - Definitions

#define RLAMQTTSERVICE_NUM_CONNECTION_TRIES 2

typedef struct RLAMQTTServiceConnectingState {
    NSUInteger numConnectionTries;
    void* mqttService;
} RLAMQTTServiceConnectingState;

#pragma mark - Private prototypes

void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response);
void connectionToBrokerFailed(void* context, MQTTAsync_failureData* response);
void connectionToBrokerLost(void* context, char const* cause);
int messageArrived(void* context, char const* topicName, size_t topicLen, MQTTAsync_message* message);
void messageDelivered(void* context, MQTTAsync_token token);

@implementation RLAMQTTService
{
    MQTTAsync _client;
}

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
    if (!user.uid) { return nil; }

    self = [super init];
    if (self)
    {
        /*
        debug("Initializing MQTT Service...");

        _user = user;
        _connectionState = RelayrConnectionStateUnknown;
        _connectionScope = RelayrConnectionScopeUnknown;
        _hostString = [NSString stringWithFormat:@"%@%@", dRLAMQTT_ProtocolTCP, dRLAMQTT_Host];
        _port = [NSNumber numberWithUnsignedInteger:dRLAMQTT_PortTCP];
        _connectionState = RelayrConnectionStateDisconnected;
        _client = NULL;

        NSString* serverURI = [NSString stringWithFormat:@"%@:%lu", _hostString, _port.unsignedLongValue];
        debug("%s", [serverURI cStringUsingEncoding:NSUTF8StringEncoding]);
        MQTTAsync_create(&_client, [serverURI cStringUsingEncoding:NSUTF8StringEncoding], RLAMQTTSERVICE_CLIENTID, MQTTCLIENT_PERSISTENCE_NONE, NULL);
        if (_client == NULL) { return nil; }

        MQTTAsync_setCallbacks(_client, (__bridge void*)self, connectionToBrokerLost, messageArrived, messageDelivered);
        MQTTCode const connectionAcceptedStatus = [self connectToBrokerWith:&(RLAMQTTServiceConnectingState){
            .numConnectionTries = RLAMQTTSERVICE_NUM_CONNECTION_TRIES,
            .mqttService = (__bridge void*)self
        }];

        if (connectionAcceptedStatus != MQTTCODE_SUCCESS) { MQTTAsync_destroy(_client); return nil; }
         */
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

//
//- (MQTTCode)connectToBrokerWith:(RLAMQTTServiceConnectingState*)connectingState
//{
//    if (connectingState==NULL || connectingState->numConnectionTries==0) { return MQTTCODE_FAILURE; }
//
//    debug("Connecting to broker...");
//
//    _connectionState = RelayrConnectionStateConnecting;
//    connectingState->numConnectionTries--;
//
//    MQTTAsync_connectOptions opts = MQTTAsync_connectOptions_initializer;
//    opts.keepAliveInterval = 20;
//    opts.cleansession = 1;
//    opts.onSuccess = connectionToBrokerSucceeded;
//    opts.onFailure = connectionToBrokerFailed;
//    opts.context = malloc_copyStruct(RLAMQTTServiceConnectingState, opts.context, *connectingState);
//    opts.username = RLAMQTTSERVICE_USERNAME;
//    opts.password = RLAMQTTSERVICE_PASSWORD;
//    MQTTCode const connectionAcceptedStatus = MQTTAsync_connect(_client, &opts);
//
//    if (connectionAcceptedStatus != MQTTCODE_SUCCESS)
//    {
//        _connectionState = RelayrConnectionStateDisconnected;
//        free(opts.context);
//    }
//
//    return connectionAcceptedStatus;
//}
//
//void connectionToBrokerFailed(void* context, MQTTAsync_failureData* response)
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        debug("Connection to broker failed!");
//
//        RLAMQTTServiceConnectingState* connectingState = context;
//        RLAMQTTService* service = (__bridge RLAMQTTService*)connectingState->mqttService;
//
//        service.connectionState = RelayrConnectionStateDisconnected;
//        [service connectToBrokerWith:connectingState];
//        free(connectingState);
//    });
//}
//
//void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response)
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        debug("Connection to broker succeeded!");
//
//        RLAMQTTServiceConnectingState* connectingState = context;
//        RLAMQTTService* service = (__bridge RLAMQTTService*)connectingState->mqttService;
//
//        service.connectionState = RelayrConnectionStateConnected;
//        free(connectingState);
//
//        // Do something here
//    });
//}
//
///*!
// *  @abstract This method is received once the connection with the broker is lost.
// *  @discussion This method is executed on a backgroudn thread.
// *
// *  @param context It refers to the <code>RLAMQTTService</code> objective-C object.
// *  @param cause The cause of the connection failure.
// */
//void connectionToBrokerLost(void* context, char const* cause)
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        debug("Connection to broker lost!");
//
//        __weak RLAMQTTService* weakService = (__bridge RLAMQTTService*)context;
//        weakService.connectionState = RelayrConnectionStateDisconnected;
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            RLAMQTTService* service = weakService;  if (!service) { return; }
//            [service connectToBrokerWith:&(RLAMQTTServiceConnectingState){
//                .numConnectionTries = RLAMQTTSERVICE_NUM_CONNECTION_TRIES,
//                .mqttService = (__bridge void*)service
//            }];
//        });
//    });
//}
//
//int messageArrived(void* context, char const* topicName, size_t topicLen, MQTTAsync_message* message)
//{
//    return 0;
//}
//
//void messageDelivered(void* context, MQTTAsync_token token)
//{
//
//}

@end
