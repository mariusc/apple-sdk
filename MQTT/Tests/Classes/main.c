#include <stdio.h>              // C Standard
#include <stdlib.h>             // C Standard
#include <string.h>             // C Standard
#include <stdbool.h>            // C Standard
#include <unistd.h>             // POSIX
#include <MQTT/MQTTAsync.h>     // MQTT Static library

#pragma mark - Definitions

#define ADDRESS     "ssl://mqtt.relayr.io:8883"
#define CLIENTID    "manolete"
#define USERNAME    "99a1cfd0-5282-40ce-a73c-ed9ca7c2f01b"
#define PASSWORD    "GZNxt38J75Qu"
#define TOPIC_PUB   "/v1/e2744ce1-4f1b-47ed-aac1-6454d9097409/data"
#define TOPIC_SUB   "/v1/e2744ce1-4f1b-47ed-aac1-6454d9097409/+"
#define QOS         1
#define TIMEOUT     10000L

#pragma mark - Variables

volatile MQTTAsync_token deliveredtoken;

#pragma mark - Private prototypes

int connectMQTT(MQTTAsync client);
void onConnectFailure(void* context, MQTTAsync_failureData* response);
void onConnect(void* context, MQTTAsync_successData* response);
void connlost(void *context, char* cause);

int publishMessage(MQTTAsync client);
void onSend(void* context, MQTTAsync_successData* response);
void onSendFailure(void* context, MQTTAsync_failureData* response);

int subscribeToData(MQTTAsync client);
void onSubscribeFailure(void* context, MQTTAsync_failureData* response);
void onSubscribe(void* context, MQTTAsync_successData* response);
int msgarrvd(void *context, char* topicName, int topicLen, MQTTAsync_message* message);

void onDisconnect(void* context, MQTTAsync_successData* response);
void onDisconnectFailure(void* context, MQTTAsync_failureData* response);

#pragma mark - Public API

int main(int argc, char* argv[])
{
    MQTTAsync client;
    int status = MQTTAsync_create(&client, ADDRESS, CLIENTID, MQTTCLIENT_PERSISTENCE_NONE, NULL);
    if (status != MQTTASYNC_SUCCESS) { printf("Not able to create an MQTTAsync object.\n"); exit(-1); }
    MQTTAsync_setCallbacks(client, NULL, connlost, msgarrvd, NULL);
    
    status = connectMQTT(client);
    if (status != MQTTASYNC_SUCCESS) { printf("MQTTAsync object not accepted for connection with code: %d.\n", status); goto salida; }
    
    while (true) { usleep(10000L); }
salida:
    MQTTAsync_destroy(&client);
    return status;
}

#pragma mark - Private functionality

int connectMQTT(MQTTAsync client)
{
    printf("Connecting to broker...\n");
    
    MQTTAsync_connectOptions opts = MQTTAsync_connectOptions_initializer;
    opts.keepAliveInterval = 20;
    opts.cleansession = 1;
    opts.username = USERNAME;
    opts.password = PASSWORD;
    opts.onSuccess = onConnect;
    opts.onFailure = onConnectFailure;
    opts.context = client;
    
    static MQTTAsync_SSLOptions opts_ssl = MQTTAsync_SSLOptions_initializer;
    opts_ssl.enableServerCertAuth = 0;
    opts.ssl = &opts_ssl;
    return MQTTAsync_connect(client, &opts);
}

void onConnectFailure(void* context, MQTTAsync_failureData* response)
{
    printf("Connection failed witch code: %d, error message: %s\n", response ? response->code : 0, response ? response->message : NULL);
    
    MQTTAsync client = (MQTTAsync)context;
    MQTTAsync_destroy(&client);
    exit(EXIT_SUCCESS);
}

void onConnect(void* context, MQTTAsync_successData* response)
{
    printf("Successful connection!\n\nSubscribing to %s ...\n", TOPIC_SUB);
    
    MQTTAsync client = (MQTTAsync)context;
    int status = subscribeToData(client);
    if (status != MQTTASYNC_SUCCESS)
    {
        printf("Subscription not accepted.\n\nDisconnecting...\n");
        MQTTAsync_disconnectOptions disconnect_opts = MQTTAsync_disconnectOptions_initializer;
        disconnect_opts.timeout = 1;
        disconnect_opts.onSuccess = onDisconnect;
        disconnect_opts.onFailure = onDisconnectFailure;
        disconnect_opts.context = client;
        
        MQTTAsync_disconnect(client, &disconnect_opts);
    }
}

