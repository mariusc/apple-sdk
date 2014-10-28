#include "MQTTPacket.h"         // Header
#include "Log.h"                // Utilities
#if !defined(NO_PERSISTENCE)
#include "MQTTPersistence.h"    // MQTT (Public)
#endif
#include "Messages.h"           // MQTT (Private)
#include "StackTrace.h"         // MQTT (Utilities)
#include "Heap.h"               // MQTT (Utilities)

#include <stdlib.h>             // C Standard
#include <string.h>             // C Standard

#pragma mark - Definitions

#if !defined(min)
    #define min(A,B) ( (A) < (B) ? (A):(B))
#endif

/*!
 *  @abstract List of the predefined MQTT v3 packet names.
 */
static char* packet_names[] =
{
	"RESERVED", "CONNECT", "CONNACK", "PUBLISH", "PUBACK", "PUBREC", "PUBREL",
	"PUBCOMP", "SUBSCRIBE", "SUBACK", "UNSUBSCRIBE", "UNSUBACK",
	"PINGREQ", "PINGRESP", "DISCONNECT"
};

char** MQTTClient_packet_names = packet_names;

/*!
 *  @abstract Array of functions to build packets, indexed according to packet code
 */
pf new_packets[] = {
	NULL,               // reserved
	NULL,               // MQTTPacket_connect*/
	MQTTPacket_connack, // CONNACK
	MQTTPacket_publish,	// PUBLISH
	MQTTPacket_ack,     // PUBACK
	MQTTPacket_ack,     // PUBREC
	MQTTPacket_ack,     // PUBREL
	MQTTPacket_ack,     // PUBCOMP
	NULL,               // MQTTPacket_subscribe*/
	MQTTPacket_suback,  // SUBACK
	NULL,               // MQTTPacket_unsubscribe
	MQTTPacket_ack,     // UNSUBACK
	MQTTPacket_header_only, // PINGREQ
	MQTTPacket_header_only, // PINGRESP
	MQTTPacket_header_only  // DISCONNECT
};

#pragma mark - Private prototypes

char* readUTFlen(char** pptr, char* enddata, size_t* len);
int MQTTPacket_send_ack(int type, int msgid, int dup, networkHandles *net);

#pragma mark - Public API

void* MQTTPacket_Factory(networkHandles* net, int* error)
{
	static Header header;
	int ptype;
	void* pack = NULL;

	FUNC_ENTRY;
	*error = SOCKET_ERROR;  // Indicate whether an error occurred, or not

	/* read the packet data from the socket */
    #if defined(OPENSSL)
	*error = (net->ssl) ? SSLSocket_getch(net->ssl, net->socket, &header.byte) : Socket_getch(net->socket, &header.byte); 
    #else
	*error = Socket_getch(net->socket, &header.byte);
    #endif
    
	if (*error != TCPSOCKET_COMPLETE)
    {   // First byte is the header byte
        goto exit;  // packet not read, *error indicates whether SOCKET_ERROR occurred.
    }

	// Now read the remaining length, so we know how much more to read
    size_t remaining_length;
    
    if ((*error = MQTTPacket_decode(net, &remaining_length)) != TCPSOCKET_COMPLETE) {
        goto exit; // Packet not read, *error indicates whether SOCKET_ERROR occurred.
    }

	// Now read the rest, the variable header and payload.
    size_t actual_len = 0;
    
    #if defined(OPENSSL)
	char* data = (net->ssl) ? SSLSocket_getdata(net->ssl, net->socket, remaining_length, &actual_len) :  Socket_getdata(net->socket, remaining_length, &actual_len);
    #else
	char* data = Socket_getdata(net->socket, remaining_length, &actual_len);
    #endif
    
	if (data == NULL)
	{
		*error = SOCKET_ERROR;
		goto exit; // Socket error
	}

	if (actual_len != remaining_length)
    {
		*error = TCPSOCKET_INTERRUPTED;
    }
	else
	{
		ptype = header.bits.type;
		if (ptype < CONNECT || ptype > DISCONNECT || new_packets[ptype] == NULL)
			Log(TRACE_MIN, 2, NULL, ptype);
		else
		{
			if ((pack = (*new_packets[ptype])(header.byte, data, remaining_length)) == NULL)
				*error = BAD_MQTT_PACKET;
            #if !defined(NO_PERSISTENCE)
			else if (header.bits.type == PUBLISH && header.bits.qos == 2)
			{
				int buf0len;
				char *buf = malloc(10);
				buf[0] = header.byte;
				buf0len = 1 + MQTTPacket_encode(&buf[1], remaining_length);
				size_t remaining_length_new = remaining_length;
				*error = MQTTPersistence_put(net->socket, buf, buf0len, 1, &data, &remaining_length_new, header.bits.type, ((Publish *)pack)->msgId, 1);
				free(buf);
			}
            #endif
		}
	}
	if (pack)
		time(&(net->lastReceived));
exit:
	FUNC_EXIT_RC(*error);
	return pack;
}

