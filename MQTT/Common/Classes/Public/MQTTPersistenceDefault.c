#if !defined(NO_PERSISTENCE)

#include <stdio.h>      // C Standard
#include <string.h>     // C Standard
#include <errno.h>      // C Standard

#include <sys/stat.h>   // POSIX
#include <dirent.h>
#include <unistd.h>

#include "MQTTClientPersistence.h"      // MQTT (Public)
#include "MQTTPersistenceDefault.h"     // MQTT (Public)
#include "StackTrace.h"                 // MQTT (Utilities)
#include "Heap.h"                       // MQTT (Utilities)

#pragma mark - Private prototypes

int keysUnix(char *, char ***, int *);
int clearUnix(char *);
int containskeyUnix(char *, char *);

#pragma mark - Public API

int pstopen(void **handle, const char* clientID, const char* serverURI, void* context)
{
    int rc = 0;
    char *dataDir = context;
    char *clientDir;
    char *pToken = NULL;
    char *save_ptr = NULL;
    char *pCrtDirName = NULL;
    char *pTokDirName = NULL;
    char *perserverURI = NULL, *ptraux;
    
    FUNC_ENTRY;
    /* Note that serverURI=address:port, but ":" not allowed in Windows directories */
    perserverURI = malloc(strlen(serverURI) + 1);
    strcpy(perserverURI, serverURI);
    ptraux = strstr(perserverURI, ":");
    *ptraux = '-' ;
    
    /* consider '/'  +  '-'  +  '\0' */
    clientDir = malloc(strlen(dataDir) + strlen(clientID) + strlen(perserverURI) + 3);
    sprintf(clientDir, "%s/%s-%s", dataDir, clientID, perserverURI);
    
    
    /* create clientDir directory */
    
    /* pCrtDirName - holds the directory name we are currently trying to create.           */
    /*               This gets built up level by level until the full path name is created.*/
    /* pTokDirName - holds the directory name that gets used by strtok.         */
    pCrtDirName = (char*)malloc( strlen(clientDir) + 1 );
    pTokDirName = (char*)malloc( strlen(clientDir) + 1 );
    strcpy( pTokDirName, clientDir );
    
    pToken = strtok_r( pTokDirName, "\\/", &save_ptr );
    
    strcpy( pCrtDirName, pToken );
    rc = pstmkdir( pCrtDirName );
    pToken = strtok_r( NULL, "\\/", &save_ptr );
    while ( (pToken != NULL) && (rc == 0) )
    {
        /* Append the next directory level and try to create it */
        sprintf( pCrtDirName, "%s/%s", pCrtDirName, pToken );
        rc = pstmkdir( pCrtDirName );
        pToken = strtok_r( NULL, "\\/", &save_ptr );
    }
    
    *handle = clientDir;
    
    free(perserverURI);
    free(pTokDirName);
    free(pCrtDirName);
    
    FUNC_EXIT_RC(rc);
    return rc;
}

int pstput(void* handle, char* key, int bufcount, char* buffers[], int buflens[])
{
    int rc = 0;
    char *clientDir = handle;
    char *file;
    FILE *fp;
    int bytesWritten = 0;
    int bytesTotal = 0;
    int i;
    
    FUNC_ENTRY;
    if (clientDir == NULL)
    {
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
        goto exit;
    }
    
    /* consider '/' + '\0' */
    file = malloc(strlen(clientDir) + strlen(key) + strlen(MESSAGE_FILENAME_EXTENSION) + 2 );
    sprintf(file, "%s/%s%s", clientDir, key, MESSAGE_FILENAME_EXTENSION);
    
    fp = fopen(file, "wb");
    if ( fp != NULL )
    {
        for(i=0; i<bufcount; i++)
        {
            bytesTotal += buflens[i];
            bytesWritten += fwrite( buffers[i], sizeof(char), buflens[i], fp );
        }
        fclose(fp);
        fp = NULL;
    } else
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
    
    if ( bytesWritten != bytesTotal )
    {
        pstremove(handle, key);
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
    }
    
    free(file);
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
};

