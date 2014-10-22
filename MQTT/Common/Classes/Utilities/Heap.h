/*!
 *  @abstract Functions to manage the heap with the goal of eliminating memory leaks.
 *  @discussion For any module to use these functions transparently, simply include the Heap.h header file. Malloc and free will be redefined, but will behave in exactly the same way as normal, so no recoding is necessary.
 **/
#pragma once

#if defined(HIGH_PERFORMANCE)
    #define NO_HEAP_TRACKING 1
#endif

#include <stdio.h>      // C Standard
#include <stdlib.h>     // C Standard
#include <memory.h>

#pragma mark Definitions

#if !defined(NO_HEAP_TRACKING)
/*!
 *  @abstract Redefines malloc to use "mymalloc" so that heap allocation can be tracked.
 *
 *  @param x the size of the item to be allocated
 *  @return the pointer to the item allocated, or NULL
 */
#define malloc(x) mymalloc(__FILE__, __LINE__, x)

/*!
 *  @abstract Redefines realloc to use "myrealloc" so that heap allocation can be tracked.
 *
 *  @param a The heap item to be reallocated.
 *  @param b The new size of the item.
 *  @return The new pointer to the heap item.
 */
#define realloc(a, b) myrealloc(__FILE__, __LINE__, a, b)

/*!
 *  @abstract Redefines free to use "myfree" so that heap allocation can be tracked.
 *
 *  @param x The size of the item to be freed.
 */
#define free(x) myfree(__FILE__, __LINE__, x)
#endif

/*!
 *  @abstract Information about the state of the heap.
 */
typedef struct
{
	int current_size;	// Current size of the heap in bytes.
	size_t max_size;	// Max size the heap has reached in bytes.
} heap_info;

/*!
 *  @abstrac Allocates a block of memory.
 *  @discussion A direct replacement for malloc, but keeps track of items allocated in a list, so that free can check that a item is being freed correctly and that we can check that all memory is freed at shutdown.
 *
 *  @param file Use the __FILE__ macro to indicate which file this item was allocated in.
 *  @param line Use the __LINE__ macro to indicate which line this item was allocated at.
 *  @param size The size of the item to be allocated.
 *  @return Pointer to the allocated item, or NULL if there was an error.
 */
void* mymalloc(char* file, int line, size_t size);

/*!
 *  @abstrac Reallocates a block of memory.
 *  @discussion A direct replacement for realloc, but keeps track of items allocated in a list, so that free can check that a item is being freed correctly and that we can check that all memory is freed at shutdown. We have to remove the item from the tree, as the memory is in order and so it needs to be reinserted in the correct place.
 *
 *  @param file use the __FILE__ macro to indicate which file this item was reallocated in.
 *  @param line use the __LINE__ macro to indicate which line this item was reallocated at.
 *  @param p pointer to the item to be reallocated.
 *  @param size the new size of the item.
 *  @return pointer to the allocated item, or NULL if there was an error.
 */
void* myrealloc(char*, int, void* p, size_t size);

/*!
 *  @abstrac Frees a block of memory.
 *  @discussion A direct replacement for free, but checks that a item is in the allocates list first.
 *
 *  @param file use the __FILE__ macro to indicate which file this item was allocated in
 *  @param line use the __LINE__ macro to indicate which line this item was allocated at
 *  @param p pointer to the item to be freed
 */
void myfree(char*, int, void* p);

/*!
 *  @abstrac Heap initialization.
 */
int Heap_initialize(void);

/*!
 *  @abstrac Heap termination.
 */
void Heap_terminate(void);

/*!
 *  @abstrac Access to heap state
 *
 *  @return pointer to the heap state structure
 */
heap_info* Heap_get_info(void);

/*!
 *  @abstrac Dump the state of the heap.
 *
 *  @param file file handle to dump the heap contents to.
 */
int HeapDump(FILE* file);

/*!
 *  @abstrac Dump a string from the heap so that it can be displayed conveniently
 *
 *  @param file file handle to dump the heap contents to
 *  @param str the string to dump, could be NULL
 */
int HeapDumpString(FILE* file, char* str);

/*!
 *  @abstrac Utility to find an item in the heap.  Lets you know if the heap already contains the memory location in question.
 *
 *  @param p pointer to a memory location
 *  @return pointer to the storage element if found, or NULL
 */
void* Heap_findItem(void* p);

/*!
 *  @abstrac Remove an item from the recorded heap without actually freeing it.
 *  @note Use sparingly!
 *
 *  @param file use the __FILE__ macro to indicate which file this item was allocated in
 *  @param line use the __LINE__ macro to indicate which line this item was allocated at
 *  @param p pointer to the item to be removed
 */
void Heap_unlink(char* file, int line, void* p);