int MQTTPacket_encode(char* buf, size_t length)
{
    int rc = 0;
    
    FUNC_ENTRY;
    do
    {
        char d = length % 128;
        length /= 128;
        /* if there are more digits to encode, set the top bit of this digit */
        if (length > 0) { d |= 0x80; }
        buf[rc++] = d;
    } while (length > 0);
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTPacket_decode(networkHandles* net, size_t* value)
{
    int rc = SOCKET_ERROR;
    char c;
    int multiplier = 1;
    int len = 0;
    #define MAX_NO_OF_REMAINING_LENGTH_BYTES 4
    
    FUNC_ENTRY;
    *value = 0;
    do
    {
        if (++len > MAX_NO_OF_REMAINING_LENGTH_BYTES)
        {
            rc = SOCKET_ERROR;	/* bad data */
            goto exit;
        }
        #if defined(OPENSSL)
        rc = (net->ssl) ? SSLSocket_getch(net->ssl, net->socket, &c) : Socket_getch(net->socket, &c);
        #else
        rc = Socket_getch(net->socket, &c);
        #endif
        if (rc != TCPSOCKET_COMPLETE) { goto exit; }
        *value += (c & 127) * multiplier;
        multiplier *= 128;
    } while ((c & 128) != 0);

exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int readInt(char** pptr)
{
    char* ptr = *pptr;
    int len = 256*((unsigned char)(*ptr)) + (unsigned char)(*(ptr+1));
    *pptr += 2;
    return len;
}

char* readUTF(char** pptr, char* enddata)
{
    size_t len;
    return readUTFlen(pptr, enddata, &len);
}

unsigned char readChar(char** pptr)
{
    unsigned char c = **pptr;
    (*pptr)++;
    return c;
}

void writeChar(char** pptr, char c)
{
    **pptr = c;
    (*pptr)++;
}

void writeInt(char** pptr, int anInt)
{
    **pptr = (char)(anInt / 256);
    (*pptr)++;
    **pptr = (char)(anInt % 256);
    (*pptr)++;
}

void writeUTF(char** pptr, const char* string)
{
    size_t len = strlen(string);
    writeInt(pptr, (int)len);
    memcpy(*pptr, string, len);
    *pptr += len;
}

char* MQTTPacket_name(int ptype)
{
    return (ptype >= 0 && ptype <= DISCONNECT) ? packet_names[ptype] : "UNKNOWN";
}

int MQTTPacket_send(networkHandles* net, Header header, char* buffer, size_t buflen, int free)
{
	int rc;

	FUNC_ENTRY;
	char* buf = malloc(10);
	buf[0] = header.byte;
	size_t buf0len = 1 + MQTTPacket_encode(&buf[1], buflen);
    #if !defined(NO_PERSISTENCE)
	if (header.bits.type == PUBREL)
	{
		char* ptraux = buffer;
		int msgId = readInt(&ptraux);
		rc = MQTTPersistence_put(net->socket, buf, buf0len, 1, &buffer, &buflen,
			header.bits.type, msgId, 0);
	}
    #endif

    #if defined(OPENSSL)
    if (net->ssl) {
		rc = SSLSocket_putdatas(net->ssl, net->socket, buf, buf0len, 1, &buffer, &buflen, &free);
    } else
    #endif
		rc = Socket_putdatas(net->socket, buf, buf0len, 1, &buffer, &buflen, &free);
		
    if (rc == TCPSOCKET_COMPLETE) { time(&(net->lastSent)); }
    if (rc != TCPSOCKET_INTERRUPTED) { free(buf); }

	FUNC_EXIT_RC(rc);
	return rc;
}

int MQTTPacket_sends(networkHandles* net, Header header, int count, char** buffers, size_t* buflens, int* frees)
{
	int i, rc, buf0len, total = 0;
	char *buf;

	FUNC_ENTRY;
	buf = malloc(10);
	buf[0] = header.byte;
	for (i = 0; i < count; i++)
		total += buflens[i];
	buf0len = 1 + MQTTPacket_encode(&buf[1], total);
    #if !defined(NO_PERSISTENCE)
	if (header.bits.type == PUBLISH && header.bits.qos != 0)
	{   // Persist PUBLISH QoS1 and Qo2
		char *ptraux = buffers[2];
		int msgId = readInt(&ptraux);
		rc = MQTTPersistence_put(net->socket, buf, buf0len, count, buffers, buflens,
			header.bits.type, msgId, 0);
	}
    #endif
    #if defined(OPENSSL)
	if (net->ssl)
		rc = SSLSocket_putdatas(net->ssl, net->socket, buf, buf0len, count, buffers, buflens, frees);
	else
    #endif
		rc = Socket_putdatas(net->socket, buf, buf0len, count, buffers, buflens, frees);
		
	if (rc == TCPSOCKET_COMPLETE)
		time(&(net->lastSent));
	
	if (rc != TCPSOCKET_INTERRUPTED)
	  free(buf);
	FUNC_EXIT_RC(rc);
	return rc;
}

void* MQTTPacket_header_only(unsigned char aHeader, char* data, size_t datalen)
{
    static unsigned char header = 0;
    header = aHeader;
    return &header;
}

int MQTTPacket_send_disconnect(networkHandles *net, const char* clientID)
{
    Header header;
    int rc = 0;
    
    FUNC_ENTRY;
    header.byte = 0;
    header.bits.type = DISCONNECT;
    rc = MQTTPacket_send(net, header, NULL, 0, 0);
    Log(LOG_PROTOCOL, 28, NULL, net->socket, clientID, rc);
    FUNC_EXIT_RC(rc);
    return rc;
}

void* MQTTPacket_publish(unsigned char aHeader, char* data, size_t datalen)
{
    Publish* pack = malloc(sizeof(Publish));
    char* curdata = data;
    char* enddata = &data[datalen];
    
    FUNC_ENTRY;
    pack->header.byte = aHeader;
    if ((pack->topic = readUTFlen(&curdata, enddata, &pack->topiclen)) == NULL) // Topic name on which to publish.
    {
        free(pack);
        pack = NULL;
        goto exit;
    }
    if (pack->header.bits.qos > 0)  // Msgid only exists for QoS 1 or 2
        pack->msgId = readInt(&curdata);
    else
        pack->msgId = 0;
    pack->payload = curdata;
    pack->payloadlen = datalen-(curdata-data);
    
exit:
    FUNC_EXIT;
    return pack;
}

void MQTTPacket_freePublish(Publish* pack)
{
    FUNC_ENTRY;
    if (pack->topic != NULL)
        free(pack->topic);
    free(pack);
    FUNC_EXIT;
}


int MQTTPacket_send_publish(Publish* pack, int dup, int qos, int retained, networkHandles* net, char const* clientID)
{
    Header header;
    char *topiclen;
    int rc = -1;
    
    FUNC_ENTRY;
    topiclen = malloc(2);
    
    header.bits.type = PUBLISH;
    header.bits.dup = dup;
    header.bits.qos = qos;
    header.bits.retain = retained;
    if (qos > 0)
    {
        char *buf = malloc(2);
        char *ptr = buf;
        char* bufs[4] = {topiclen, pack->topic, buf, pack->payload};
        size_t lens[4] = {2, strlen(pack->topic), 2, pack->payloadlen};
        int frees[4] = {1, 0, 1, 0};
        
        writeInt(&ptr, pack->msgId);
        ptr = topiclen;
        writeInt(&ptr, (int)(lens[1]));
        rc = MQTTPacket_sends(net, header, 4, bufs, lens, frees);
        if (rc != TCPSOCKET_INTERRUPTED)
            free(buf);
    }
    else
    {
        char* ptr = topiclen;
        char* bufs[3] = {topiclen, pack->topic, pack->payload};
        size_t lens[3] = {2, strlen(pack->topic), pack->payloadlen};
        int frees[3] = {1, 0, 0};
        
        writeInt(&ptr, (int)(lens[1]));
        rc = MQTTPacket_sends(net, header, 3, bufs, lens, frees);
    }
    if (rc != TCPSOCKET_INTERRUPTED)
        free(topiclen);
    if (qos == 0)
        Log(LOG_PROTOCOL, 27, NULL, net->socket, clientID, retained, rc);
    else
        Log(LOG_PROTOCOL, 10, NULL, net->socket, clientID, pack->msgId, qos, retained, rc,
            min(20, pack->payloadlen), pack->payload);
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTPacket_send_puback(int msgid, networkHandles* net, const char* clientID)
{
    int rc = 0;
    
    FUNC_ENTRY;
    rc =  MQTTPacket_send_ack(PUBACK, msgid, 0, net);
    Log(LOG_PROTOCOL, 12, NULL, net->socket, clientID, msgid, rc);
    FUNC_EXIT_RC(rc);
    return rc;
}

void* MQTTPacket_ack(unsigned char aHeader, char* data, size_t datalen)
{
    Ack* pack = malloc(sizeof(Ack));
    char* curdata = data;
    
    FUNC_ENTRY;
    pack->header.byte = aHeader;
    pack->msgId = readInt(&curdata);
    FUNC_EXIT;
    return pack;
}

void MQTTPacket_freeSuback(Suback* pack)
{
    FUNC_ENTRY;
    if (pack->qoss != NULL)
        ListFree(pack->qoss);
    free(pack);
    FUNC_EXIT;
}

int MQTTPacket_send_pubrec(int msgid, networkHandles* net, const char* clientID)
{
    int rc = 0;
    
    FUNC_ENTRY;
    rc =  MQTTPacket_send_ack(PUBREC, msgid, 0, net);
    Log(LOG_PROTOCOL, 13, NULL, net->socket, clientID, msgid, rc);
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTPacket_send_pubrel(int msgid, int dup, networkHandles* net, const char* clientID)
{
    int rc = 0;
    
    FUNC_ENTRY;
    rc = MQTTPacket_send_ack(PUBREL, msgid, dup, net);
    Log(LOG_PROTOCOL, 16, NULL, net->socket, clientID, msgid, rc);
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTPacket_send_pubcomp(int msgid, networkHandles* net, const char* clientID)
{
    int rc = 0;
    
    FUNC_ENTRY;
    rc = MQTTPacket_send_ack(PUBCOMP, msgid, 0, net);
    Log(LOG_PROTOCOL, 18, NULL, net->socket, clientID, msgid, rc);
    FUNC_EXIT_RC(rc);
    return rc;
}

void MQTTPacket_free_packet(MQTTPacket* pack)
{
    FUNC_ENTRY;
    if (pack->header.bits.type == PUBLISH)
        MQTTPacket_freePublish((Publish*)pack);
    /*else if (pack->header.type == SUBSCRIBE)
     MQTTPacket_freeSubscribe((Subscribe*)pack, 1);
     else if (pack->header.type == UNSUBSCRIBE)
     MQTTPacket_freeUnsubscribe((Unsubscribe*)pack);*/
    else
        free(pack);
    FUNC_EXIT;
}

#pragma mark - Private functionality

/*!
 *  @abstract Reads a "UTF" string from the input buffer.  UTF as in the MQTT v3 spec which really means
 * a length delimited string.  So it reads the two byte length then the data according to
 * that length.  The end of the buffer is provided too, so we can prevent buffer overruns caused
 * by an incorrect length.
 *
 *  @param pptr pointer to the input buffer - incremented by the number of bytes used & returned
 *  @param enddata pointer to the end of the buffer not to be read beyond
 *  @param len returns the calculcated value of the length bytes read
 *  @return an allocated C string holding the characters read, or NULL if the length read would
 * have caused an overrun.
 *
 */
char* readUTFlen(char** pptr, char* enddata, size_t* len)
{
	char* string = NULL;

	FUNC_ENTRY;
	if (enddata - (*pptr) > 1) /* enough length to read the integer? */
	{
		*len = readInt(pptr);
		if (&(*pptr)[*len] <= enddata)
		{
			string = malloc(*len+1);
			memcpy(string, *pptr, *len);
			string[*len] = '\0';
			*pptr += *len;
		}
	}
	FUNC_EXIT;
	return string;
}

/*!
 *  @abstract Send an MQTT acknowledgement packet down a socket.
 *
 *  @param type the MQTT packet type e.g. SUBACK
 *  @param msgid the MQTT message id to use
 *  @param dup boolean - whether to set the MQTT DUP flag
 *  @param net the network handle to send the data to
 *  @return the completion code (e.g. TCPSOCKET_COMPLETE)
 */
int MQTTPacket_send_ack(int type, int msgid, int dup, networkHandles *net)
{
	Header header;
	int rc;
	char *buf = malloc(2);
	char *ptr = buf;

	FUNC_ENTRY;
	header.byte = 0;
	header.bits.type = type;
	header.bits.dup = dup;
	if (type == PUBREL)
	    header.bits.qos = 1;
	writeInt(&ptr, msgid);
	if ((rc = MQTTPacket_send(net, header, buf, 2, 1)) != TCPSOCKET_INTERRUPTED)
		free(buf);
	FUNC_EXIT_RC(rc);
	return rc;
}
