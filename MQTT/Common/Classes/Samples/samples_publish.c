#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "MQTTAsync.h"

#define ADDRESS     "tcp://localhost:1883"
#define CLIENTID    "ExampleClientPub"
#define TOPIC       "MQTT Examples"
#define PAYLOAD     "Hello World!"
#define QOS         1
#define TIMEOUT     10000L

#pragma mark - Private prototypes

void onConnectFailure(void* context, MQTTAsync_failureData* response);
void onConnect(void* context, MQTTAsync_successData* response);
void connlost(void *context, char *cause);
void onDisconnect(void* context, MQTTAsync_successData* response);
void onSend(void* context, MQTTAsync_successData* response);

#pragma mark - Variables

volatile MQTTAsync_token deliveredtoken;
int finished = 0;

#pragma mark - Public API

int main(int argc, char* argv[])
{
    MQTTAsync client;
    MQTTAsync_create(&client, ADDRESS, CLIENTID, MQTTCLIENT_PERSISTENCE_NONE, NULL);
    MQTTAsync_setCallbacks(client, NULL, connlost, NULL, NULL);
    
    MQTTAsync_connectOptions conn_opts = MQTTAsync_connectOptions_initializer;
    conn_opts.keepAliveInterval = 20;
    conn_opts.cleansession = 1;
    conn_opts.onSuccess = onConnect;
    conn_opts.onFailure = onConnectFailure;
    conn_opts.context = client;
    
    int const rc = MQTTAsync_connect(client, &conn_opts);
    if (rc != MQTTCODE_SUCCESS)
    {
        printf("Failed to start connect, return code %d\n", rc);
        exit(-1);
    }
    
    printf("Waiting for publication of %s\n" "on topic %s for client with ClientID: %s\n", PAYLOAD, TOPIC, CLIENTID);
    while (!finished) { usleep(10000L); }
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
    printf("Successful connection\n");
    
    MQTTAsync_message pubmsg = MQTTAsync_message_initializer;
    pubmsg.payload = PAYLOAD;
    pubmsg.payloadlen = strlen(PAYLOAD);
    pubmsg.qos = QOS;
    pubmsg.retained = 0;
    deliveredtoken = 0;
    
    MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
    opts.onSuccess = onSend;
    opts.context = client;
    
    int rc = MQTTAsync_sendMessage(client, TOPIC, &pubmsg, &opts);
    if (rc != MQTTCODE_SUCCESS)
    {
        printf("Failed to start sendMessage, return code %d\n", rc);
        exit(-1);
    }
}

void connlost(void *context, char *cause)
{
    MQTTAsync client = (MQTTAsync)context;
    MQTTAsync_connectOptions conn_opts = MQTTAsync_connectOptions_initializer;
    int rc;
    
    printf("\nConnection lost\n");
    printf("     cause: %s\n", cause);
    
    printf("Reconnecting\n");
    conn_opts.keepAliveInterval = 20;
    conn_opts.cleansession = 1;
    if ((rc = MQTTAsync_connect(client, &conn_opts)) != MQTTCODE_SUCCESS)
    {
        printf("Failed to start connect, return code %d\n", rc);
        finished = 1;
    }
}

void onSend(void* context, MQTTAsync_successData* response)
{
    MQTTAsync client = (MQTTAsync)context;
    MQTTAsync_disconnectOptions opts = MQTTAsync_disconnectOptions_initializer;
    int rc;
    
    printf("Message with token value %d delivery confirmed\n", response->token);
    
    opts.onSuccess = onDisconnect;
    opts.context = client;
    
    if ((rc = MQTTAsync_disconnect(client, &opts)) != MQTTCODE_SUCCESS)
    {
        printf("Failed to start sendMessage, return code %d\n", rc);
        exit(-1);
    }
}

void onDisconnect(void* context, MQTTAsync_successData* response)
{
    printf("Successful disconnection\n");
    finished = 1;
}
