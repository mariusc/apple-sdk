#pragma once

#include <pthread.h>
#include <semaphore.h>
#define ssl_mutex_type pthread_mutex_t

#include <openssl/ssl.h>
#include "SocketBuffer.h"
#include "Clients.h"

#define URI_SSL "ssl://"

int SSLSocket_initialize();
void SSLSocket_terminate();
int SSLSocket_setSocketForSSL(networkHandles* net, MQTTClient_SSLOptions* opts);
int SSLSocket_getch(SSL* ssl, int socket, char* c);
char *SSLSocket_getdata(SSL* ssl, int socket, int bytes, int* actual_len);

int SSLSocket_close(networkHandles* net);
int SSLSocket_putdatas(SSL* ssl, int socket, char* buf0, size_t buf0len, int count, char** buffers, size_t* buflens, int* frees);
int SSLSocket_connect(SSL* ssl, int socket);

int SSLSocket_getPendingRead();
int SSLSocket_continueWrite(pending_writes* pw);
