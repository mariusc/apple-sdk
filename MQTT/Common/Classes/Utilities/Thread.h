#pragma once

#include <pthread.h>        // POSIX
#include <semaphore.h>      // POSIX

#pragma mark Definitions

typedef struct {
    pthread_cond_t cond;
    pthread_mutex_t mutex;
} cond_type_struct;

typedef void* (*thread_fn)(void*);

#pragma mark Public API

/*!
 *  @abstract Create a new mutex
 *
 *  @return the new mutex
 */
pthread_mutex_t* Thread_create_mutex();

/*!
 *  @abstract Lock a mutex which has already been created, block until ready
 *
 *  @param mutex the mutex
 *  @return completion code, 0 is success
 */
int Thread_lock_mutex(pthread_mutex_t*);

/*!
 *  @abstract Unlock a mutex which has already been locked
 *
 *  @param mutex the mutex
 *  @return completion code, 0 is success
 */
int Thread_unlock_mutex(pthread_mutex_t*);

/*!
 *  @abstract Destroy a mutex which has already been created
 *
 * @param mutex the mutex
 */
void Thread_destroy_mutex(pthread_mutex_t*);

/*!
 *  @abstract Create a new semaphore
 *
 * @return the new condition variable
 */
sem_t* Thread_create_sem();

/*!
 *  @abstract Wait for a semaphore to be posted, or timeout.
 *
 *  @param sem The semaphore.
 *  @param timeout The maximum time to wait, in milliseconds.
 *  @return Completion code.
 */
int Thread_wait_sem(sem_t* sem, int timeout);

/*!
 *  @abstract Check to see if a semaphore has been posted, without waiting.
 *
 *  @param sem the semaphore.
 *  @return 0 (false) or 1 (true).
 */
int Thread_check_sem(sem_t* sem);

/*!
 *  @abstract Post a semaphore.
 *
 *  @param sem the semaphore.
 *  @return completion code.
 */
int Thread_post_sem(sem_t* sem);

/*!
 *  @abstract Destroy a semaphore which has already been created.
 *
 *  @param sem the semaphore.
 */
int Thread_destroy_sem(sem_t* sem);

/*!
 *  @abstract Create a new condition variable.
 *
 *  @return the condition variable struct.
 */
cond_type_struct* Thread_create_cond();

/*!
 *  @abstract Signal a condition variable.
 *
 *  @return completion code.
 */
int Thread_signal_cond(cond_type_struct*);

/*!
 *  @abstract Wait with a timeout (seconds) for condition variable.
 *
 *  @return completion code.
 */
int Thread_wait_cond(cond_type_struct* condvar, int timeout);

/*!
 *  @abstract Destroy a condition variable.
 *
 *  @return completion code.
 */
int Thread_destroy_cond(cond_type_struct*);

/*!
 *  @abstract Start a new thread.
 *
 *  @param fn The function to run, must be of the correct signature.
 *  @param parameter Pointer to the function parameter, can be NULL.
 *  @return The new thread.
 */
pthread_t Thread_start(thread_fn, void*);

/*!
 *  @abstract Get the thread id of the thread from which this function is called
 *
 *  @return thread id, type varying according to OS
 */
pthread_t Thread_getid();
