#import "RLAMQTTService.h"          // Header
#import "RelayrUser.h"              // Relayr.framework (Public)
#import "RelayrErrors.h"            // Relayr.framework (Public)
#import "RelayrTransmitter.h"       // Relayr.framework (Public)
#import "RelayrDevice.h"            // Relayr.framework (Public)
#import "RelayrUser_Setup.h"        // Relayr.framework (Private)
#import "RLAAPIService.h"           // Relayr.framework (Private)
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
    char const* username;
    char const* password;
} RLAMQTTServiceConnectingState;

#pragma mark - Private prototypes

void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response);
void connectionToBrokerFailed(void* context, MQTTAsync_failureData* response);
void connectionToBrokerLost(void* context, char* cause);
void disconnectionFromBrokerSucceeded(void* context, MQTTAsync_successData* response);
void disconnectionFromBrokerFailed(void* context, MQTTAsync_failureData* response);

int messageArrived(void* context, char* topicName, int topicLen, MQTTAsync_message* message);
//void messageDelivered(void* context, MQTTAsync_token token);

@implementation RLAMQTTService
{
    MQTTAsync _client;
    NSMutableSet* _subscribedDevices;
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
//        _user = user;
//        _connectionState = RelayrConnectionStateUnknown;
//        _connectionScope = RelayrConnectionScopeUnknown;
//        _hostString = [NSString stringWithFormat:@"%@%@", dRLAMQTT_ProtocolSSL, dRLAMQTT_Host];
//        _port = [NSNumber numberWithUnsignedInteger:dRLAMQTT_PortSSL];
//        _client = NULL;
//        _subscribedDevices = [[NSMutableSet alloc] init];
//        
//        _connectionState = RelayrConnectionStateDisconnected;
//
//        NSString* serverURI = [NSString stringWithFormat:@"%@:%lu", _hostString, _port.unsignedLongValue];
//        int status = MQTTAsync_create(&_client, [serverURI cStringUsingEncoding:NSUTF8StringEncoding], RLAMQTTSERVICE_CLIENTID, MQTTCLIENT_PERSISTENCE_NONE, NULL);
//        if (status!=MQTTASYNC_SUCCESS || _client==NULL) { return nil; }
//
//        MQTTAsync_setCallbacks(_client, (__bridge void*)self, connectionToBrokerLost, messageArrived, NULL);
//        status = [self connectToBrokerWith:&(RLAMQTTServiceConnectingState){
//            .numConnectionTries = RLAMQTTSERVICE_NUM_CONNECTION_TRIES,
//            .mqttService = (__bridge void*)self
//        }];
//        if (status != MQTTASYNC_SUCCESS) { MQTTAsync_destroy(&_client); return nil; }
    }
    return self;
}

