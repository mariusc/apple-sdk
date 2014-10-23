#include "Socket.h"         // Header
#include "Log.h"            // MQTT (Utilities)
#include "SocketBuffer.h"   // MQTT (Web)
#include "Messages.h"       // MQTT (Private)
#include "StackTrace.h"     // MQTT (Utilities)
#if defined(OPENSSL)
#include "SSLSocket.h"      // OpenSSL
#endif

#include <stdlib.h>         // C Standard
#include <string.h>         // C Standard
#include <signal.h>         // C Standard
#include <ctype.h>          // C Standard

#include "Heap.h"           // MQTT (Utilities)

#pragma mark - Private prototypes

int Socket_addSocket(int newSd);
int Socket_setnonblocking(int sock);
int isReady(int socket, fd_set* read_set, fd_set* write_set);
int Socket_error(char* aString, int sock);
char* Socket_getaddrname(struct sockaddr* sa, int sock);
int Socket_writev(int socket, iobuf* iovecs, int count, size_t* bytes);
int Socket_continueWrites(fd_set* pwset);
int Socket_continueWrite(int socket);
int Socket_close_only(int socket);

#pragma mark - Variables

Sockets s;          // Structure to hold all socket data for the module
static fd_set wset; //
static Socket_writeComplete* writecomplete = NULL;  // 

#pragma mark - Public API

void Socket_outInitialize()
{
    FUNC_ENTRY;
    signal(SIGPIPE, SIG_IGN);       // For historical reasons; programs expect signal's return value to be defined by <sys/signal.h>.
    
    SocketBuffer_initialize();
    s.clientsds = ListInitialize();
    s.connect_pending = ListInitialize();
    s.write_pending = ListInitialize();
    s.cur_clientsds = NULL;
    FD_ZERO(&(s.rset));            // Initialize the descriptor set
    FD_ZERO(&(s.pending_wset));
    s.maxfdp1 = 0;
    memcpy((void*)&(s.rset_saved), (void*)&(s.rset), sizeof(s.rset_saved));
    FUNC_EXIT;
}

void Socket_outTerminate()
{
    FUNC_ENTRY;
    ListFree(s.connect_pending);
    ListFree(s.write_pending);
    ListFree(s.clientsds);
    SocketBuffer_terminate();
    FUNC_EXIT;
}

