#pragma once

#include <pthread.h>
#include <semaphore.h>
#define thread_type pthread_t
#define thread_id_type pthread_t
#define thread_return_type void*
typedef thread_return_type (*thread_fn)(void*);
#define mutex_type pthread_mutex_t*
typedef struct { pthread_cond_t cond; pthread_mutex_t mutex; } cond_type_struct;
typedef cond_type_struct *cond_type;
typedef sem_t *sem_type;

cond_type Thread_create_cond();
int Thread_signal_cond(cond_type);
int Thread_wait_cond(cond_type condvar, int timeout);
int Thread_destroy_cond(cond_type);

thread_type Thread_start(thread_fn, void*);

mutex_type Thread_create_mutex();
int Thread_lock_mutex(mutex_type);
int Thread_unlock_mutex(mutex_type);
void Thread_destroy_mutex(mutex_type);

thread_id_type Thread_getid();

sem_type Thread_create_sem();
int Thread_wait_sem(sem_type sem, int timeout);
int Thread_check_sem(sem_type sem);
int Thread_post_sem(sem_type sem);
int Thread_destroy_sem(sem_type sem);