void connlost(void *context, char *cause)
{
    MQTTAsync client = (MQTTAsync)context;
    
    printf("\nConnection lost\n\t\tcause: %s\n", cause);
    
    int status = connectMQTT(client);
    if (status != MQTTASYNC_SUCCESS) { printf("MQTTAsync object not accepted for connection. Status %d.\n", status); exit(EXIT_FAILURE); }
}

int publishMessage(MQTTAsync client)
{
    MQTTAsync_message pubmsg = MQTTAsync_message_initializer;
    pubmsg.payload = "Hello World!";
    pubmsg.payloadlen = (int)strlen(pubmsg.payload);
    pubmsg.qos = QOS;
    pubmsg.retained = 0;
    
    MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
    opts.onSuccess = onSend;
    opts.onFailure = onSendFailure;
    opts.context = client;
    
    return MQTTAsync_sendMessage(client, TOPIC_PUB, &pubmsg, &opts);
}

void onSend(void* context, MQTTAsync_successData* response)
{
    printf("Message send successfully!\n\nSubscribing to %s ...\n", TOPIC_SUB);
    
    MQTTAsync client = (MQTTAsync)context;
    int status = subscribeToData(client);
    if (status != MQTTASYNC_SUCCESS)
    {
        printf("Subscription not accepted.\n\nDisconnecting...\n");
        MQTTAsync_disconnectOptions disconnect_opts = MQTTAsync_disconnectOptions_initializer;
        disconnect_opts.timeout = 1;
        disconnect_opts.onSuccess = onDisconnect;
        disconnect_opts.onFailure = onDisconnectFailure;
        disconnect_opts.context = client;
        
        MQTTAsync_disconnect(client, &disconnect_opts);
    }
}

void onSendFailure(void* context, MQTTAsync_failureData* response)
{
    printf("Message sent failed with status: %d, message: %s.!\n\nSubscribing to %s...", (response) ? response->code : 0, (response) ? response->message : NULL, TOPIC_SUB);
    
    MQTTAsync client = (MQTTAsync)context;
    int status = subscribeToData(client);
    if (status != MQTTASYNC_SUCCESS)
    {
        printf("Subscription not accepted.\n\nDisconnecting...\n");
        MQTTAsync_disconnectOptions disconnect_opts = MQTTAsync_disconnectOptions_initializer;
        disconnect_opts.timeout = 1;
        disconnect_opts.onSuccess = onDisconnect;
        disconnect_opts.onFailure = onDisconnectFailure;
        disconnect_opts.context = client;
        
        MQTTAsync_disconnect(client, &disconnect_opts);
    }
}

int subscribeToData(MQTTAsync client)
{
    MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
    opts.onSuccess = onSubscribe;
    opts.onFailure = onSubscribeFailure;
    opts.context = client;
    
    return MQTTAsync_subscribe(client, TOPIC_SUB, QOS, &opts);
}

void onSubscribeFailure(void* context, MQTTAsync_failureData* response)
{
    printf("Subscription failed with code: %d, message: %s\n\nDisconnecting...\n", (response) ? response->code : 0, (response) ? response->message : 0);
    
    MQTTAsync client = (MQTTAsync)context;
    
    MQTTAsync_disconnectOptions disconnect_opts = MQTTAsync_disconnectOptions_initializer;
    disconnect_opts.timeout = 1;
    disconnect_opts.onSuccess = onDisconnect;
    disconnect_opts.onFailure = onDisconnectFailure;
    disconnect_opts.context = client;
    MQTTAsync_disconnect(client, &disconnect_opts);
}

void onSubscribe(void* context, MQTTAsync_successData* response)
{
    printf("Subscription succeeded!\n\n");
}

int msgarrvd(void* context, char* topicName, int topicLen, MQTTAsync_message* message)
{
    printf("Message arrived withtopic: %s and message: \n", topicName);
    
    char* payloadptr = message->payload;
    for(int i=0; i<message->payloadlen; i++) { putchar(*payloadptr++); }
    putchar('\n');
    putchar('\n');
    
    MQTTAsync_freeMessage(&message);
    MQTTAsync_free(topicName);
    return 1;
}

void onDisconnect(void* context, MQTTAsync_successData* response)
{
    printf("Disconnected.\n\n");
    
    MQTTAsync client = (MQTTAsync)context;
    MQTTAsync_destroy(&client);
    exit(EXIT_SUCCESS);
}

void onDisconnectFailure(void* context, MQTTAsync_failureData* response)
{
    printf("Failed disconnecting with status: %d, error message: %s\n\n", (response) ? response->code : 0, (response) ? response->message : NULL);
    
    MQTTAsync client = (MQTTAsync)context;
    MQTTAsync_destroy(&client);
    exit(EXIT_FAILURE);
}
