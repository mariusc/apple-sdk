#include "Tree.h"       // MQTT (Utilities)
#include "Log.h"        // MQTT (Utilities)
#include "StackTrace.h" // MQTT (Utilities)
#include "Thread.h"     // MQTT (Utilites)
char* Broker_recordFFDC(char* symptoms);

#include <memory.h>
#include <stdlib.h>     // C Standard
#include <string.h>     // C Standard
#include <stdio.h>      // C Standard
#include <stddef.h>     // C Standard

#include "Heap.h"       // Header

#undef malloc
#undef realloc
#undef free

#pragma mark - Variables

static pthread_mutex_t heap_mutex_store = PTHREAD_MUTEX_INITIALIZER;
static mutex_type heap_mutex = &heap_mutex_store;

static heap_info state = {0, 0}; /**< global heap state information */
static int eyecatcher = 0x88888888;

static Tree heap;   //Tree that holds the allocation records.
static char const* errmsg = "Memory allocation error";

#pragma mark - Definitions

/*!
 *  @abstrac Each item on the heap is recorded with this structure.
 */
typedef struct
{
	char* file;		// The name of the source file where the storage was allocated.
	int line;		// The line no in the source file where it was allocated.
	void* ptr;		// Pointer to the allocated storage.
	size_t size;    // Size of the allocated storage.
} storageElement;

#pragma mark - Private prototypes

size_t Heap_roundup(size_t size);
void checkEyecatchers(char* file, int line, void* p, size_t const size);
int Internal_heap_unlink(char* file, int line, void* p);
void HeapScan(int log_level);
int ptrCompare(void* a, void* b, int value);

#pragma mark - Public API

void* mymalloc(char* file, int line, size_t size)
{
    storageElement* s = NULL;
    size_t space = sizeof(storageElement);
    size_t const filenamelen = strlen(file)+1;
    
    Thread_lock_mutex(heap_mutex);
    size = Heap_roundup(size);
    if ((s = malloc(sizeof(storageElement))) == NULL)
    {
        Log(LOG_ERROR, 13, errmsg);
        return NULL;
    }
    s->size = size; /* size without eyecatchers */
    if ((s->file = malloc(filenamelen)) == NULL)
    {
        Log(LOG_ERROR, 13, errmsg);
        free(s);
        return NULL;
    }
    space += filenamelen;
    strcpy(s->file, file);
    s->line = line;
    /* Add space for eyecatcher at each end */
    if ((s->ptr = malloc(size + 2*sizeof(int))) == NULL)
    {
        Log(LOG_ERROR, 13, errmsg);
        free(s->file);
        free(s);
        return NULL;
    }
    space += size + 2*sizeof(int);
    *(int*)(s->ptr) = eyecatcher; /* start eyecatcher */
    *(int*)(((char*)(s->ptr)) + (sizeof(int) + size)) = eyecatcher; /* end eyecatcher */
    Log(TRACE_MAX, -1, "Allocating %d bytes in heap at file %s line %d ptr %p\n", size, file, line, s->ptr);
    TreeAdd(&heap, s, space);
    state.current_size += size;
    if (state.current_size > state.max_size)
        state.max_size = state.current_size;
    Thread_unlock_mutex(heap_mutex);
    return ((int*)(s->ptr)) + 1;	/* skip start eyecatcher */
}

void* myrealloc(char* file, int line, void* p, size_t size)
{
    void* rc = NULL;
    storageElement* s = NULL;
    
    Thread_lock_mutex(heap_mutex);
    s = TreeRemoveKey(&heap, ((int*)p)-1);
    if (s == NULL)
        Log(LOG_ERROR, 13, "Failed to reallocate heap item at file %s line %d", file, line);
    else
    {
        int space = sizeof(storageElement);
        size_t filenamelen = strlen(file)+1;
        
        checkEyecatchers(file, line, p, s->size);
        size = Heap_roundup(size);
        state.current_size += size - s->size;
        if (state.current_size > state.max_size)
            state.max_size = state.current_size;
        if ((s->ptr = realloc(s->ptr, size + 2*sizeof(int))) == NULL)
        {
            Log(LOG_ERROR, 13, errmsg);
            return NULL;
        }
        space += size + 2*sizeof(int) - s->size;
        *(int*)(s->ptr) = eyecatcher; /* start eyecatcher */
        *(int*)(((char*)(s->ptr)) + (sizeof(int) + size)) = eyecatcher; /* end eyecatcher */
        s->size = size;
        space -= strlen(s->file);
        s->file = realloc(s->file, filenamelen);
        space += filenamelen;
        strcpy(s->file, file);
        s->line = line;
        rc = s->ptr;
        TreeAdd(&heap, s, space);
    }
    Thread_unlock_mutex(heap_mutex);
    return (rc == NULL) ? NULL : ((int*)(rc)) + 1;	/* skip start eyecatcher */
}

void myfree(char* file, int line, void* p)
{
    Thread_lock_mutex(heap_mutex);
    if (Internal_heap_unlink(file, line, p)) { free(((int*)p)-1); }
    Thread_unlock_mutex(heap_mutex);
}

int Heap_initialize()
{
    TreeInitializeNoMalloc(&heap, ptrCompare);
    heap.heap_tracking = 0; /* no recursive heap tracking! */
    return 0;
}

