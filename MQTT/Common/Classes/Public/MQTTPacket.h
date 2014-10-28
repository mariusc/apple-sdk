/*!
 *  @abstract functions to deal with reading and writing of MQTT packets from and to sockets
 *  @discussion Some other related functions are in the MQTTPacketOut module
 */
#pragma once

#include "Socket.h"     // MQTT (Web)
#if defined(OPENSSL)
#include "SSLSocket.h"  // MQTT (Web)
#endif
#include "LinkedList.h" // MQTT (Utilities)
#include "Clients.h"    // MQTT (Utilities)

#pragma mark Definitions

typedef unsigned int uint_bool;
typedef void* (*pf)(unsigned char, char*, size_t);

#define BAD_MQTT_PACKET -4

enum msgTypes
{
	CONNECT = 1, CONNACK, PUBLISH, PUBACK, PUBREC, PUBREL,
	PUBCOMP, SUBSCRIBE, SUBACK, UNSUBSCRIBE, UNSUBACK,
	PINGREQ, PINGRESP, DISCONNECT
};


/*!
 *  @abstract Bitfields for the MQTT header byte.
 */
typedef union
{
	/*unsigned*/ char byte;	// The whole byte.
    #if defined(REVERSED)
	struct
	{
		unsigned int type : 4;	// Message type nibble.
		uint_bool dup : 1;      // DUP flag bit
		unsigned int qos : 2;	// QoS value, 0, 1 or 2
		uint_bool retain : 1;	// retained flag bit
	} bits;
    #else
	struct
	{
		uint_bool retain : 1;	// Retained flag bit.
		unsigned int qos : 2;	// QoS value, 0, 1 or 2
		uint_bool dup : 1;		// DUP flag bit
		unsigned int type : 4;	// message type nibble
	} bits;
    #endif
} Header;


/*!
 *  @abstract Data for a connect packet.
 */
typedef struct
{
	Header header;          // MQTT header byte.
	union
	{
		unsigned char all;	// All connect flags.
        #if defined(REVERSED)
		struct
		{
			uint_bool username : 1;			// 3.1 user name
			uint_bool password : 1;         // 3.1 password
			uint_bool willRetain : 1;		// Will retain setting
			unsigned int willQoS : 2;       // Will QoS value
			uint_bool will : 1;             // Will flag
			uint_bool cleanstart : 1;       // Cleansession flag
			int : 1;                        // Unused
		} bits;
        #else
		struct
		{
			int : 1;                    // Unused
			uint_bool cleanstart : 1;	// Cleansession flag
			uint_bool will : 1;			// Will flag
			unsigned int willQoS : 2;	// Will QoS value
			uint_bool willRetain : 1;   // Will retain setting
			uint_bool password : 1; 	// 3.1 password
			uint_bool username : 1;     // 3.1 user name
		} bits;
        #endif
	} flags;                // Connect flags byte

	char *Protocol,         // MQTT protocol name
		*clientID,          // string client id
        *willTopic,         // will topic
        *willMsg;           // will payload

	int keepAliveTimer;		// keepalive timeout value in seconds 
	unsigned char version;	// MQTT version number 
} Connect;


/*!
 *  @abstract Data for a connack packet.
 */
typedef struct
{
	Header header; // MQTT header byte 
	union
	{
		unsigned char all;	// all connack flags 
#if defined(REVERSED)
		struct
		{
			unsigned int reserved : 7;	// message type nibble 
			uint_bool sessionPresent : 1;    // was a session found on the server? 
		} bits;
#else
		struct
		{
			uint_bool sessionPresent : 1;    // was a session found on the server? 
			unsigned int reserved : 7;	// message type nibble 
		} bits;
#endif
	} flags;	 // connack flags byte 
	char rc; // connack return code 
} Connack;


/*!
 *  @abstract Data for a packet with header only.
 */
typedef struct
{
	Header header;	// MQTT header byte 
} MQTTPacket;


/*!
 *  @abstract Data for a subscribe packet.
 */
typedef struct
{
	Header header;	// MQTT header byte 
	int msgId;		// MQTT message id 
	List* topics;	// list of topic strings 
	List* qoss;		// list of corresponding QoSs 
	int noTopics;	// topic and qos count 
} Subscribe;


/*!
 *  @abstract Data for a suback packet.
 */
