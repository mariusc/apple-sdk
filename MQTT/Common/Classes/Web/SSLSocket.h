#pragma once

#include <pthread.h>
#include <semaphore.h>
#define ssl_mutex_type pthread_mutex_t

#include <openssl/ssl.h>
#include "SocketBuffer.h"
#include "Clients.h"

#define URI_SSL "ssl://"

int SSLSocket_initialize();

int SSLSocket_setSocketForSSL(networkHandles* net, MQTTClient_SSLOptions* opts);

int SSLSocket_connect(SSL* ssl, int socket);

/*!
 *  @abstract Reads one byte from a socket.
 *
 *  @param socket the socket to read from.
 *  @param c the character read, returned.
 *  @return completion code.
 */
int SSLSocket_getch(SSL* ssl, int socket, char* c);

/*!
 *  @abstract Attempts to read a number of bytes from a socket, non-blocking. If a previous read did not finish, then retrieve that data.
 *
 *  @param socket The socket to read from.
 *  @param bytes The number of bytes to read.
 *  @param actual_len The actual number of bytes read.
 *  @return Completion code.
 */
char *SSLSocket_getdata(SSL* ssl, int socket, size_t bytes, size_t* actual_len);

int SSLSocket_putdatas(SSL* ssl, int socket, char* buf0, size_t buf0len, int count, char** buffers, size_t* buflens, int* frees);

int SSLSocket_getPendingRead();

int SSLSocket_continueWrite(pending_writes* pw);

int SSLSocket_close(networkHandles* net);

void SSLSocket_terminate();