// FIXME: Delete this as soon as the server guys finish.
- (instancetype)initWithUser:(RelayrUser *)user device:(RelayrDevice *)device
{
    RelayrTransmitter* transmitter = device.transmitter;
    if (!transmitter.uid) { return nil; }
    
    self = [super init];
    {
        _user = user;
        _connectionState = RelayrConnectionStateUnknown;
        _connectionScope = RelayrConnectionScopeUnknown;
        _hostString = [NSString stringWithFormat:@"%@%@", dRLAMQTT_ProtocolSSL, dRLAMQTT_Host];
        _port = [NSNumber numberWithUnsignedInteger:dRLAMQTT_PortSSL];
        _client = NULL;
        _subscribedDevices = [[NSMutableSet alloc] init];
        
        NSString* serverURI = [NSString stringWithFormat:@"%@:%lu", _hostString, _port.unsignedLongValue];
        NSString* randomClientID = [RLAIdentifierGenerator randomIDWithMaximumRandomNumber:65535];
        int status = MQTTAsync_create(&_client, [serverURI cStringUsingEncoding:NSUTF8StringEncoding], [randomClientID cStringUsingEncoding:NSUTF8StringEncoding], MQTTCLIENT_PERSISTENCE_NONE, NULL);
        if (status!=MQTTASYNC_SUCCESS || _client==NULL) { return nil; }
        
        MQTTAsync_setCallbacks(_client, (__bridge void*)self, connectionToBrokerLost, messageArrived, NULL);
        status = [self connectToBrokerWith:&(RLAMQTTServiceConnectingState){
            .numConnectionTries = RLAMQTTSERVICE_NUM_CONNECTION_TRIES,
            .mqttService = (__bridge void*)self,
            .username = [transmitter.uid cStringUsingEncoding:NSUTF8StringEncoding],
            .password = [transmitter.secret cStringUsingEncoding:NSUTF8StringEncoding]
        }];
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

}

- (void)subscribeToDataFromDevice:(RelayrDevice*)device completion:(void (^)(NSError* error))completion
{
//    RelayrConnectionState const netConnection = _user.apiService.connectionState;
//    NSError* error = [RLAAPIService internetErrorForConnectionState:netConnection];
//    if (error) { if (completion) { completion(error); } return; }
//    
//    // Check if the device was already subscribed.
//    if ([_subscribedDevices containsObject:device]) { return; }
//    [_subscribedDevices addObject:device];
//    
//    if (self.connectionState == RelayrConnectionStateConnected)
//    {
//
//    }
//    else
//    {
//
//    }
    debug("Device asking for subscription");
}

- (void)unsubscribeToDataFromDevice:(RelayrDevice*)device
{

}

#pragma mark - Private functionality

- (int)connectToBrokerWith:(RLAMQTTServiceConnectingState*)connectingState
{
    if (connectingState==NULL || connectingState->numConnectionTries==0) { return MQTTASYNC_FAILURE; }

    debug("Connecting to broker...\n");
    _connectionState = RelayrConnectionStateConnecting;
    connectingState->numConnectionTries--;

    MQTTAsync_connectOptions opts = MQTTAsync_connectOptions_initializer;
    opts.keepAliveInterval = 20;
    opts.cleansession = 1;
    opts.onSuccess = connectionToBrokerSucceeded;
    opts.onFailure = connectionToBrokerFailed;
    opts.context = malloc_copyStruct(RLAMQTTServiceConnectingState, opts.context, *connectingState);
    opts.username = connectingState->username;
    opts.password = connectingState->password;
    
    int const connectionAcceptedStatus = MQTTAsync_connect(_client, &opts);
    if (connectionAcceptedStatus != MQTTASYNC_SUCCESS)
    {
        _connectionState = RelayrConnectionStateDisconnected;
        free(opts.context);
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
        free(connectingState);
    });
}

void connectionToBrokerSucceeded(void* context, MQTTAsync_successData* response)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        debug("Connection to broker succeeded!\n");
        
        RLAMQTTServiceConnectingState* connectingState = context;
        RLAMQTTService* service = (__bridge RLAMQTTService*)connectingState->mqttService;
        
        service.connectionState = RelayrConnectionStateConnected;
        free(connectingState);
    });
}

/*!
 *  @abstract This method is received once the connection with the broker is lost.
 *  @discussion This method is executed on a backgroudn thread.
 *
 *  @param context It refers to the <code>RLAMQTTService</code> objective-C object.
 *  @param cause The cause of the connection failure.
 */
void connectionToBrokerLost(void* context, char* cause)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        debug("Connection to broker lost!\n");
        
        __weak RLAMQTTService* weakService = (__bridge RLAMQTTService*)context;
        weakService.connectionState = RelayrConnectionStateDisconnected;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            RLAMQTTService* service = weakService;  if (!service) { return; }
            [service connectToBrokerWith:&(RLAMQTTServiceConnectingState){
                .numConnectionTries = RLAMQTTSERVICE_NUM_CONNECTION_TRIES,
                .mqttService = (__bridge void*)service
            }];
        });
    });
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

//void messageDelivered(void* context, MQTTAsync_token token)
//{
//
//}

- (NSString*)deviceIDFromTopic:(NSString*)topicName
{
    return nil;
}

@end
