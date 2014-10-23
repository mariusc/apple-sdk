#include "SocketBuffer.h"
#include "LinkedList.h"
#include "Log.h"
#include "Messages.h"
#include "StackTrace.h"

#include <stdbool.h>        // C Standard
#include <stdlib.h>         // C Standard
#include <stdio.h>          // C Standard
#include <memory.h>         

#include "Heap.h"

#pragma mark - Variables

static socket_queue* def_queue; // Default input queue buffer
static List* queues;            // List of queued input buffers
static List writes;             // List of queued write buffers

#pragma mark - Private Prototypes

void SocketBuffer_newDefQ(void);
void SocketBuffer_freeDefQ(void);
bool socketcompare(void const* a, void const* b);
bool pending_socketcompare(void const * a, void const* b);

#pragma mark - Public API

void SocketBuffer_initialize(void)
{
    FUNC_ENTRY;
    SocketBuffer_newDefQ();
    queues = ListInitialize();
    ListZero(&writes);
    FUNC_EXIT;
}

void SocketBuffer_terminate(void)
{
    ListElement* cur = NULL;
    ListEmpty(&writes);
    
    FUNC_ENTRY;
    while (ListNextElement(queues, &cur))
        free(((socket_queue*)(cur->content))->buf);
    ListFree(queues);
    SocketBuffer_freeDefQ();
    FUNC_EXIT;
}

void SocketBuffer_cleanup(int socket)
{
    FUNC_ENTRY;
    if (ListFindItem(queues, &socket, socketcompare))
    {
        free(((socket_queue*)(queues->current->content))->buf);
        ListRemove(queues, queues->current->content);
    }
    if (def_queue->socket == socket)
        def_queue->socket = def_queue->index = def_queue->headerlen = def_queue->datalen = 0;
    FUNC_EXIT;
}

char* SocketBuffer_getQueuedData(int socket, size_t bytes, size_t* actual_len)
{
    socket_queue* queue = NULL;
    
    FUNC_ENTRY;
    if (ListFindItem(queues, &socket, socketcompare))
    {  /* if there is queued data for this socket, add any data read to it */
        queue = (socket_queue*)(queues->current->content);
        *actual_len = queue->datalen;
    }
    else
    {
        *actual_len = 0;
        queue = def_queue;
    }
    if (bytes > queue->buflen)
    {
        if (queue->datalen > 0)
        {
            void* newmem = malloc(bytes);
            memcpy(newmem, queue->buf, queue->datalen);
            free(queue->buf);
            queue->buf = newmem;
        }
        else { queue->buf = realloc(queue->buf, bytes); }
        queue->buflen = bytes;
    }
    
    FUNC_EXIT;
    return queue->buf;
}

int SocketBuffer_getQueuedChar(int socket, char* c)
{
    int rc = SOCKETBUFFER_INTERRUPTED;
    
    FUNC_ENTRY;
    if (ListFindItem(queues, &socket, socketcompare))
    {  /* if there is queued data for this socket, read that first */
        socket_queue* queue = (socket_queue*)(queues->current->content);
        if (queue->index < queue->headerlen)
        {
            *c = queue->fixed_header[(queue->index)++];
            Log(TRACE_MAX, -1, "index is now %d, headerlen %d", queue->index, queue->headerlen);
            rc = SOCKETBUFFER_COMPLETE;
            goto exit;
        }
        else if (queue->index > 4)
        {
            Log(LOG_FATAL, -1, "header is already at full length");
            rc = SOCKET_ERROR;
            goto exit;
        }
    }
exit:
    FUNC_EXIT_RC(rc);
    return rc;  /* there was no queued char if rc is SOCKETBUFFER_INTERRUPTED*/
}

void SocketBuffer_interrupted(int socket, size_t actual_len)
{
    socket_queue* queue = NULL;
    
    FUNC_ENTRY;
    if (ListFindItem(queues, &socket, socketcompare))
    {
        queue = (socket_queue*)(queues->current->content);
    }
    else /* new saved queue */
    {
        queue = def_queue;
        ListAppend(queues, def_queue, sizeof(socket_queue)+def_queue->buflen);
        SocketBuffer_newDefQ();
    }
    queue->index = 0;
    queue->datalen = actual_len;
    FUNC_EXIT;
}

