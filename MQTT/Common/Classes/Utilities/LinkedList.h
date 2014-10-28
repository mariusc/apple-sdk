/*!
 *  @abstract Functions which apply to linked list structures.
 *  @discussion These linked lists can hold data of any sort, pointerd to by the content pointer of the ListElement structure. <code>ListElement</code>s hold the pointers to the next and previous items in the list.
 */
#pragma once

#include <stdlib.h>     // C Standard
#include <stdbool.h>    // C Standard

#pragma mark Variables

/*!
 *  @abstract Structure to hold all data for one list element.
 *
 *  @field prev Pointer to previous list element.
 *  @field next Pointer to next list element.
 *  @field content Pointer to element content.
 */
typedef struct ListElementStruct
{
    struct ListElementStruct* prev;
    struct ListElementStruct* next;
    void* content;
} ListElement;


/*!
 *  @abstract Structure to hold all data for one list.
 *
 *  @field first First element in the list.
 *  @field last Last element in the list.
 *  @field current Current element in the list, for iteration.
 *  @field count Number of items.
 *  @field size Heap storage used.
 */
typedef struct
{
    ListElement* first;
    ListElement* last;
    ListElement* current;
    int count;
    size_t size;
} List;

#pragma mark Comparison functions

/*!
 *  @abstract Callback to be used in several Linked List functions.
 *  @return Boolean indicating whether the operation was successful (<code>true</code>) or not (<code>false</false>).
 */
typedef bool(*ListCallback)(void const* a, void const* b);

/*!
 *  @abstract List callback function for comparing integers
 *
 *  @param a First integer value
 *  @param b Second integer value
 *  @return Boolean indicating whether a and b are equal
 */
bool intcompare(void const* a, void const* b);

/*!
 *  @abstract List callback function for comparing C strings
 *
 *  @param a first integer value
 *  @param b second integer value
 *  @return boolean indicating whether a and b are equal
 */
bool stringcompare(void const* a, void const* b);

#pragma mark Public API

/*!
 *  @abstract Sets a list structure to empty - all null values.
 *  @discussion It does not remove any items from the list.
 *
 *  @param list A pointer to the list structure to be initialized.
 */
void ListZero(List* restrict list);

/*!
 *  @abstract Allocates and initializes a new list structure.
 *
 *  @return A pointer to the new list structure.
 */
List* ListInitialize(void)
    __attribute__((malloc));

/*!
 *  @abstract Append an item to a list.
 *
 *  @param list The list to which the item is to be added
 *  @param content The list item content itself
 *  @param size The size of the element
 */
void ListAppend(List* restrict list, void const* restrict content, size_t const size);

/*!
 *  @abstract Append an already allocated ListElement and content to a list. Can be used to move an item from one list to another.
 *
 *  @param list The list to which the item is to be added
 *  @param content The list item content itself
 *  @param element The ListElement to be used in adding the new item
 *  @param size The size of the element
 */
void ListAppendNoMalloc(List* restrict list, void const* restrict content, ListElement* restrict element, size_t const size);

/*!
 *  @abstract Insert an item to a list at a specific position.
 *
 *  @param list The list to which the item is to be added.
 *  @param content The list item content itself.
 *  @param size The size of the element.
 *  @param index The position in the list. If <code>NULL</code>, this function is equivalent to ListAppend.
 */
void ListInsert(List* restrict list, void const* restrict content, size_t const size, ListElement* restrict index);

/*!
 *  @abstract Removes and frees an item in a list by comparing the pointer to the content.
 *  @param list The list from which the item is to be removed
 *  @param content Pointer to the content to look for
 *  @return 1=item removed, 0=item not removed
 */
int ListRemove(List* restrict list, void const* content);

/*!
 *  @abstract Removes and frees an element in a list by comparing the content.
 *  @discussion A callback function is used to define the method of comparison for each element
 *
 *  @param list The list in which the search is to be conducted
 *  @param content Pointer to the content to look for
 *  @param callback Pointer to a function which compares each element
 *  @return 1=item removed, 0=item not removed
 */
int ListRemoveItem(List* restrict list, void const* content, ListCallback callback);

/*!
 *  @abstract Removes and frees an the first item in a list.
 *  @param aList the list from which the item is to be removed
 *  @return 1=item removed, 0=item not removed
 */
int ListRemoveHead(List* restrict list);

/*!
 *  @abstract Removes but does not free the last item in a list.
 *  @param list The list from which the item is to be removed
 *  @return The last item removed (or NULL if none was)
 */
void* ListPopTail(List* restrict list);

/*!
 *  @abstract Removes but does not free an item in a list by comparing the pointer to the content.
 *  @param list The list in which the search is to be conducted
 *  @param content Pointer to the content to look for
 *  @return 1=item removed, 0=item not removed
 */
int ListDetach(List* restrict list, void const* content);

/*!
 *  @abstract Removes but does not free an element in a list by comparing the content.
 *  @discussion A callback function is used to define the method of comparison for each element.
 *
 *  @param list The list in which the search is to be conducted.
 *  @param content Pointer to the content to look for.
 *  @param callback Pointer to a function which compares each element.
 *  @return 1=item removed, 0=item not removed
 */
int ListDetachItem(List* restrict list, void const* content, ListCallback callback);

/*!
 * @abstract Removes and frees an the first item in a list.
 * @param list The list from which the item is to be removed.
 * @return 1=item removed, 0=item not removed.
 */
void* ListDetachHead(List* restrict list);

/*!
 *  @abstract Finds an element in a list by comparing the content pointers, rather than the contents.
 *
 *  @param aList the list in which the search is to be conducted
 *  @param content pointer to the list item content itself
 *  @return the list item found, or NULL
 */
ListElement* ListFind(List* restrict list, void const* content);

/*!
 *  @abstract Finds an element in a list by comparing the content or pointer to the content.  A callback function is used to define the method of comparison for each element.
 *
 *  @param list The list in which the search is to be conducted
 *  @param content Pointer to the content to look for
 *  @param callback Pointer to a function which compares each element (NULL means compare by content pointer)
 *  @return The list element found, or NULL.
 */
ListElement* ListFindItem(List* restrict list, void const* content, ListCallback callback);

/*!
 *  @abstract Forward iteration through a list.
 *  @discussion This is updated on return to the same value as that returned from this function.
 *
 *  @param list The list to which the operation is to be applied.
 *  @param pos Pointer to the current position in the list. <code>NULL</code> means start from the beginning of the list.
 *  @return Pointer to the current list element.
 */
ListElement* ListNextElement(List* restrict list, ListElement** pos);

/*!
 *  @abstract Backward iteration through a list
 *  @discussion This is updated on return to the same value as that returned from this function.
 *
 *  @param aList the list to which the operation is to be applied
 *  @param pos pointer to the current position in the list.  NULL means start from the end of the list
 *  @return pointer to the current list element
 */
ListElement* ListPrevElement(List* restrict list, ListElement** pos);

/*!
 *  @abstract Removes and frees all items in a list, leaving the list ready for new items.
 *
 *  @param list The list to which the operation is to be applied
 */
void ListEmpty(List* restrict list);

/*!
 *  @abstract Removes and frees all items in a list, and frees the list itself
 *
 *  @param list the list to which the operation is to be applied
 */
void ListFree(List* restrict list);

/*!
 *  @abstract Removes and but does not free all items in a list, and frees the list itself
 *
 *  @param list The list to which the operation is to be applied
 */
void ListFreeNoContent(List* restrict list);
