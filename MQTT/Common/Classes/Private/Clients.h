/*!
 *  @abstract Functions which apply to client structures.
 */
#pragma once

#include <stdbool.h>                // C Standard
#include <time.h>                   // C Standard
#if defined(OPENSSL)
    #include <openssl/ssl.h>
#endif
#include "MQTTClient.h"             // MQTT (Public)
#include "MQTTClientPersistence.h"  // MQTT (Public)
#include "LinkedList.h"             // MQTT (Utilities)

#pragma mark Definitions

/*!
 *  @abstract Configuration data related to all clients.
 *
 *  @field version The MQTT library version running for all the clients. This value never changes after being set up.
 *  @field clients A list of clients running concurrently on the current system.
 */
typedef struct
{
    char const* const version;
    List* clients;
} ClientStates;

/*!
 *  @abstract Stored publication data to minimize copying.
 */
typedef struct
{
	char* topic;
	int topiclen;
	char* payload;
	int payloadlen;
	int refcount;
} Publications;

/*!
 *  @abstract Client publication message data.
 */
typedef struct
{
	int qos;
	int retain;
	int msgid;
	Publications *publish;
	time_t lastTouch;		// Used for retry and expiry.
	char nextMessageType;	// PUBREC, PUBREL, PUBCOMP
	int len;				// Length of the whole structure+data
} Messages;

/*!
 *  @abstract Client will message data
 */
typedef struct
{
	char* topic;
	char* msg;
	int retained;
	int qos;
} willMessages;

/*!
 *  @abstract Network related data
 */
typedef struct
{
	int socket;
	time_t lastSent;
	time_t lastReceived;
    #if defined(OPENSSL)
	SSL* ssl;
	SSL_CTX* ctx;
    #endif
} networkHandles;

/*!
 *  @abstract Data related to one client
 */
typedef struct
{
	char* clientID;                 // The string ID of the client
	const char* username;           // MQTT v3.1 user name
	const char* password;           // MQTT v3.1 password
	unsigned int cleansession : 1;	// MQTT clean session flag
	unsigned int connected : 1;		// Whether it is currently connected
	unsigned int good : 1; 			// If we have an error on the socket we turn this off
	unsigned int ping_outstanding : 1;
	int connect_state : 4;
	networkHandles net;
	int msgID;
	int keepAliveInterval;
	int retryInterval;
	int maxInflightMessages;
	willMessages* will;
	List* inboundMsgs;
	List* outboundMsgs;             // In flight
	List* messageQueue;
	unsigned int qentry_seqno;
	void* phandle;                  // The persistence handle
	MQTTClient_persistence* persistence; // A persistence implementation
	void* context;                  // Calling context - used when calling disconnect_internal */
	int MQTTVersion;
    #if defined(OPENSSL)
	MQTTClient_SSLOptions *sslopts;
	SSL_SESSION* session;           // SSL session pointer for fast handhake
    #endif
} Clients;

#pragma mark Comparison functions

/*!
 *  @abstract List callback function for comparing clients by clientid
 *
 *  @param a First integer value
 *  @param b Second integer value
 *  @return Boolean indicating whether a and b are equal
 */
bool clientIDCompare(void const* a, void const* b);

/*!
 *  @abstract List callback function for comparing clients by socket
 *
 *  @param a First integer value
 *  @param b Second integer value
 *  @return Boolean indicating whether a and b are equal
 */
bool clientSocketCompare(void const* a, void const* b);