int Socket_getReadySocket(int more_work, struct timeval *tp)
{
    int rc = 0;
    static struct timeval zero = {0L, 0L}; /* 0 seconds */
    static struct timeval one = {1L, 0L}; /* 1 second */
    struct timeval timeout = one;
    
    FUNC_ENTRY;
    if (s.clientsds->count == 0)
        goto exit;
    
    if (more_work)
        timeout = zero;
    else if (tp)
        timeout = *tp;
    
    while (s.cur_clientsds != NULL)
    {
        if (isReady(*((int*)(s.cur_clientsds->content)), &(s.rset), &wset))
            break;
        ListNextElement(s.clientsds, &s.cur_clientsds);
    }
    
    if (s.cur_clientsds == NULL)
    {
        int rc1;
        fd_set pwset;
        
        memcpy((void*)&(s.rset), (void*)&(s.rset_saved), sizeof(s.rset));
        memcpy((void*)&(pwset), (void*)&(s.pending_wset), sizeof(pwset));
        if ((rc = select(s.maxfdp1, &(s.rset), &pwset, NULL, &timeout)) == SOCKET_ERROR)
        {
            Socket_error("read select", 0);
            goto exit;
        }
        Log(TRACE_MAX, -1, "Return code %d from read select", rc);
        
        if (Socket_continueWrites(&pwset) == SOCKET_ERROR)
        {
            rc = 0;
            goto exit;
        }
        
        memcpy((void*)&wset, (void*)&(s.rset_saved), sizeof(wset));
        if ((rc1 = select(s.maxfdp1, NULL, &(wset), NULL, &zero)) == SOCKET_ERROR)
        {
            Socket_error("write select", 0);
            rc = rc1;
            goto exit;
        }
        Log(TRACE_MAX, -1, "Return code %d from write select", rc1);
        
        if (rc == 0 && rc1 == 0)
            goto exit; /* no work to do */
        
        s.cur_clientsds = s.clientsds->first;
        while (s.cur_clientsds != NULL)
        {
            int cursock = *((int*)(s.cur_clientsds->content));
            if (isReady(cursock, &(s.rset), &wset))
                break;
            ListNextElement(s.clientsds, &s.cur_clientsds);
        }
    }
    
    if (s.cur_clientsds == NULL)
        rc = 0;
    else
    {
        rc = *((int*)(s.cur_clientsds->content));
        ListNextElement(s.clientsds, &s.cur_clientsds);
    }
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int Socket_getch(int socket, char* c)
{
    int rc = SOCKET_ERROR;
    
    FUNC_ENTRY;
    if ((rc = SocketBuffer_getQueuedChar(socket, c)) != SOCKETBUFFER_INTERRUPTED)
        goto exit;
    
    if ((rc = (int)recv(socket, c, (size_t)1, 0)) == SOCKET_ERROR)
    {
        int err = Socket_error("recv - getch", socket);
        if (err == EWOULDBLOCK || err == EAGAIN)
        {
            rc = TCPSOCKET_INTERRUPTED;
            SocketBuffer_interrupted(socket, 0);
        }
    }
    else if (rc == 0)
        rc = SOCKET_ERROR; 	// The return value from recv is 0 when the peer has performed an orderly shutdown.
    else if (rc == 1)
    {
        SocketBuffer_queueChar(socket, *c);
        rc = TCPSOCKET_COMPLETE;
    }
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

char* Socket_getdata(int socket, size_t bytes, size_t* actual_len)
{
    int rc;
    
    FUNC_ENTRY;
    char* buf;
    
    if (bytes == 0)
    {
        buf = SocketBuffer_complete(socket);
        goto exit;
    }
    
    buf = SocketBuffer_getQueuedData(socket, bytes, actual_len);
    
    if ((rc = (int)recv(socket, buf + (*actual_len), (size_t)(bytes - (*actual_len)), 0)) == SOCKET_ERROR)
    {
        rc = Socket_error("recv - getdata", socket);
        if (rc != EAGAIN && rc != EWOULDBLOCK)
        {
            buf = NULL;
            goto exit;
        }
    }
    else if (rc == 0) /* rc 0 means the other end closed the socket, albeit "gracefully" */
    {
        buf = NULL;
        goto exit;
    }
    else
        *actual_len += rc;
    
    if (*actual_len == bytes)
    {
        SocketBuffer_complete(socket);
    }
    else /* we didn't read the whole packet */
    {
        SocketBuffer_interrupted(socket, *actual_len);
        Log(TRACE_MAX, -1, "%d bytes expected but %d bytes now received", bytes, *actual_len);
    }
exit:
    FUNC_EXIT;
    return buf;
}

int Socket_putdatas(int socket, char* buf0, size_t buf0len, int count, char** buffers, size_t* buflens, int* frees)
{
    size_t bytes = 0L;
    size_t total = buf0len;
    
    iobuf iovecs[5];
    int frees1[5];
    int rc = TCPSOCKET_INTERRUPTED;
    
    FUNC_ENTRY;
    if (!Socket_noPendingWrites(socket))
    {
        Log(LOG_SEVERE, -1, "Trying to write to socket %d for which there is already pending output", socket);
        rc = SOCKET_ERROR;
        goto exit;
    }
    
    for (int i = 0; i < count; i++) { total += buflens[i]; }
    
    iovecs[0].iov_base = buf0;
    iovecs[0].iov_len = buf0len;
    frees1[0] = 1;
    for (int i = 0; i < count; i++)
    {
        iovecs[i+1].iov_base = buffers[i];
        iovecs[i+1].iov_len = buflens[i];
        frees1[i+1] = frees[i];
    }
    
    if ((rc = Socket_writev(socket, iovecs, count+1, &bytes)) != SOCKET_ERROR)
    {
        if (bytes == total)
            rc = TCPSOCKET_COMPLETE;
        else
        {
            int* sockmem = (int*)malloc(sizeof(int));
            Log(TRACE_MIN, -1, "Partial write: %ld bytes of %d actually written on socket %d",
                bytes, total, socket);
            #if defined(OPENSSL)
            SocketBuffer_pendingWrite(socket, NULL, count+1, iovecs, frees1, total, bytes);
            #else
            SocketBuffer_pendingWrite(socket, count+1, iovecs, frees1, total, bytes);
            #endif
            *sockmem = socket;
            ListAppend(s.write_pending, sockmem, sizeof(int));
            FD_SET(socket, &(s.pending_wset));
            rc = TCPSOCKET_INTERRUPTED;
        }
    }
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

void Socket_close(int socket)
{
    FUNC_ENTRY;
    Socket_close_only(socket);
    FD_CLR(socket, &(s.rset_saved));
    if (FD_ISSET(socket, &(s.pending_wset))) { FD_CLR(socket, &(s.pending_wset)); }
    if (s.cur_clientsds != NULL && *(int*)(s.cur_clientsds->content) == socket) { s.cur_clientsds = s.cur_clientsds->next; }
    ListRemoveItem(s.connect_pending, &socket, intcompare);
    ListRemoveItem(s.write_pending, &socket, intcompare);
    SocketBuffer_cleanup(socket);
    
    if (ListRemoveItem(s.clientsds, &socket, intcompare)) {
        Log(TRACE_MIN, -1, "Removed socket %d", socket);
    } else {
        Log(LOG_ERROR, -1, "Failed to remove socket %d", socket);
    }
    
    if (socket + 1 >= s.maxfdp1)
    {
        /* now we have to reset s.maxfdp1 */
        ListElement* cur_clientsds = NULL;
        
        s.maxfdp1 = 0;
        while (ListNextElement(s.clientsds, &cur_clientsds))
            s.maxfdp1 = max(*((int*)(cur_clientsds->content)), s.maxfdp1);
        ++(s.maxfdp1);
        Log(TRACE_MAX, -1, "Reset max fdp1 to %d", s.maxfdp1);
    }
    FUNC_EXIT;
}

int Socket_new(char* addr, int port, int* sock)
{
    int type = SOCK_STREAM;
    struct sockaddr_in address;
    #if defined(AF_INET6)
    struct sockaddr_in6 address6;
    #endif
    int rc = SOCKET_ERROR;
    sa_family_t family = AF_INET;
    struct addrinfo *result = NULL;
    struct addrinfo hints = {0, AF_UNSPEC, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL, NULL};
    
    FUNC_ENTRY;
    *sock = -1;
    
    if (addr[0] == '[') { ++addr; }
    
    if ((rc = getaddrinfo(addr, NULL, &hints, &result)) == 0)
    {
        struct addrinfo* res = result;
        
        /* prefer ip4 addresses */
        while (res)
        {
            if (res->ai_family == AF_INET)
            {
                result = res;
                break;
            }
            res = res->ai_next;
        }
        
        if (result == NULL)
            rc = -1;
        else
            #if defined(AF_INET6)
            if (result->ai_family == AF_INET6)
            {
                address6.sin6_port = htons(port);
                address6.sin6_family = family = AF_INET6;
                address6.sin6_addr = ((struct sockaddr_in6*)(result->ai_addr))->sin6_addr;
            }
            else
            #endif
                if (result->ai_family == AF_INET)
                {
                    address.sin_port = htons(port);
                    address.sin_family = family = AF_INET;
                    address.sin_addr = ((struct sockaddr_in*)(result->ai_addr))->sin_addr;
                }
                else
                    rc = -1;
        
        freeaddrinfo(result);
    }
    else
        Log(LOG_ERROR, -1, "getaddrinfo failed for addr %s with rc %d", addr, rc);
    
    if (rc != 0)
        Log(LOG_ERROR, -1, "%s is not a valid IP address", addr);
    else
    {
        *sock =	socket(family, type, 0);
        if (*sock == INVALID_SOCKET)
            rc = Socket_error("socket", *sock);
        else
        {
            #if defined(NOSIGPIPE)
            int opt = 1;
            
            if (setsockopt(*sock, SOL_SOCKET, SO_NOSIGPIPE, (void*)&opt, sizeof(opt)) != 0)
                Log(LOG_ERROR, -1, "Could not set SO_NOSIGPIPE for socket %d", *sock);
            #endif
            
            Log(TRACE_MIN, -1, "New socket %d for %s, port %d",	*sock, addr, port);
            if (Socket_addSocket(*sock) == SOCKET_ERROR)
                rc = Socket_error("setnonblocking", *sock);
            else
            {
                /* this could complete immmediately, even though we are non-blocking */
                if (family == AF_INET)
                    rc = connect(*sock, (struct sockaddr*)&address, sizeof(address));
                #if defined(AF_INET6)
                else
                    rc = connect(*sock, (struct sockaddr*)&address6, sizeof(address6));
                #endif
                if (rc == SOCKET_ERROR)
                    rc = Socket_error("connect", *sock);
                if (rc == EINPROGRESS || rc == EWOULDBLOCK)
                {
                    int* pnewSd = (int*)malloc(sizeof(int));
                    *pnewSd = *sock;
                    ListAppend(s.connect_pending, pnewSd, sizeof(int));
                    Log(TRACE_MIN, 15, "Connect pending");
                }
            }
        }
    }
    FUNC_EXIT_RC(rc);
    return rc;
}

int Socket_noPendingWrites(int socket)
{
    int cursock = socket;
    return ListFindItem(s.write_pending, &cursock, intcompare) == NULL;
}

char* Socket_getpeer(int sock)
{
    struct sockaddr_in6 sa;
    socklen_t sal = sizeof(sa);
    int rc;
    
    if ((rc = getpeername(sock, (struct sockaddr*)&sa, &sal)) == SOCKET_ERROR)
    {
        Socket_error("getpeername", sock);
        return "unknown";
    }
    
    return Socket_getaddrname((struct sockaddr*)&sa, sock);
}

void Socket_addPendingWrite(int socket)
{
    FD_SET(socket, &(s.pending_wset));
}

void Socket_clearPendingWrite(int socket)
{
    if (FD_ISSET(socket, &(s.pending_wset)))
        FD_CLR(socket, &(s.pending_wset));
}

void Socket_setWriteCompleteCallback(Socket_writeComplete* mywritecomplete)
{
    writecomplete = mywritecomplete;
}

#pragma mark - Private functionality

/*!
 *  @abstract Add a socket to the list of socket to check with select
 *
 *  @param newSd the new socket to add
 */
int Socket_addSocket(int newSd)
{
    int rc = 0;
    
    FUNC_ENTRY;
    if (ListFindItem(s.clientsds, &newSd, intcompare) == NULL) /* make sure we don't add the same socket twice */
    {
        int* pnewSd = (int*)malloc(sizeof(newSd));
        *pnewSd = newSd;
        ListAppend(s.clientsds, pnewSd, sizeof(newSd));
        FD_SET(newSd, &(s.rset_saved));
        s.maxfdp1 = max(s.maxfdp1, newSd + 1);
        rc = Socket_setnonblocking(newSd);
    }
    else
        Log(LOG_ERROR, -1, "addSocket: socket %d already in the list", newSd);
    
    FUNC_EXIT_RC(rc);
    return rc;
}

/*!
 *  @abstract Set a socket non-blocking, OS independently
 *
 *  @param sock the socket to set non-blocking
 *  @return TCP call error code
 */
int Socket_setnonblocking(int sock)
{
	int rc;
	int flags;

	FUNC_ENTRY;
	if ((flags = fcntl(sock, F_GETFL, 0)))
		flags = 0;
	rc = fcntl(sock, F_SETFL, flags | O_NONBLOCK);

	FUNC_EXIT_RC(rc);
	return rc;
}

/*!
 *  @abstract Don't accept work from a client unless it is accepting work back, i.e. its socket is writeable this seems like a reasonable form of flow control, and practically, seems to work.
 *
 *  @param socket the socket to check
 *  @param read_set the socket read set (see select doc)
 *  @param write_set the socket write set (see select doc)
 *  @return boolean - is the socket ready to go?
 */
int isReady(int socket, fd_set* read_set, fd_set* write_set)
{
    int rc = 1;
    
    FUNC_ENTRY;
    if  (ListFindItem(s.connect_pending, &socket, intcompare) && FD_ISSET(socket, write_set))
        ListRemoveItem(s.connect_pending, &socket, intcompare);
    else
        rc = FD_ISSET(socket, read_set) && FD_ISSET(socket, write_set) && Socket_noPendingWrites(socket);
    FUNC_EXIT_RC(rc);
    return rc;
}

/*!
 *  @abstract Gets the specific error corresponding to SOCKET_ERROR
 *
 *  @param aString the function that was being used when the error occurred
 *  @param sock the socket on which the error occurred
 *  @return the specific TCP error code
 */
int Socket_error(char* aString, int sock)
{

	FUNC_ENTRY;
	if (errno != EINTR && errno != EAGAIN && errno != EINPROGRESS && errno != EWOULDBLOCK)
	{
		if (strcmp(aString, "shutdown") != 0 || (errno != ENOTCONN && errno != ECONNRESET))
			Log(TRACE_MINIMUM, -1, "Socket error %s in %s for socket %d", strerror(errno), aString, sock);
	}
	FUNC_EXIT_RC(errno);
	return errno;
}

/*!
 *  Convert a numeric address to character string
 *  @param sa	socket numerical address
 *  @param sock socket
 *  @return the peer information
 */
char* Socket_getaddrname(struct sockaddr* sa, int sock)
{
    /*!
     * maximum length of the address string
     */
#define ADDRLEN INET6_ADDRSTRLEN+1
    /*!
     * maximum length of the port string
     */
#define PORTLEN 10
    static char addr_string[ADDRLEN + PORTLEN];
    struct sockaddr_in *sin = (struct sockaddr_in *)sa;
    inet_ntop(sin->sin_family, &sin->sin_addr, addr_string, ADDRLEN);
    sprintf(&addr_string[strlen(addr_string)], ":%d", ntohs(sin->sin_port));
    return addr_string;
}

/*!
 *  @abstract Attempts to write a series of iovec buffers to a socket in *one* system call so that they are sent as one packet.
 *
 *  @param socket the socket to write to.
 *  @param iovecs an array of buffers to write.
 *  @param count number of buffers in iovecs.
 *  @param bytes number of bytes actually written returned
 *  @return completion code, especially TCPSOCKET_INTERRUPTED
 */
int Socket_writev(int socket, iobuf* iovecs, int count, size_t* bytes)
{
    int rc;
    
    FUNC_ENTRY;
    *bytes = 0L;
    rc = (int)writev(socket, iovecs, count);
    if (rc == SOCKET_ERROR)
    {
        int err = Socket_error("writev - putdatas", socket);
        if (err == EWOULDBLOCK || err == EAGAIN) { rc = TCPSOCKET_INTERRUPTED; }
    }
    else { *bytes = rc; }
    
    FUNC_EXIT_RC(rc);
    return rc;
}

/*!
 *  Continue any outstanding writes for a socket set
 *  @param pwset the set of sockets
 *  @return completion code
 */
int Socket_continueWrites(fd_set* pwset)
{
    int rc1 = 0;
    ListElement* curpending = s.write_pending->first;
    
    FUNC_ENTRY;
    while (curpending)
    {
        int socket = *(int*)(curpending->content);
        if (FD_ISSET(socket, pwset) && Socket_continueWrite(socket))
        {
            if (!SocketBuffer_writeComplete(socket))
                Log(LOG_SEVERE, -1, "Failed to remove pending write from socket buffer list");
            FD_CLR(socket, &(s.pending_wset));
            if (!ListRemove(s.write_pending, curpending->content))
            {
                Log(LOG_SEVERE, -1, "Failed to remove pending write from list");
                ListNextElement(s.write_pending, &curpending);
            }
            curpending = s.write_pending->current;
            
            if (writecomplete)
                (*writecomplete)(socket);
        }
        else
            ListNextElement(s.write_pending, &curpending);
    }
    FUNC_EXIT_RC(rc1);
    return rc1;
}

/*!
 *  @abstract Continue an outstanding write for a particular socket
 *
 *  @param socket that socket
 *  @return completion code
 */
int Socket_continueWrite(int socket)
{
    int rc = 0;
    pending_writes* pw;
    size_t curbuflen = 0L, /* cumulative total of buffer lengths */
    bytes;
    int curbuf = -1, i;
    iobuf iovecs1[5];
    
    FUNC_ENTRY;
    pw = SocketBuffer_getWrite(socket);
    
    #if defined(OPENSSL)
    if (pw->ssl)
    {
        rc = SSLSocket_continueWrite(pw);
        goto exit;
    }
    #endif
    
    for (i = 0; i < pw->count; ++i)
    {
        if (pw->bytes <= curbuflen)
        { /* if previously written length is less than the buffer we are currently looking at,
           add the whole buffer */
            iovecs1[++curbuf].iov_len = pw->iovecs[i].iov_len;
            iovecs1[curbuf].iov_base = pw->iovecs[i].iov_base;
        }
        else if (pw->bytes < curbuflen + pw->iovecs[i].iov_len)
        { /* if previously written length is in the middle of the buffer we are currently looking at,
           add some of the buffer */
            long offset = pw->bytes - curbuflen;
            iovecs1[++curbuf].iov_len = pw->iovecs[i].iov_len - offset;
            iovecs1[curbuf].iov_base = pw->iovecs[i].iov_base + offset;
            break;
        }
        curbuflen += pw->iovecs[i].iov_len;
    }
    
    if ((rc = Socket_writev(socket, iovecs1, curbuf+1, &bytes)) != SOCKET_ERROR)
    {
        pw->bytes += bytes;
        if ((rc = (pw->bytes == pw->total)))
        {  /* topic and payload buffers are freed elsewhere, when all references to them have been removed */
            for (i = 0; i < pw->count; i++)
            {
                if (pw->frees[i])
                    free(pw->iovecs[i].iov_base);
            }
            Log(TRACE_MIN, -1, "ContinueWrite: partial write now complete for socket %d", socket);
        }
        else
            Log(TRACE_MIN, -1, "ContinueWrite wrote +%lu bytes on socket %d", bytes, socket);
    }
    
#if defined(OPENSSL)
exit:
#endif
    FUNC_EXIT_RC(rc);
    return rc;
}

/*!
 *  @abstract Close a socket without removing it from the select list.
 *
 *  @param socket the socket to close.
 *  @return completion code
 */
int Socket_close_only(int socket)
{
    int rc;
    
    FUNC_ENTRY;
    if (shutdown(socket, SHUT_WR) == SOCKET_ERROR)
        Socket_error("shutdown", socket);
    if ((rc = (int)recv(socket, NULL, (size_t)0, 0)) == SOCKET_ERROR)
        Socket_error("shutdown", socket);
    if ((rc = close(socket)) == SOCKET_ERROR)
        Socket_error("close", socket);
    FUNC_EXIT_RC(rc);
    return rc;
}
