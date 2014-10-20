#pragma once

#include "LinkedList.h"
#include "MQTTPacket.h"
#include "Clients.h"
#include "Log.h"
#include "Messages.h"
#include "MQTTProtocol.h"
#include "MQTTProtocolClient.h"

#define DEFAULT_PORT 1883

void MQTTProtocol_reconnect(const char* ip_address, Clients* client);
#if defined(OPENSSL)
int MQTTProtocol_connect(const char* ip_address, Clients* acClients, int ssl, int MQTTVersion);
#else
int MQTTProtocol_connect(const char* ip_address, Clients* acClients, int MQTTVersion);
#endif
int MQTTProtocol_handlePingresps(void* pack, int sock);
int MQTTProtocol_subscribe(Clients* client, List* topics, List* qoss, int msgID);
int MQTTProtocol_handleSubacks(void* pack, int sock);
int MQTTProtocol_unsubscribe(Clients* client, List* topics, int msgID);
int MQTTProtocol_handleUnsubacks(void* pack, int sock);