char* SocketBuffer_complete(int socket)
{
    FUNC_ENTRY;
    if (ListFindItem(queues, &socket, socketcompare))
    {
        socket_queue* queue = (socket_queue*)(queues->current->content);
        SocketBuffer_freeDefQ();
        def_queue = queue;
        ListDetach(queues, queue);
    }
    def_queue->socket = def_queue->index = def_queue->headerlen = def_queue->datalen = 0;
    FUNC_EXIT;
    return def_queue->buf;
}

void SocketBuffer_queueChar(int socket, char c)
{
    int error = 0;
    socket_queue* curq = def_queue;
    
    FUNC_ENTRY;
    if (ListFindItem(queues, &socket, socketcompare))
        curq = (socket_queue*)(queues->current->content);
    else if (def_queue->socket == 0)
    {
        def_queue->socket = socket;
        def_queue->index = def_queue->datalen = 0;
    }
    else if (def_queue->socket != socket)
    {
        Log(LOG_FATAL, -1, "attempt to reuse socket queue");
        error = 1;
    }
    if (curq->index > 4)
    {
        Log(LOG_FATAL, -1, "socket queue fixed_header field full");
        error = 1;
    }
    if (!error)
    {
        curq->fixed_header[(curq->index)++] = c;
        curq->headerlen = curq->index;
    }
    Log(TRACE_MAX, -1, "queueChar: index is now %d, headerlen %d", curq->index, curq->headerlen);
    FUNC_EXIT;
}

#if defined(OPENSSL)
void SocketBuffer_pendingWrite(int socket, SSL* ssl, int count, iobuf* iovecs, int* frees, size_t total, size_t bytes)
#else
void SocketBuffer_pendingWrite(int socket, int count, iobuf* iovecs, int* frees, size_t total, size_t bytes)
#endif
{
    FUNC_ENTRY;
    /* store the buffers until the whole packet is written */
    pending_writes* pw = malloc(sizeof(pending_writes));
    pw->socket = socket;
#if defined(OPENSSL)
    pw->ssl = ssl;
#endif
    pw->bytes = bytes;
    pw->total = total;
    pw->count = count;
    for (int i = 0; i < count; i++)
    {
        pw->iovecs[i] = iovecs[i];
        pw->frees[i] = frees[i];
    }
    ListAppend(&writes, pw, sizeof(pw) + total);
    FUNC_EXIT;
}

pending_writes* SocketBuffer_getWrite(int socket)
{
    ListElement* le = ListFindItem(&writes, &socket, pending_socketcompare);
    return (le) ? (pending_writes*)(le->content) : NULL;
}

int SocketBuffer_writeComplete(int socket)
{
    return ListRemoveItem(&writes, &socket, pending_socketcompare);
}

pending_writes* SocketBuffer_updateWrite(int socket, char* topic, char* payload)
{
    pending_writes* pw = NULL;
    ListElement* le = NULL;
    
    FUNC_ENTRY;
    if ((le = ListFindItem(&writes, &socket, pending_socketcompare)) != NULL)
    {
        pw = (pending_writes*)(le->content);
        if (pw->count == 4)
        {
            pw->iovecs[2].iov_base = topic;
            pw->iovecs[3].iov_base = payload;
        }
    }
    
    FUNC_EXIT;
    return pw;
}

#pragma mark - Private functionality

/*!
 *  @abstract Create a new default queue when one has just been used.
 */
void SocketBuffer_newDefQ(void)
{
    def_queue = malloc(sizeof(socket_queue));
    def_queue->buflen = 1000;
    def_queue->buf = malloc(def_queue->buflen);
    def_queue->socket = def_queue->index = def_queue->buflen = def_queue->datalen = 0;
}

/*!
 *  @abstract Free the default queue memory
 */
void SocketBuffer_freeDefQ(void)
{
    free(def_queue->buf);
    free(def_queue);
}

#pragma mark Comparison functions

/*!
 *  @abstract List callback function for comparing socket_queues by socket
 *
 *  @param a First integer value
 *  @param b Second integer value
 *  @return Boolean indicating whether a and b are equal
 */
bool socketcompare(void const* a, void const* b)
{
    return (((socket_queue*)a)->socket == *(int*)b) ? true : false;
}

/*!
 *  @abstract List callback function for comparing pending_writes by socket
 *
 *  @param a First integer value.
 *  @param b Second integer value.
 *  @return Boolean indicating whether a and b are equal.
 */
bool pending_socketcompare(void const * a, void const* b)
{
    return (((pending_writes*)a)->socket == *(int*)b) ? true : false;
}
