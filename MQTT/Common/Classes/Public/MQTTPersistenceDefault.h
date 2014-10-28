/**
 *  @abstract A file system based persistence implementation.
 *  @discussion A directory is specified when the MQTT client is created. When the persistence is then opened (@link Persistence_open @\link), a sub-directory is made beneath the base for this particular client ID and connection key. This allows one persistence base directory to be shared by multiple clients.
 */
#pragma once

#pragma mark Definitions

/** 8.3 filesystem */
#define MESSAGE_FILENAME_LENGTH 8    
/** Extension of the filename */
#define MESSAGE_FILENAME_EXTENSION ".msg"

#pragma mark Public API

/*!
 *  @abstract Create persistence directory for the client: context/clientID-serverURI.
 */
int pstopen(void** handle, const char* clientID, const char* serverURI, void* context);

/*!
 *  @abstract Write wire message to the client persistence directory.
 */
int pstput(void* handle, char* key, int bufcount, char* buffers[], int buflens[]);

/*!
 *  @abstract Retrieve a wire message from the client persistence directory.
 */
int pstget(void* handle, char* key, char** buffer, int* buflen);

/*!
 *  @abstract Delete a persisted message from the client persistence directory.
 */
int pstremove(void* handle, char* key);

/*!
 *  Returns the keys (file names w/o the extension) in the client persistence directory.
 */
int pstkeys(void* handle, char*** keys, int* nkeys);

/*!
 *  @abstract Returns whether if a wire message is persisted in the client persistence directory.
 */
int pstcontainskey(void* handle, char* key);

/*!
 *  @abstract Delete all the persisted message in the client persistence directory.
 */
int pstclear(void* handle);

/*!
 *  @abstract Delete client persistence directory (if empty).
 */
int pstclose(void* handle);

/*!
 *  @abstract Function to create a directory.
 *  @return Returns 0 on success or if the directory already exists.
 */
int pstmkdir(char *pPathname);
