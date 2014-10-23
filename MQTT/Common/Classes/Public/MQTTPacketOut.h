/*!
 *  @abstract Functions to deal with reading and writing of MQTT packets from and to sockets
 *  @discussion Some other related functions are in the MQTTPacket module
 */
#pragma once

#include "MQTTPacket.h"     // MQTT (Public)

/*!
 *  @abstract Send an MQTT CONNECT packet down a socket.
 *
 *  @param client a structure from which to get all the required values
 *  @param MQTTVersion the MQTT version to connect with
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_connect(Clients* client, int MQTTVersion);

/*!
 *  @abstract Function used in the new packets table to create connack packets.
 *
 *  @param aHeader the MQTT header byte
 *  @param data the rest of the packet
 *  @param datalen the length of the rest of the packet
 *  @return pointer to the packet structure
 */
void* MQTTPacket_connack(unsigned char aHeader, char* data, size_t datalen);

/*!
 *  @abstract Send an MQTT PINGREQ packet down a socket.
 *
 *  @param socket the open socket to send the data to
 *  @param clientID the string client identifier, only used for tracing
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_pingreq(networkHandles* net, const char* clientID);

/*!
 *  @abstract Send an MQTT subscribe packet down a socket.
 *
 *  @param topics list of topics
 *  @param qoss list of corresponding QoSs
 *  @param msgid the MQTT message id to use
 *  @param dup boolean - whether to set the MQTT DUP flag
 *  @param socket the open socket to send the data to
 *  @param clientID the string client identifier, only used for tracing
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_subscribe(List* topics, List* qoss, int msgid, int dup, networkHandles* net, const char* clientID);

/*!
 *  @abstract Function used in the new packets table to create suback packets.
 *
 *  @param aHeader the MQTT header byte
 *  @param data the rest of the packet
 *  @param datalen the length of the rest of the packet
 *  @return pointer to the packet structure
 */
void* MQTTPacket_suback(unsigned char aHeader, char* data, size_t datalen);

/*!
 *  @abstract Send an MQTT unsubscribe packet down a socket.
 *
 *  @param topics list of topics
 *  @param msgid the MQTT message id to use
 *  @param dup boolean - whether to set the MQTT DUP flag
 *  @param socket the open socket to send the data to
 *  @param clientID the string client identifier, only used for tracing
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_unsubscribe(List* topics, int msgid, int dup, networkHandles* net, const char* clientID);
