#include "Clients.h"    // Header
#include <string.h>     // C Standard
#include <stdio.h>      // C Standard

#pragma mark - Public API

bool clientIDCompare(void const* a, void const* b)
{
	Clients* client = (Clients*)a;
    return (strcmp(client->clientID, (char*)b) == 0) ? true : false;
}

bool clientSocketCompare(void const* a, void const* b)
{
	Clients* client = (Clients*)a;
    return (client->net.socket == *(int*)b) ? true : false;
}
