/*!
 *  @abstract Socket related functions.
 *  @discussion Some other related functions are in the SocketBuffer module.
 */
#pragma once

#include <sys/types.h>      // POSIX

#define INVALID_SOCKET SOCKET_ERROR
#include <sys/socket.h>     // POSIX
#include <sys/param.h>      // POSIX
#include <sys/time.h>       // POSIX
#include <sys/select.h>     // POSIX
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>          // C Standard
#include <unistd.h>
#include <errno.h>          // C Standard
#include <fcntl.h>
#include <unistd.h>
#include <sys/uio.h>        // POSIX
#include "LinkedList.h"     // MQTT (Utilities)

#pragma mark Definitions

// Socket operation completed successfully.
#define TCPSOCKET_COMPLETE 0

#if !defined(SOCKET_ERROR)
	// Error in socket operation.
	#define SOCKET_ERROR -1
#endif

// Must be the same as SOCKETBUFFER_INTERRUPTED.
#define TCPSOCKET_INTERRUPTED -22
#define SSL_FATAL -3

#if !defined(INET6_ADDRSTRLEN)
    #define INET6_ADDRSTRLEN 46     // Only needed for gcc/cygwin on windows.
#endif


#if !defined(max)
    #define max(A,B) ( (A) > (B) ? (A):(B))
#endif

/**
 *  @abstract Structure to hold all socket data for the module
 *
 *  @field rset Socket read set.
 *  @field rset_saved Saved socket read set.
 *  @field maxfdp1 Max descriptor used +1.
 *  @field clientsds List of client socket descriptors.
 *  @field cur_clientsds Current client socket descriptor (iterator).
 *  @field connect_pending List of sockets for which a connect is pending.
 *  @field write_pending List of sockets for which a write is pending.
 *  @field pending_wset Socket pending write set for select.
 */
typedef struct
{
    fd_set rset;
    fd_set rset_saved;
	int maxfdp1;
	List* clientsds;
	ListElement* cur_clientsds;
	List* connect_pending;
	List* write_pending;
	fd_set pending_wset;
} Sockets;

typedef void Socket_writeComplete(int socket);

#pragma mark Public API

/*!
 *  @abstract Initialize the socket module.
 */
void Socket_outInitialize(void);

/*!
 *  @abstract Terminate the socket module.
 */
void Socket_outTerminate(void);

/*!
 *  Returns the next socket ready for communications as indicated by select
 *
 *  @param more_work flag to indicate more work is waiting, and thus a timeout value of 0 should be used for the select.
 *  @param tp the timeout to be used for the select, unless overridden.
 *  @return the socket next ready, or 0 if none is ready.
 */
int Socket_getReadySocket(int more_work, struct timeval *tp);

/*!
 *  @abstract Reads one byte from a socket
 *
 *  @param socket the socket to read from
 *  @param c the character read, returned
 *  @return completion code
 */
int Socket_getch(int socket, char* c);
/*!
 *  @abstract Attempts to read a number of bytes from a socket, non-blocking. If a previous read did not finish, then retrieve that data.
 *
 *  @param socket the socket to read from.
 *  @param bytes the number of bytes to read.
 *  @param actual_len the actual number of bytes read.
 *  @return completion code.
 */
char* Socket_getdata(int socket, size_t bytes, size_t* actual_len);

/*!
 *  @abstract Attempts to write a series of buffers to a socket in *one* system call so that they are sent as one packet.
 *
 *  @param socket the socket to write to
 *  @param buf0 the first buffer
 *  @param buf0len the length of data in the first buffer
 *  @param count number of buffers
 *  @param buffers an array of buffers to write
 *  @param buflens an array of corresponding buffer lengths
 *  @return completion code, especially TCPSOCKET_INTERRUPTED
 */
int Socket_putdatas(int socket, char* buf0, size_t buf0len, int count, char** buffers, size_t* buflens, int* frees);

/*!
 *  @abstract Close a socket and remove it from the select list.
 *
 *  @param socket the socket to close
 *  @return completion code
 */
void Socket_close(int socket);

/*!
 *  @abstract Create a new socket and TCP connect to an address/port.
 *
 *  @param addr the address string.
 *  @param port the TCP port.
 *  @param sock returns the new socket.
 *  @return completion code.
 */
int Socket_new(char* addr, int port, int* socket);

/*!
 *  @abstract Indicate whether any data is pending outbound for a socket.
 *
 *  @return boolean - true == data pending.
 */
int Socket_noPendingWrites(int socket);

/*!
 *  @abstract Get information about the other end connected to a socket.
 *
 *  @param sock the socket to inquire on.
 *  @return the peer information.
 */
char* Socket_getpeer(int sock);

/*!
 *  @abstract Add a socket to the pending write list, so that it is checked for writing in select.  This is used in connect processing when the TCP connect is incomplete, as we need to check the socket for both ready to read and write states.
 *
 *  @param socket the socket to add
 */
void Socket_addPendingWrite(int socket);

/*!
 *  @abstract Clear a socket from the pending write list - if one was added with Socket_addPendingWrite.
 *  @param socket the socket to remove.
 */
void Socket_clearPendingWrite(int socket);

void Socket_setWriteCompleteCallback(Socket_writeComplete*);
