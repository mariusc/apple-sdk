#pragma once

#include "LinkedList.h"     // MQTT (Utilities)
#include "MQTTPacket.h"     // MQTT (Public)
#include "Clients.h"        // MQTT (Private)

#define MAX_MSG_ID 65535
#define MAX_CLIENTID_LEN 65535

typedef struct
{
	int socket;
	Publications* p;
} pending_write;


typedef struct
{
	List publications;
	unsigned int msgs_received;
	unsigned int msgs_sent;
	List pending_writes; /* for qos 0 writes not complete */
} MQTTProtocol;

#include "MQTTProtocolOut.h"    // MQTT (Public)