int pstget(void* handle, char* key, char** buffer, int* buflen)
{
    int rc = 0;
    FILE *fp;
    char *clientDir = handle;
    char *file;
    char *buf;
    unsigned long fileLen = 0;
    unsigned long bytesRead = 0;
    
    FUNC_ENTRY;
    if (clientDir == NULL)
    {
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
        goto exit;
    }
    
    /* consider '/' + '\0' */
    file = malloc(strlen(clientDir) + strlen(key) + strlen(MESSAGE_FILENAME_EXTENSION) + 2);
    sprintf(file, "%s/%s%s", clientDir, key, MESSAGE_FILENAME_EXTENSION);
    
    fp = fopen(file, "rb");
    if ( fp != NULL )
    {
        fseek(fp, 0, SEEK_END);
        fileLen = ftell(fp);
        fseek(fp, 0, SEEK_SET);
        buf=(char *)malloc(fileLen);
        bytesRead = fread(buf, sizeof(char), fileLen, fp);
        *buffer = buf;
        *buflen = bytesRead;
        if ( bytesRead != fileLen )
            rc = MQTTCLIENT_PERSISTENCE_ERROR;
        fclose(fp);
        fp = NULL;
    } else
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
    
    free(file);
    /* the caller must free buf */
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int pstremove(void* handle, char* key)
{
    int rc = 0;
    char *clientDir = handle;
    char *file;
    
    FUNC_ENTRY;
    if (clientDir == NULL)
    {
        return rc = MQTTCLIENT_PERSISTENCE_ERROR;
        goto exit;
    }
    
    /* consider '/' + '\0' */
    file = malloc(strlen(clientDir) + strlen(key) + strlen(MESSAGE_FILENAME_EXTENSION) + 2);
    sprintf(file, "%s/%s%s", clientDir, key, MESSAGE_FILENAME_EXTENSION);
    
    if ( unlink(file) != 0 )
    {
        if ( errno != ENOENT )
            rc = MQTTCLIENT_PERSISTENCE_ERROR;
    }
    
    free(file);
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int pstkeys(void *handle, char ***keys, int *nkeys)
{
    int rc = 0;
    char *clientDir = handle;
    
    FUNC_ENTRY;
    if (clientDir == NULL)
    {
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
        goto exit;
    }
    
    rc = keysUnix(clientDir, keys, nkeys);
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int pstcontainskey(void *handle, char *key)
{
    int rc = 0;
    char *clientDir = handle;
    
    FUNC_ENTRY;
    if (clientDir == NULL)
    {
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
        goto exit;
    }
    
    rc = containskeyUnix(clientDir, key);
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int pstclear(void *handle)
{
    int rc = 0;
    char *clientDir = handle;
    
    FUNC_ENTRY;
    if (clientDir == NULL)
    {
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
        goto exit;
    }
    
    rc = clearUnix(clientDir);
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int pstclose(void* handle)
{
    int rc = 0;
    char *clientDir = handle;
    
    FUNC_ENTRY;
    if (clientDir == NULL)
    {
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
        goto exit;
    }
    
    if ( rmdir(clientDir) != 0 )
    {
        if ( errno != ENOENT && errno != ENOTEMPTY )
            rc = MQTTCLIENT_PERSISTENCE_ERROR;
    }
    
    free(clientDir);
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int pstmkdir( char *pPathname )
{
    int rc = 0;
    
    FUNC_ENTRY;
    /* Create a directory with read, write and execute access for the owner and read access for the group */
    if ( mkdir( pPathname, S_IRWXU | S_IRGRP ) != 0 )
    {
        if ( errno != EEXIST )
            rc = MQTTCLIENT_PERSISTENCE_ERROR;
    }
    
    FUNC_EXIT_RC(rc);
    return rc;
}

#pragma mark - Private functionality

int keysUnix(char *dirname, char ***keys, int *nkeys)
{
    int rc = 0;
    char **fkeys = NULL;
    int nfkeys = 0;
    char *ptraux;
    int i;
    DIR *dp;
    struct dirent *dir_entry;
    struct stat stat_info;
    
    FUNC_ENTRY;
    /* get number of keys */
    if((dp = opendir(dirname)) != NULL)
    {
        while((dir_entry = readdir(dp)) != NULL)
        {
            char* temp = malloc(strlen(dirname)+strlen(dir_entry->d_name)+2);
            
            sprintf(temp, "%s/%s", dirname, dir_entry->d_name);
            if (lstat(temp, &stat_info) == 0 && S_ISREG(stat_info.st_mode))
                nfkeys++;
            free(temp);
        }
        closedir(dp);
    } else
    {
        rc = MQTTCLIENT_PERSISTENCE_ERROR;
        goto exit;
    }
    
    if (nfkeys != 0)
    {
        fkeys = (char **)malloc(nfkeys * sizeof(char *));
        
        /* copy the keys */
        if((dp = opendir(dirname)) != NULL)
        {
            i = 0;
            while((dir_entry = readdir(dp)) != NULL)
            {
                char* temp = malloc(strlen(dirname)+strlen(dir_entry->d_name)+2);
                
                sprintf(temp, "%s/%s", dirname, dir_entry->d_name);
                if (lstat(temp, &stat_info) == 0 && S_ISREG(stat_info.st_mode))
                {
                    fkeys[i] = malloc(strlen(dir_entry->d_name) + 1);
                    strcpy(fkeys[i], dir_entry->d_name);
                    ptraux = strstr(fkeys[i], MESSAGE_FILENAME_EXTENSION);
                    if ( ptraux != NULL )
                        *ptraux = '\0' ;
                    i++;
                }
                free(temp);
            }
            closedir(dp);
        } else
        {
            rc = MQTTCLIENT_PERSISTENCE_ERROR;
            goto exit;
        }
    }
    
    *nkeys = nfkeys;
    *keys = fkeys;
    /* the caller must free keys */
    
exit:
    FUNC_EXIT_RC(rc);
    return rc;
}

int clearUnix(char *dirname)
{
	int rc = 0;
	DIR *dp;
	struct dirent *dir_entry;
	struct stat stat_info;

	FUNC_ENTRY;
	if((dp = opendir(dirname)) != NULL)
	{
		while((dir_entry = readdir(dp)) != NULL && rc == 0)
		{
			lstat(dir_entry->d_name, &stat_info);
			if(S_ISREG(stat_info.st_mode))
			{
				if ( remove(dir_entry->d_name) != 0 )
					rc = MQTTCLIENT_PERSISTENCE_ERROR;
			}
		}
		closedir(dp);
	} else
		rc = MQTTCLIENT_PERSISTENCE_ERROR;

	FUNC_EXIT_RC(rc);
	return rc;
}

int containskeyUnix(char *dirname, char *key)
{
    int notFound = MQTTCLIENT_PERSISTENCE_ERROR;
    char *filekey, *ptraux;
    DIR *dp;
    struct dirent *dir_entry;
    struct stat stat_info;
    
    FUNC_ENTRY;
    if((dp = opendir(dirname)) != NULL)
    {
        while((dir_entry = readdir(dp)) != NULL && notFound)
        {
            char* filename = malloc(strlen(dirname) + strlen(dir_entry->d_name) + 2);
            sprintf(filename, "%s/%s", dirname, dir_entry->d_name);
            lstat(filename, &stat_info);
            free(filename);
            if(S_ISREG(stat_info.st_mode))
            {
                filekey = malloc(strlen(dir_entry->d_name) + 1);
                strcpy(filekey, dir_entry->d_name);
                ptraux = strstr(filekey, MESSAGE_FILENAME_EXTENSION);
                if ( ptraux != NULL )
                    *ptraux = '\0' ;
                if(strcmp(filekey, key) == 0)
                    notFound = 0;
                free(filekey);
            }
        }
        closedir(dp);
    }
    
    FUNC_EXIT_RC(notFound);
    return notFound;
}

#endif // NO_PERSISTENCE
