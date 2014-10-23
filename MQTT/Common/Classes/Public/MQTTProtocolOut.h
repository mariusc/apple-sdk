/*!
 *  @abstract Functions dealing with the MQTT protocol exchanges.
 *  @discussion Some other related functions are in the MQTTProtocolClient module.
 */
#pragma once

#include "LinkedList.h"         // MQTT (Utilities)
#include "MQTTPacket.h"         // MQTT (Public)
#include "Clients.h"            // MQTT (Private)
#include "Log.h"                // MQTT (Utilities)
#include "Messages.h"           // MQTT (Private)
#include "MQTTProtocol.h"       // MQTT (Public)
#include "MQTTProtocolClient.h" // MQTT (Public)

#define DEFAULT_PORT 1883

/*!
 *  @abstract MQTT outgoing connect processing for a client.
 *
 *  @param ip_address the TCP address:port to connect to.
 *  @param aClient a structure with all MQTT data needed.
 *  @param int ssl.
 *  @param int MQTTVersion the MQTT version to connect with (3 or 4).
 *  @return return code.
 */
#if defined(OPENSSL)
int MQTTProtocol_connect(const char* ip_address, Clients* acClients, int ssl, int MQTTVersion);
#else
int MQTTProtocol_connect(const char* ip_address, Clients* acClients, int MQTTVersion);
#endif

/*!
 *  @abstract Process an incoming pingresp packet for a socket.
 *
 *  @param pack pointer to the publish packet.
 *  @param sock the socket on which the packet was received.
 *  @return completion code.
 */
int MQTTProtocol_handlePingresps(void* pack, int sock);

/*!
 *  @abstract MQTT outgoing subscribe processing for a client.
 *
 *  @param client the client structure.
 *  @param topics list of topics.
 *  @param qoss corresponding list of QoSs.
 *  @return completion code.
 */
int MQTTProtocol_subscribe(Clients* client, List* topics, List* qoss, int msgID);

/*!
 *  @abstract Process an incoming suback packet for a socket.
 *
 *  @param pack pointer to the publish packet
 *  @param sock the socket on which the packet was received
 *  @return completion code
 */
int MQTTProtocol_handleSubacks(void* pack, int sock);

/*!
 *  @abstract MQTT outgoing unsubscribe processing for a client.
 *
 *  @param client the client structure.
 *  @param topics list of topics.
 *  @return completion code.
 */
int MQTTProtocol_unsubscribe(Clients* client, List* topics, int msgID);

/*!
 *  @abstract Process an incoming unsuback packet for a socket.
 *
 *  @param pack pointer to the publish packet.
 *  @param sock the socket on which the packet was received.
 *  @return completion code.
 */
int MQTTProtocol_handleUnsubacks(void* pack, int sock);
