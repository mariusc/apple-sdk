#pragma once

#include <pthread.h>        // POSIX
#include <semaphore.h>      // POSIX

#pragma mark Definitions

#define thread_type pthread_t

#define thread_id_type pthread_t

#define thread_return_type void*

typedef thread_return_type (*thread_fn)(void*);

#define mutex_type pthread_mutex_t*

typedef struct {
    pthread_cond_t cond;
    pthread_mutex_t mutex;
} cond_type_struct;

typedef cond_type_struct *cond_type;

typedef sem_t *sem_type;

#pragma mark Public API

/*!
 *  @abstract Create a new mutex
 *
 *  @return the new mutex
 */
mutex_type Thread_create_mutex();

/*!
 *  @abstract Lock a mutex which has already been created, block until ready
 *
 *  @param mutex the mutex
 *  @return completion code, 0 is success
 */
int Thread_lock_mutex(mutex_type);

/*!
 *  @abstract Unlock a mutex which has already been locked
 *
 *  @param mutex the mutex
 *  @return completion code, 0 is success
 */
int Thread_unlock_mutex(mutex_type);

/*!
 *  @abstract Destroy a mutex which has already been created
 *
 * @param mutex the mutex
 */
void Thread_destroy_mutex(mutex_type);

/*!
 *  @abstract Create a new semaphore
 *
 * @return the new condition variable
 */
sem_type Thread_create_sem();

/*!
 *  @abstract Wait for a semaphore to be posted, or timeout.
 *
 *  @param sem The semaphore.
 *  @param timeout The maximum time to wait, in milliseconds.
 *  @return Completion code.
 */
int Thread_wait_sem(sem_type sem, int timeout);

/*!
 *  @abstract Check to see if a semaphore has been posted, without waiting.
 *
 *  @param sem the semaphore
 *  @return 0 (false) or 1 (true)
 */
int Thread_check_sem(sem_type sem);

/*!
 *  @abstract Post a semaphore
 *
 *  @param sem the semaphore
 *  @return completion code
 */
int Thread_post_sem(sem_type sem);

/*!
 *  @abstract Destroy a semaphore which has already been created
 *
 *  @param sem the semaphore
 */
int Thread_destroy_sem(sem_type sem);

/*!
 *  @abstract Create a new condition variable
 *
 *  @return the condition variable struct
 */
cond_type Thread_create_cond();

/*!
 *  @abstract Signal a condition variable
 *
 *  @return completion code
 */
int Thread_signal_cond(cond_type);

/*!
 *  @abstract Wait with a timeout (seconds) for condition variable
 *
 *  @return completion code
 */
int Thread_wait_cond(cond_type condvar, int timeout);

/*!
 *  @abstract Destroy a condition variable
 *
 *  @return completion code
 */
int Thread_destroy_cond(cond_type);

/*!
 *  @abstract Start a new thread.
 *
 *  @param fn The function to run, must be of the correct signature.
 *  @param parameter Pointer to the function parameter, can be NULL.
 *  @return The new thread.
 */
thread_type Thread_start(thread_fn, void*);

/*!
 *  @abstract Get the thread id of the thread from which this function is called
 *
 *  @return thread id, type varying according to OS
 */
thread_id_type Thread_getid();
