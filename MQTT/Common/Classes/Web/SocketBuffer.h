/*!
 *  @abstract Socket buffering related functions
 *  @discussion Some other related functions are in the Socket module
 */
#pragma once

#include <sys/socket.h>     // Unix (System)
#if defined(OPENSSL)
#include <openssl/ssl.h>    // OpenSSL
#endif

#pragma mark Definitions

typedef struct iovec iobuf;

typedef struct
{
	int socket;
	int index, headerlen;
	char fixed_header[5];	// Header plus up to 4 length bytes
    size_t buflen; 			// Total length of the buffer
    size_t datalen; 		// current length of data in buf
	char* buf;
} socket_queue;

typedef struct
{
	int socket, count;
    #if defined(OPENSSL)
	SSL* ssl;
    #endif
	size_t bytes;
    size_t total;
	iobuf iovecs[5];
	int frees[5];
} pending_writes;

#define SOCKETBUFFER_COMPLETE 0
#if !defined(SOCKET_ERROR)
	#define SOCKET_ERROR -1
#endif
#define SOCKETBUFFER_INTERRUPTED -22 /* must be the same value as TCPSOCKET_INTERRUPTED */

#pragma mark Public API

/*!
 *  @abstract Initialize the socketBuffer module
 */
void SocketBuffer_initialize(void);

/*!
 *  @abstract Terminate the socketBuffer module
 */
void SocketBuffer_terminate(void);

/*!
 *  @abstract Cleanup any buffers for a specific socket.
 *
 *  @param socket The socket to clean up.
 */
void SocketBuffer_cleanup(int socket);

/*!
 *  @abstract Get any queued data for a specific socket
 *
 *  @param socket the socket to get queued data for
 *  @param bytes the number of bytes of data to retrieve
 *  @param actual_len the actual length returned
 *  @return the actual data
 */
char* SocketBuffer_getQueuedData(int socket, size_t bytes, size_t* actual_len);

/*!
 *  @abstract Get any queued character for a specific socket
 *
 *  @param socket the socket to get queued data for
 *  @param c the character returned if any
 *  @return completion code
 */
int SocketBuffer_getQueuedChar(int socket, char* c);

/*!
 *  @abstract A socket read was interrupted so we need to queue data
 *
 *  @param socket the socket to get queued data for
 *  @param actual_len the actual length of data that was read
 */
void SocketBuffer_interrupted(int socket, size_t actual_len);

/*!
 *  @abstract A socket read has now completed so we can get rid of the queue
 *
 *  @param socket the socket for which the operation is now complete
 *  @return pointer to the default queue data
 */
char* SocketBuffer_complete(int socket);

/*!
 *  @abstract A socket operation had now completed so we can get rid of the queue
 *
 *  @param socket The socket for which the operation is now complete
 *  @param c The character to queue
 */
void SocketBuffer_queueChar(int socket, char c);

/*!
 *  @abstrac A socket write was interrupted so store the remaining data
 *
 *  @param socket The socket for which the write was interrupted
 *  @param count The number of iovec buffers
 *  @param iovecs Buffer array
 *  @param total Total data length to be written
 *  @param bytes Actual data length that was written
 */
#if defined(OPENSSL)
void SocketBuffer_pendingWrite(int socket, SSL* ssl, int count, iobuf* iovecs, int* frees, size_t total, size_t bytes);
#else
void SocketBuffer_pendingWrite(int socket, int count, iobuf* iovecs, int* frees, size_t total, size_t bytes);
#endif

/*!
 *  @abstrac Get any queued write data for a specific socket
 *
 *  @param socket the socket to get queued data for
 *  @return pointer to the queued data or NULL
 */
pending_writes* SocketBuffer_getWrite(int socket);

/*!
 *  @abstrac A socket write has now completed so we can get rid of the queue
 *
 *  @param socket the socket for which the operation is now complete
 *  @return completion code, boolean - was the queue removed?
 */
int SocketBuffer_writeComplete(int socket);

/*!
 *  @abstrac Update the queued write data for a socket in the case of QoS 0 messages.
 *
 *  @param socket the socket for which the operation is now complete
 *  @param topic the topic of the QoS 0 write
 *  @param payload the payload of the QoS 0 write
 *  @return pointer to the updated queued data structure, or NULL
 */
pending_writes* SocketBuffer_updateWrite(int socket, char* topic, char* payload);
