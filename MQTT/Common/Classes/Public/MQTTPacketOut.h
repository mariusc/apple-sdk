#pragma once

#include "MQTTPacket.h"

int MQTTPacket_send_connect(Clients* client, int MQTTVersion);
void* MQTTPacket_connack(unsigned char aHeader, char* data, size_t datalen);

int MQTTPacket_send_pingreq(networkHandles* net, const char* clientID);

int MQTTPacket_send_subscribe(List* topics, List* qoss, int msgid, int dup, networkHandles* net, const char* clientID);
void* MQTTPacket_suback(unsigned char aHeader, char* data, size_t datalen);

int MQTTPacket_send_unsubscribe(List* topics, int msgid, int dup, networkHandles* net, const char* clientID);