typedef struct
{
	Header header;	// MQTT header byte 
	int msgId;		// MQTT message id 
	List* qoss;		// list of granted QoSs 
} Suback;


/*!
 *  @abstract Data for an unsubscribe packet.
 */
typedef struct
{
	Header header;	// MQTT header byte 
	int msgId;		// MQTT message id 
	List* topics;	// list of topic strings 
	int noTopics;	// topic count 
} Unsubscribe;


/*!
 *  @abstract Data for a publish packet.
 */
typedef struct
{
	Header header;	// MQTT header byte 
	char* topic;	// topic string 
	size_t topiclen;
	int msgId;		// MQTT message id 
	char* payload;	// binary payload, length delimited 
	size_t payloadlen;	// payload length
} Publish;


/*!
 *  @abstract Data for one of the ack packets.
 */
typedef struct
{
	Header header;	// MQTT header byte 
	int msgId;		// MQTT message id 
} Ack;

typedef Ack Puback;
typedef Ack Pubrec;
typedef Ack Pubrel;
typedef Ack Pubcomp;
typedef Ack Unsuback;

#pragma mark Public API

/*!
 *  @abstract Reads one MQTT packet from a socket.
 *
 *  @param socket a socket from which to read an MQTT packet
 *  @param error pointer to the error code which is completed if no packet is returned
 *  @return the packet structure or NULL if there was an error
 */
void* MQTTPacket_Factory(networkHandles* net, int* error);

/*!
 *  @abstract Encodes the message length according to the MQTT algorithm.
 *
 *  @param buf the buffer into which the encoded data is written
 *  @param length the length to be encoded
 *  @return the number of bytes written to buffer
 */
int MQTTPacket_encode(char* buf, size_t length);

/*!
 *  @abstract Decodes the message length according to the MQTT algorithm.
 *
 *  @param socket the socket from which to read the bytes.
 *  @param value the decoded length returned.
 *  @return the number of bytes read from the socket.
 */
int MQTTPacket_decode(networkHandles* net, size_t* value);

/*!
 *  @abstract Calculates an integer from two bytes read from the input buffer
 *  @param pptr pointer to the input buffer - incremented by the number of bytes used & returned
 *  @return the integer value calculated
 */
int readInt(char** pptr);

/*!
 *  @abstract Reads a "UTF" string from the input buffer.  UTF as in the MQTT v3 spec which really means
 * a length delimited string.  So it reads the two byte length then the data according to
 * that length.  The end of the buffer is provided too, so we can prevent buffer overruns caused
 * by an incorrect length.
 *
 *  @param pptr pointer to the input buffer - incremented by the number of bytes used & returned
 *  @param enddata pointer to the end of the buffer not to be read beyond
 *  @return an allocated C string holding the characters read, or NULL if the length read would
 * have caused an overrun.
 */
char* readUTF(char** pptr, char* enddata);

/*!
 *  @abstract Reads one character from the input buffer.
 *
 *  @param pptr pointer to the input buffer - incremented by the number of bytes used & returned
 *  @return the character read
 */
unsigned char readChar(char** pptr);

/*!
 *  @abstract Writes one character to an output buffer.
 *
 *  @param pptr pointer to the output buffer - incremented by the number of bytes used & returned
 *  @param c the character to write
 */
void writeChar(char** pptr, char c);

/*!
 *  @abstract Writes an integer as 2 bytes to an output buffer.
 *
 *  @param pptr pointer to the output buffer - incremented by the number of bytes used & returned
 *  @param anInt the integer to write
 */
void writeInt(char** pptr, int anInt);

/*!
 *  @abstract Writes a "UTF" string to an output buffer.  Converts C string to length-delimited.
 *
 *  @param pptr pointer to the output buffer - incremented by the number of bytes used & returned
 *  @param string the C string to write
 */
void writeUTF(char** pptr, const char* string);

/*!
 *  @abstract Converts an MQTT packet code into its name.
 *
 *  @param ptype packet code.
 *  @return the corresponding string, or "UNKNOWN".
 */
char* MQTTPacket_name(int ptype);

/*!
 *  @abstract Sends an MQTT packet in one system call write
 *
 *  @param socket the socket to which to write the data
 *  @param header the one-byte MQTT header
 *  @param buffer the rest of the buffer to write (not including remaining length)
 *  @param buflen the length of the data in buffer to be written
 *  @return the completion code (TCPSOCKET_COMPLETE etc)
 */
