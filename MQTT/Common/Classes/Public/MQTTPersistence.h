/*!
 * @abstract Functions that apply to persistence operations.
 */
#pragma once

#include "Clients.h"    // MQTT (Private)

#pragma mark Definitions

// Stem of the key for a sent PUBLISH QoS1 or QoS2
#define PERSISTENCE_PUBLISH_SENT "s-"
// Stem of the key for a sent PUBREL
#define PERSISTENCE_PUBREL "sc-"
// Stem of the key for a received PUBLISH QoS2
#define PERSISTENCE_PUBLISH_RECEIVED "r-"
// Stem of the key for an async client command
#define PERSISTENCE_COMMAND_KEY "c-"
// Stem of the key for an async client message queue
#define PERSISTENCE_QUEUE_KEY "q-"
#define PERSISTENCE_MAX_KEY_LENGTH 8

typedef struct
{
    char struct_id[4];
    int struct_version;
    int payloadlen;
    void* payload;
    int qos;
    int retained;
    int dup;
    int msgid;
} MQTTPersistence_message;

typedef struct
{
    MQTTPersistence_message* msg;
    char* topicName;
    int topicLen;
    unsigned int seqno;     // only used on restore
} MQTTPersistence_qEntry;


#pragma mark Public API

/*!
 *  @abstract Creates a <code>MQTTClient_persistence</code> structure representing a persistence implementation.
 *
 *  @param persistence the <code>MQTTClient_persistence</code> structure..
 *  @param type the type of the persistence implementation. See <code>MQTTClient_create</code>.
 *  @param pcontext the context for this persistence implementation. See <code>MQTTClient_create</code>.
 *  @return 0 if success, #MQTTCLIENT_PERSISTENCE_ERROR otherwise.
 */
int MQTTPersistence_create(MQTTClient_persistence** per, int type, void* pcontext);

/*!
 *  @abstract Open persistent store and restore any persisted messages.
 *
 *  @param client the client as ::Clients.
 *  @param serverURI the URI of the remote end.
 *  @return 0 if success, #MQTTCLIENT_PERSISTENCE_ERROR otherwise.
 */
int MQTTPersistence_initialize(Clients* c, const char* serverURI);

/*!
 *  @abstract Close persistent store.
 *
 *  @param client the client as ::Clients.
 *  @return 0 if success, #MQTTCLIENT_PERSISTENCE_ERROR otherwise.
 */
int MQTTPersistence_close(Clients* c);

/*!
 *  @abstract Clears the persistent store.
 *
 *  @param client the client as ::Clients.
 *  @return 0 if success, #MQTTCLIENT_PERSISTENCE_ERROR otherwise.
 */
int MQTTPersistence_clear(Clients* c);

/*!
 *  @abstract Restores the persisted records to the outbound and inbound message queues of the client.
 *  @param client the client as ::Clients.
 *  @return 0 if success, #MQTTCLIENT_PERSISTENCE_ERROR otherwise.
 */
int MQTTPersistence_restore(Clients* c);

/*!
 *  @abstract Returns a MQTT packet restored from persisted data.
 *
 *  @param buffer the persisted data.
 *  @param buflen the number of bytes of the data buffer.
 */
void* MQTTPersistence_restorePacket(char* buffer, size_t buflen);

/*!
 *  @abstract Inserts the specified message into the list, maintaining message ID order.
 *
 *  @param list the list to insert the message into.
 *  @param content the message to add.
 *  @param size size of the message.
 */
void MQTTPersistence_insertInOrder(List* list, void* content, size_t size);

/*!
 *  @abstract Adds a record to the persistent store. This function must not be called for QoS0 messages.
 *
 *  @param socket the socket of the client.
 *  @param buf0 fixed header.
 *  @param buf0len length of the fixed header.
 *  @param count number of buffers representing the variable header and/or the payload.
 *  @param buffers the buffers representing the variable header and/or the payload.
 *  @param buflens length of the buffers representing the variable header and/or the payload.
 *  @param msgId the message ID.
 *  @param scr 0 indicates message in the sending direction; 1 indicates message in the receiving direction.
 *  @return 0 if success, #MQTTCLIENT_PERSISTENCE_ERROR otherwise.
 */
int MQTTPersistence_put(int socket, char* buf0, size_t buf0len, size_t count, char** buffers, size_t* buflens, int htype, int msgId, int scr);

/*!
 *  @abstract Deletes a record from the persistent store.
 *  @param client the client as ::Clients.
 *  @param type the type of the persisted record: #PERSISTENCE_PUBLISH_SENT, #PERSISTENCE_PUBREL or #PERSISTENCE_PUBLISH_RECEIVED.
 *  @param qos the qos field of the message.
 *  @param msgId the message ID.
 *  @return 0 if success, #MQTTCLIENT_PERSISTENCE_ERROR otherwise.
 */
int MQTTPersistence_remove(Clients* c, char* type, int qos, int msgId);

/*!
 *  @abstract Checks whether the message IDs wrapped by looking for the largest gap between two consecutive message IDs in the outboundMsgs queue.
 *  @param client the client as ::Clients.
 */
void MQTTPersistence_wrapMsgID(Clients *c);

int MQTTPersistence_unpersistQueueEntry(Clients* client, MQTTPersistence_qEntry* qe);

int MQTTPersistence_persistQueueEntry(Clients* aclient, MQTTPersistence_qEntry* qe);

/*!
 *  @abstract Restores a queue of messages from persistence to memory
 *  @param c the client as ::Clients - the client object to restore the messages to
 *  @return return code, 0 if successful
 */
int MQTTPersistence_restoreMessageQueue(Clients* c);