void Heap_terminate()
{
    Log(TRACE_MIN, -1, "Maximum heap use was %d bytes", state.max_size);
    if (state.current_size > 20) /* One log list is freed after this function is called */
    {
        Log(LOG_ERROR, -1, "Some memory not freed at shutdown, possible memory leak");
        HeapScan(LOG_ERROR);
    }
}

heap_info* Heap_get_info()
{
    return &state;
}

int HeapDump(FILE* file)
{
    int rc = 0;
    Node* current = NULL;
    
    while (rc == 0 && (current = TreeNextElement(&heap, current)))
    {
        storageElement* s = (storageElement*)(current->content);
        
        if (fwrite(&(s->ptr), sizeof(s->ptr), 1, file) != 1)
            rc = -1;
        else if (fwrite(&(current->size), sizeof(current->size), 1, file) != 1)
            rc = -1;
        else if (fwrite(s->ptr, current->size, 1, file) != 1)
            rc = -1;
    }
    return rc;
}

int HeapDumpString(FILE* file, char* str)
{
    int rc = 0;
    size_t const len = str ? strlen(str) + 1 : 0; // Include the trailing null.
    
    if (fwrite(&(str), sizeof(char*), 1, file) != 1) {
        rc = -1;
    } else if (fwrite(&(len), sizeof(int), 1 ,file) != 1) {
        rc = -1;
    } else if (len > 0 && fwrite(str, len, 1, file) != 1) {
        rc = -1;
    }
    return rc;
}

void* Heap_findItem(void* p)
{
    Node* e = NULL;
    
    Thread_lock_mutex(heap_mutex);
    e = TreeFind(&heap, ((int*)p)-1);
    Thread_unlock_mutex(heap_mutex);
    return (e == NULL) ? NULL : e->content;
}

void Heap_unlink(char* file, int line, void* p)
{
    Thread_lock_mutex(heap_mutex);
    Internal_heap_unlink(file, line, p);
    Thread_unlock_mutex(heap_mutex);
}

#pragma mark - Private functionality

/*!
 *  @abstrac Round allocation size up to a multiple of the size of an int.
 *  @discussion Apart from possibly reducing fragmentation, on the old v3 gcc compilers I was hitting some weird behaviour, which might have been errors in sizeof() used on structures and related to packing.  In any case, this fixes that too.
 *
 *  @param size The size actually needed
 *  @return The rounded up size
 */
size_t Heap_roundup(size_t size)
{
	static size_t multsize = 4*sizeof(int);

    if (size % multsize != 0) { size += multsize - (size % multsize); }
	return size;
}

void checkEyecatchers(char* file, int line, void* p, size_t const size)
{
	int *sp = (int*)p;
	char *cp = (char*)p;
	int us;
	static char* msg = "Invalid %s eyecatcher %d in heap item at file %s line %d";

    if ((us = *--sp) != eyecatcher) {
		Log(LOG_ERROR, 13, msg, "start", us, file, line);
    }

	cp += size;
    if ((us = *(int*)cp) != eyecatcher) {
		Log(LOG_ERROR, 13, msg, "end", us, file, line);
    }
}

/*!
 *  @abstrac Remove an item from the recorded heap without actually freeing it.
 *  @note Use sparingly!
 *
 *  @param file Use the __FILE__ macro to indicate which file this item was allocated in.
 *  @param line Use the __LINE__ macro to indicate which line this item was allocated at.
 *  @param p Pointer to the item to be removed.
 */
int Internal_heap_unlink(char* file, int line, void* p)
{
	int rc = 0;

	Node* e = TreeFind(&heap, ((int*)p)-1);
    if (e == NULL)
    {
		Log(LOG_ERROR, 13, "Failed to remove heap item at file %s line %d", file, line);
    }
    else
	{
		storageElement* s = (storageElement*)(e->content);
		Log(TRACE_MAX, -1, "Freeing %d bytes in heap at file %s line %d, heap use now %d bytes\n",
											 s->size, file, line, state.current_size);
		checkEyecatchers(file, line, p, s->size);
		//free(s->ptr);
		free(s->file);
		state.current_size -= s->size;
		TreeRemoveNodeIndex(&heap, e, 0);
		free(s);
		rc = 1;
	}
	return rc;
}

/*!
 *  @abstrac Scans the heap and reports any items currently allocated.
 *  @discussion To be used at shutdown if any heap items have not been freed.
 */
void HeapScan(int log_level)
{
	Node* current = NULL;

	Thread_lock_mutex(heap_mutex);
	Log(log_level, -1, "Heap scan start, total %d bytes", state.current_size);
	while ((current = TreeNextElement(&heap, current)) != NULL)
	{
		storageElement* s = (storageElement*)(current->content);
		Log(log_level, -1, "Heap element size %d, line %d, file %s, ptr %p", s->size, s->line, s->file, s->ptr);
		Log(log_level, -1, "  Content %*.s", (10 > current->size) ? s->size : 10, (char*)(((int*)s->ptr) + 1));
	}
	Log(log_level, -1, "Heap scan end");
	Thread_unlock_mutex(heap_mutex);
}

#pragma mark Comparison

/*!
 *  @abstrac List callback function for comparing storage elements.
 *
 *  @param a Pointer to the current content in the tree (storageElement*).
 *  @param b Pointer to the memory to free.
 *  @param value
 *  @return Boolean indicating whether a and b are equal.
 */
int ptrCompare(void* a, void* b, int value)
{
    a = ((storageElement*)a)->ptr;
    if (value) { b = ((storageElement*)b)->ptr; }
    
    return (a > b) ? -1 : (a == b) ? 0 : 1;
}
