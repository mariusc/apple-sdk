#include "MQTTProtocolOut.h"    // Header
#include <stdlib.h>             // C Standard
#include "StackTrace.h"         // MQTT (Utilities)
#include "Heap.h"               // MQTT (Utilities)

#pragma mark - Variables

extern MQTTProtocol state;
extern ClientStates* bstate;

#pragma mark - Private prototypes

char* MQTTProtocol_addressPort(const char* uri, int* port);

#pragma mark - Public API

#if defined(OPENSSL)
int MQTTProtocol_connect(const char* ip_address, Clients* aClient, int ssl, int MQTTVersion)
#else
int MQTTProtocol_connect(const char* ip_address, Clients* aClient, int MQTTVersion)
#endif
{
    int rc, port;
    char* addr;
    
    FUNC_ENTRY;
    aClient->good = 1;
    
    addr = MQTTProtocol_addressPort(ip_address, &port);
    rc = Socket_new(addr, port, &(aClient->net.socket));
    if (rc == EINPROGRESS || rc == EWOULDBLOCK)
        aClient->connect_state = 1; /* TCP connect called - wait for connect completion */
    else if (rc == 0)
    {	/* TCP connect completed. If SSL, send SSL connect */
        #if defined(OPENSSL)
        if (ssl)
        {
            if (SSLSocket_setSocketForSSL(&aClient->net, aClient->sslopts) != 1)
            {
                rc = SSLSocket_connect(aClient->net.ssl, aClient->net.socket);
                if (rc == -1)
                    aClient->connect_state = 2; /* SSL connect called - wait for completion */
            }
            else
                rc = SOCKET_ERROR;
        }
        #endif
        
        if (rc == 0)
        {
            /* Now send the MQTT connect packet */
            if ((rc = MQTTPacket_send_connect(aClient, MQTTVersion)) == 0)
                aClient->connect_state = 3; /* MQTT Connect sent - wait for CONNACK */
            else
                aClient->connect_state = 0;
        }
    }
    if (addr != ip_address)
        free(addr);
    
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTProtocol_handlePingresps(void* pack, int sock)
{
    Clients* client = NULL;
    int rc = TCPSOCKET_COMPLETE;
    
    FUNC_ENTRY;
    client = (Clients*)(ListFindItem(bstate->clients, &sock, clientSocketCompare)->content);
    Log(LOG_PROTOCOL, 21, NULL, sock, client->clientID);
    client->ping_outstanding = 0;
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTProtocol_subscribe(Clients* client, List* topics, List* qoss, int msgID)
{
    int rc = 0;
    
    FUNC_ENTRY;
    /* we should stack this up for retry processing too */
    rc = MQTTPacket_send_subscribe(topics, qoss, msgID, 0, &client->net, client->clientID);
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTProtocol_handleSubacks(void* pack, int sock)
{
    Suback* suback = (Suback*)pack;
    Clients* client = NULL;
    int rc = TCPSOCKET_COMPLETE;
    
    FUNC_ENTRY;
    client = (Clients*)(ListFindItem(bstate->clients, &sock, clientSocketCompare)->content);
    Log(LOG_PROTOCOL, 23, NULL, sock, client->clientID, suback->msgId);
    MQTTPacket_freeSuback(suback);
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTProtocol_unsubscribe(Clients* client, List* topics, int msgID)
{
    int rc = 0;
    
    FUNC_ENTRY;
    /* we should stack this up for retry processing too? */
    rc = MQTTPacket_send_unsubscribe(topics, msgID, 0, &client->net, client->clientID);
    FUNC_EXIT_RC(rc);
    return rc;
}

int MQTTProtocol_handleUnsubacks(void* pack, int sock)
{
    Unsuback* unsuback = (Unsuback*)pack;
    Clients* client = NULL;
    int rc = TCPSOCKET_COMPLETE;
    
    FUNC_ENTRY;
    client = (Clients*)(ListFindItem(bstate->clients, &sock, clientSocketCompare)->content);
    Log(LOG_PROTOCOL, 24, NULL, sock, client->clientID, unsuback->msgId);
    free(unsuback);
    FUNC_EXIT_RC(rc);
    return rc;
}

#pragma mark - Private functionality

/*!
 *  @abstract Separates an address:port into two separate values.
 *  @param uri The input string - hostname:port.
 *  @param port The returned port integer.
 *  @return The address string.
 */
char* MQTTProtocol_addressPort(char const* uri, int* port)
{
	char const* colon_pos = strrchr(uri, ':'); /* reverse find to allow for ':' in IPv6 addresses */
	char* buf = (char*)uri;

	FUNC_ENTRY;
	if (uri[0] == '[')
	{
        // Means it was an IPv6 separator, not for host:port
        if (colon_pos < strrchr(uri, ']')) { colon_pos = NULL; }
	}

	if (colon_pos)
	{
		size_t const addr_len = colon_pos - uri;
		buf = malloc(addr_len + 1);
		*port = atoi(colon_pos + 1);
		MQTTStrncpy(buf, uri, addr_len+1);
	}
    else { *port = DEFAULT_PORT; }

	size_t len = strlen(buf);
    if (buf[len - 1] == ']') { buf[len - 1] = '\0'; }

	FUNC_EXIT;
	return buf;
}
