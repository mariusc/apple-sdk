/*!
 * @abstract Functions dealing with the MQTT protocol exchanges.
 * @discussion Some other related functions are in the MQTTProtocolOut module.
 */
#pragma once

#include "LinkedList.h"     // MQTT (Utilities)
#include "MQTTPacket.h"     // MQTT (Public)
#include "Log.h"            // MQTT (Utilities)
#include "MQTTProtocol.h"   // MQTT (Public)
#include "Messages.h"       // MQTT (Private)

#pragma mark Definitions

#define MAX_MSG_ID 65535
#define MAX_CLIENTID_LEN 65535

#pragma mark Public API

/*!
 *  @abstract Start a new publish exchange.  Store any state necessary and try to send the packet.
 *
 *  @param pubclient the client to send the publication to
 *  @param publish the publication data
 *  @param qos the MQTT QoS to use
 *  @param retained boolean - whether to set the MQTT retained flag
 *  @param mm - pointer to the message to send
 *  @return the completion code
 */
int MQTTProtocol_startPublish(Clients* pubclient, Publish* publish, int qos, int retained, Messages** m);

/*!
 *  @abstract Copy and store message data for retries.
 *
 *  @param publish the publication data
 *  @param mm - pointer to the message data to store
 *  @param qos the MQTT QoS to use
 *  @param retained boolean - whether to set the MQTT retained flag
 *  @return pointer to the message data stored
 */
Messages* MQTTProtocol_createMessage(Publish* publish, Messages** mm, int qos, int retained);

/*!
 *  @abstract Store message data for possible retry.
 *
 *  @param publish the publication data.
 *  @param len returned length of the data stored.
 *  @return the publication stored.
 */
Publications* MQTTProtocol_storePublication(Publish* publish, size_t* len);

/*!
 *  @abstract Remove stored message data.
 *  @discussion Opposite of storePublication.
 *
 *  @param p stored publication to remove.
 */
void MQTTProtocol_removePublication(Publications* p);

/*!
 *  @abstract Assign a new message id for a client.  Make sure it isn't already being used and does not exceed the maximum.
 *
 *  @param client a client structure
 *  @return the next message id to use, or 0 if none available
 */
int MQTTProtocol_assignMsgId(Clients* client);

/*!
 *  @abstract Process an incoming publish packet for a socket.
 *
 *  @param pack pointer to the publish packet.
 *  @param sock the socket on which the packet was received.
 *  @return completion code.
 */
int MQTTProtocol_handlePublishes(void* pack, int sock);

/*!
 *  @abstract Process an incoming puback packet for a socket.
 *
 *  @param pack pointer to the publish packet
 *  @param sock the socket on which the packet was received
 *  @return completion code
 */
int MQTTProtocol_handlePubacks(void* pack, int sock);
/*!
 *  @abstract Process an incoming pubrec packet for a socket.
 *
 *  @param pack pointer to the publish packet
 *  @param sock the socket on which the packet was received
 *  @return completion code
 */
int MQTTProtocol_handlePubrecs(void* pack, int sock);

/*!
 *  @abstract Process an incoming pubrel packet for a socket.
 *
 *  @param pack pointer to the publish packet.
 *  @param sock the socket on which the packet was received.
 *  @return completion code.
 */
int MQTTProtocol_handlePubrels(void* pack, int sock);

/*!
 *  @abstract Process an incoming pubcomp packet for a socket.
 *
 *  @param pack pointer to the publish packet.
 *  @param sock the socket on which the packet was received.
 *  @return completion code.
 */
int MQTTProtocol_handlePubcomps(void* pack, int sock);

/*!
 *  @abstract MQTT protocol keepAlive processing.  Sends PINGREQ packets as required.
 *
 *  @param now current time
 */
void MQTTProtocol_keepalive(time_t);

/*!
 *  @abstract MQTT retry protocol and socket pending writes processing.
 *
 *  @param now current time.
 *  @param doRetry boolean - retries as well as pending writes?
 *  @param regardless boolean - retry packets regardless of retry interval (used on reconnect).
 */
void MQTTProtocol_retry(time_t, int, int);

/*!
 *  @abstract Free a client structure.
 *
 *  @param client the client data to free.
 */
void MQTTProtocol_freeClient(Clients* client);

/*!
 *  @abstract Empty a message list, leaving it able to accept new messages.
 *
 *  @param msgList the message list to empty
 */
void MQTTProtocol_emptyMessageList(List* msgList);

/*!
 *  @abstract Empty and free up all storage used by a message list
 *
 *  @param msgList the message list to empty and free
 */
void MQTTProtocol_freeMessageList(List* msgList);

/*!
 *  @abstract List callback function for comparing Message structures by message id
 *
 *  @param a first integer value
 *  @param b second integer value
 *  @return boolean indicating whether a and b are equal
 */
bool messageIDCompare(void const* a, void const* b);

/*!
 *  @abstract Copy no more than dest_size -1 characters from the string pointed to by src to the array pointed to by dest.
 *  @discussion The destination string will always be null-terminated.
 *
 *  @param dest the array which characters copy to
 *  @param src the source string which characters copy from
 *  @param dest_size the size of the memory pointed to by dest: copy no more than this -1 (allow for null).  Must be >= 1
 *  @return the destination string pointer
 */
char* MQTTStrncpy(char *dest, const char* src, size_t num);

/*!
 *  @abstract Duplicate a string, safely, allocating space on the heap.
 *
 *  @param src the source string which characters copy from.
 *  @return the duplicated, allocated string.
 */
char* MQTTStrdup(const char* src);