int MQTTPacket_send(networkHandles* net, Header header, char* buffer, size_t buflen, int free);

/*!
 *  @abstract Sends an MQTT packet from multiple buffers in one system call write.
 *
 *  @param socket the socket to which to write the data
 *  @param header the one-byte MQTT header
 *  @param count the number of buffers
 *  @param buffers the rest of the buffers to write (not including remaining length)
 *  @param buflens the lengths of the data in the array of buffers to be written
 *  @return the completion code (TCPSOCKET_COMPLETE etc)
 */
int MQTTPacket_sends(networkHandles* net, Header header, int count, char** buffers, size_t* buflens, int* frees);

/*!
 *  @abstract Function used in the new packets table to create packets which have only a header.
 *
 *  @param aHeader the MQTT header byte
 *  @param data the rest of the packet
 *  @param datalen the length of the rest of the packet
 *  @return pointer to the packet structure
 */
void* MQTTPacket_header_only(unsigned char aHeader, char* data, size_t datalen);

/*!
 *  @abstract Send an MQTT disconnect packet down a socket.
 *
 *  @param socket the open socket to send the data to
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_disconnect(networkHandles* net, char const* clientID);

/*!
 *  @abstract Function used in the new packets table to create publish packets.
 *
 *  @param aHeader the MQTT header byte
 *  @param data the rest of the packet
 *  @param datalen the length of the rest of the packet
 *  @return pointer to the packet structure
 */
void* MQTTPacket_publish(unsigned char aHeader, char* data, size_t datalen);

/*!
 *  @abstract Free allocated storage for a publish packet.
 *
 *  @param pack pointer to the publish packet structure
 */
void MQTTPacket_freePublish(Publish* pack);

/*!
 *  @abstract Send an MQTT PUBLISH packet down a socket.
 *
 *  @param pack a structure from which to get some values to use, e.g topic, payload
 *  @param dup boolean - whether to set the MQTT DUP flag
 *  @param qos the value to use for the MQTT QoS setting
 *  @param retained boolean - whether to set the MQTT retained flag
 *  @param socket the open socket to send the data to
 *  @param clientID the string client identifier, only used for tracing
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_publish(Publish* pack, int dup, int qos, int retained, networkHandles* net, char const* clientID);

/*!
 *  @abstract Send an MQTT PUBACK packet down a socket.
 *
 *  @param msgid the MQTT message id to use
 *  @param socket the open socket to send the data to
 *  @param clientID the string client identifier, only used for tracing
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_puback(int msgid, networkHandles* net, char const* clientID);

/*!
 *  @abstract Function used in the new packets table to create acknowledgement packets.
 *
 *  @param aHeader the MQTT header byte
 *  @param data the rest of the packet
 *  @param datalen the length of the rest of the packet
 *  @return pointer to the packet structure
 */
void* MQTTPacket_ack(unsigned char aHeader, char* data, size_t datalen);

/*!
 *  @abstract Free allocated storage for a suback packet.
 *
 *  @param pack pointer to the suback packet structure
 */
void MQTTPacket_freeSuback(Suback* pack);

/*!
 *  @abstract Send an MQTT PUBREC packet down a socket.
 *
 *  @param msgid the MQTT message id to use
 *  @param socket the open socket to send the data to
 *  @param clientID the string client identifier, only used for tracing
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_pubrec(int msgid, networkHandles* net, char const* clientID);

/*!
 *  @abstract Send an MQTT PUBREL packet down a socket.
 *
 *  @param msgid the MQTT message id to use
 *  @param dup boolean - whether to set the MQTT DUP flag
 *  @param socket the open socket to send the data to
 *  @param clientID the string client identifier, only used for tracing
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_pubrel(int msgid, int dup, networkHandles* net, char const* clientID);

/*!
 *  @abstract Send an MQTT PUBCOMP packet down a socket.
 *
 *  @param msgid the MQTT message id to use
 *  @param socket the open socket to send the data to
 *  @param clientID the string client identifier, only used for tracing
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_pubcomp(int msgid, networkHandles* net, char const* clientID);

/*!
 *  @abstract Free allocated storage for a various packet tyoes.
 *
 *  @param pack pointer to the suback packet structure.
 */
void MQTTPacket_free_packet(MQTTPacket* pack);

#if !defined(NO_BRIDGE)
	#include "MQTTPacketOut.h"  // MQTT (Public)
#endif
