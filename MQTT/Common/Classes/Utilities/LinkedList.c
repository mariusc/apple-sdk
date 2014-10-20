#include "LinkedList.h" // Header
#include <string.h>     // C Standard
#include <memory.h>
#include "Heap.h"       // MQTT (Utilities)

#pragma mark - Private prototypes

int ListUnlink(List* restrict list, void const* content, ListCallback callback, int const freeContent);

#pragma mark - Public API

void ListZero(List* restrict list)
{
	memset(list, '\0', sizeof(List));
}

List* ListInitialize(void)
{
	List* list = malloc(sizeof(List));
	ListZero(list);
	return list;
}

void ListAppend(List* restrict list, void const* restrict content, size_t const size)
{
    ListElement* element = malloc(sizeof(ListElement));
    ListAppendNoMalloc(list, content, element, size);
}

void ListAppendNoMalloc(List* restrict list, void const* restrict content, ListElement* restrict element, size_t const size)
{   // For heap use
	element->content = (void*)content;
	element->next = NULL;
	element->prev = list->last;
    
    if (list->first == NULL) {
		list->first = element;
    } else {
		list->last->next = element;
    }
    
	list->last = element;
	++(list->count);
	list->size += size;
}

void ListInsert(List* restrict list, void const* restrict content, size_t const size, ListElement* restrict index)
{
	ListElement* element = malloc(sizeof(ListElement));

    if ( index == NULL )
    {
		ListAppendNoMalloc(list, content, element, size);
    }
    else
	{
		element->content = (void*)content;
		element->next = index;
		element->prev = index->prev;

		index->prev = element;
        if ( element->prev != NULL ) {
			element->prev->next = element;
        } else {
			list->first = element;
        }
        
		++(list->count);
		list->size += size;
	}
}

int ListRemove(List* restrict list, void const* content)
{
    return ListUnlink(list, content, NULL, 1);
}

int ListRemoveItem(List* restrict list, void const* content, ListCallback callback)
{   // Remove from list and free the content
    return ListUnlink(list, content, callback, 1);
}

int ListRemoveHead(List* restrict list)
{
    free(ListDetachHead(list));
    return 0;
}

void* ListPopTail(List* restrict list)
{
    if (list->count <= 0) { return NULL; }
    
    void* content = NULL;
    ListElement* last = list->last;
    if (list->current == last) { list->current = last->prev; }
    
    // i.e. Number of items in list == 1
    if (list->first == last) { list->first = NULL; }
    content = last->content;
    list->last = list->last->prev;
    if (list->last) { list->last->next = NULL; }
    free(last);
    --(list->count);
    return content;
}

int ListDetach(List* restrict list, void const* content)
{
    return ListUnlink(list, content, NULL, 0);
}

int ListDetachItem(List* restrict list, void const* content, ListCallback callback)
{   // Do not free the content.
    return ListUnlink(list, content, callback, 0);
}

void* ListDetachHead(List* restrict list)
{
    if (list->count <= 0) { return NULL; }
    
    void* content = NULL;
    
    ListElement* first = list->first;
    if (list->current == first) { list->current = first->next; }
    
    // i.e. no of items in list == 1
    if (list->last == first) { list->last = NULL; }
    
    content = first->content;
    list->first = list->first->next;
    if (list->first) { list->first->prev = NULL; }
    free(first);
    --(list->count);
    
    return content;
}

ListElement* ListFind(List* restrict list, void const* content)
{
    return ListFindItem(list, content, NULL);
}

ListElement* ListFindItem(List* restrict list, void const* content, ListCallback callback)
{
	ListElement* rc = NULL;

    if (list->current != NULL && ((callback == NULL && list->current->content == content) || (callback != NULL && callback(list->current->content, content))))
    {
		rc = list->current;
    }
    else
	{
		ListElement* current = NULL;

		/* find the content */
		while (ListNextElement(list, &current) != NULL)
		{
			if (callback == NULL)
			{
				if (current->content == content)
				{
					rc = current;
					break;
				}
			}
			else
			{
				if (callback(current->content, content))
				{
					rc = current;
					break;
				}
			}
		}
        if (rc != NULL) { list->current = rc; }
	}
	return rc;
}

ListElement* ListNextElement(List* restrict list, ListElement** pos)
{
    return *pos = (*pos == NULL) ? list->first : (*pos)->next;
}

ListElement* ListPrevElement(List* restrict list, ListElement** pos)
{
    return *pos = (*pos == NULL) ? list->last : (*pos)->prev;
}

void ListEmpty(List* restrict list)
{
    while (list->first != NULL)
    {
        ListElement* first = list->first;
        if (first->content != NULL) { free(first->content); }
        list->first = first->next;
        free(first);
    }
    list->count = list->size = 0;
    list->current = list->first = list->last = NULL;
}

void ListFree(List* restrict list)
{
    ListEmpty(list);
    free(list);
}

void ListFreeNoContent(List* restrict list)
{
    while (list->first != NULL)
    {
        ListElement* first = list->first;
        list->first = first->next;
        free(first);
    }
    free(list);
}

#pragma mark Comparison functions

bool intcompare(void const* a, void const* b)
{
    return (*((int const*)a) == *((int const*)b)) ? true : false;
}

bool stringcompare(void const* a, void const* b)
{
    return (strcmp((char const*)a, (char const*)b) == 0) ? true : false;
}

#pragma mark - Private functionality

/*!
 *  @abstract Removes and optionally frees an element in a list by comparing the content.
 *  @discussion A callback function is used to define the method of comparison for each element.
 *
 *  @param list The list in which the search is to be conducted.
 *  @param content Pointer to the content to look for.
 *  @param callback Pointer to a function which compares each element.
 *  @param freeContent Boolean value to indicate whether the item found is to be freed.
 *  @return 1=item removed, 0=item not removed.
 */
int ListUnlink(List* restrict list, void const* content, ListCallback callback, int const freeContent)
{
	ListElement* next = NULL;
	ListElement* saved = list->current;
	int saveddeleted = 0;

    if ( !ListFindItem(list, content, callback) ) { return 0; }

	if (list->current->prev == NULL)
    {   // This is the first element, and we have to update the "first" pointer.
		list->first = list->current->next;
    } else {
		list->current->prev->next = list->current->next;
    }

    if (list->current->next == NULL) {
		list->last = list->current->prev;
    } else {
		list->current->next->prev = list->current->prev;
    }

	next = list->current->next;
    if (freeContent) { free(list->current->content); }
    if (saved == list->current) { saveddeleted = 1; }
	free(list->current);
    if (saveddeleted) {
		list->current = next;
    } else {
		list->current = saved;
    }
	--(list->count);
	return 1; /* successfully removed item */
}
