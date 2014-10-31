#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "MQTTAsync.h"

#define ADDRESS     "tcp://localhost:1883"
#define CLIENTID    "ExampleClientSub"
#define TOPIC       "MQTT Examples"
#define PAYLOAD     "Hello World!"
#define QOS         1
#define TIMEOUT     10000L

#pragma mark - Private prototypes

void onConnectFailure(void* context, MQTTAsync_failureData* response);
void onConnect(void* context, MQTTAsync_successData* response);
void connlost(void* context, char* cause);
int msgarrvd(void *context, char *topicName, int topicLen, MQTTAsync_message *message);
void onDisconnect(void* context, MQTTAsync_successData* response);
void onSubscribe(void* context, MQTTAsync_successData* response);
void onSubscribeFailure(void* context, MQTTAsync_failureData* response);

#pragma mark - Variables

volatile MQTTAsync_token deliveredtoken;

int disc_finished = 0;
int subscribed = 0;
int finished = 0;

#pragma mark - Public API

int main(int argc, char* argv[])
{
    MQTTAsync client;
    MQTTAsync_create(&client, ADDRESS, CLIENTID, MQTTCLIENT_PERSISTENCE_NONE, NULL);
    MQTTAsync_setCallbacks(client, NULL, connlost, msgarrvd, NULL);
    
    MQTTAsync_connectOptions conn_opts = MQTTAsync_connectOptions_initializer;
    conn_opts.keepAliveInterval = 20;
    conn_opts.cleansession = 1;
    conn_opts.onSuccess = onConnect;
    conn_opts.onFailure = onConnectFailure;
    conn_opts.context = client;
    
    int rc = MQTTAsync_connect(client, &conn_opts);
    if (rc != MQTTCODE_SUCCESS)
    {
        printf("Failed to start connect, return code %d\n", rc);
        exit(-1);
    }
    
    while (!subscribed) { usleep(10000L); }
    if (finished) { goto exit; }
    
    int ch;
    do
    {
        ch = getchar();
    } while (ch!='Q' && ch != 'q');
    
    MQTTAsync_disconnectOptions disc_opts = MQTTAsync_disconnectOptions_initializer;
    disc_opts.onSuccess = onDisconnect;
    
    rc = MQTTAsync_disconnect(client, &disc_opts)
    if (rc != MQTTCODE_SUCCESS)
    {
        printf("Failed to start disconnect, return code %d\n", rc);
        exit(-1);
    }
    while (!disc_finished) { usleep(10000L); }
    
exit:
    MQTTAsync_destroy(&client);
    return rc;
}

void onConnectFailure(void* context, MQTTAsync_failureData* response)
{
    printf("Connect failed, rc %d\n", response ? response->code : 0);
    finished = 1;
}

void onConnect(void* context, MQTTAsync_successData* response)
{
    MQTTAsync client = (MQTTAsync)context;
    printf("Subscribing to topic %s\nfor client %s using QoS%d\n\n" "Press Q<Enter> to quit\n\n", TOPIC, CLIENTID, QOS);
    
    MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
    opts.onSuccess = onSubscribe;
    opts.onFailure = onSubscribeFailure;
    opts.context = client;
    
    deliveredtoken = 0;
    
    int rc = MQTTAsync_subscribe(client, TOPIC, QOS, &opts);
    if (rc != MQTTCODE_SUCCESS)
    {
        printf("Failed to start subscribe, return code %d\n", rc);
        exit(-1);
    }
}

void connlost(void* context, char* cause)
{
    MQTTAsync client = (MQTTAsync)context;
    printf("\nConnection lost\n     cause: %s\nReconnecting\n", cause);
    
    MQTTAsync_connectOptions conn_opts = MQTTAsync_connectOptions_initializer;
    conn_opts.keepAliveInterval = 20;
    conn_opts.cleansession = 1;
    
    int rc = MQTTAsync_connect(client, &conn_opts)
    if (rc != MQTTCODE_SUCCESS)
    {
        printf("Failed to start connect, return code %d\n", rc);
        finished = 1;
    }
}


int msgarrvd(void *context, char *topicName, int topicLen, MQTTAsync_message *message)
{
    printf("Message arrived\n     topic: %s\n   message: ", topicName);
    
    char* payloadptr = message->payload;
    for(int i=0; i<message->payloadlen; i++) { putchar(*payloadptr++); }
    putchar('\n');
    MQTTAsync_freeMessage(&message);
    MQTTAsync_free(topicName);
    return 1;
}


void onDisconnect(void* context, MQTTAsync_successData* response)
{
    printf("Successful disconnection\n");
    disc_finished = 1;
}


void onSubscribe(void* context, MQTTAsync_successData* response)
{
    printf("Subscribe succeeded\n");
    subscribed = 1;
}

void onSubscribeFailure(void* context, MQTTAsync_failureData* response)
{
    printf("Subscribe failed, rc %d\n", response ? response->code : 0);
    finished = 1;
}
