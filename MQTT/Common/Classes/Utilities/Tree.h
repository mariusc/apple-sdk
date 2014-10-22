/*!
 *  @abstract Functions which apply to tree structures.
 *  @discussion These trees can hold data of any sort, pointed to by the content pointer of the Node structure.
 */
#pragma once

#include <stdlib.h>     // C Standard

/*!
 *  @abstract Structure to hold all data for one list element
 *
 *  @field parent Pointer to parent tree node, in case we need it
 *  @field child Pointer to child tree nodes (0 = left, 1 = right)
 *  @field content Pointer to element content.
 *  @field size Size of content.
 */
typedef struct NodeStruct
{
    struct NodeStruct* parent;
    struct NodeStruct* child[2];
	void* content;
	size_t size;
	unsigned int red : 1;
} Node;

/*!
 *  @abstract Structure to hold all data for one tree
 *
 *  @field index <#description#>
 *  @field indexes Number of indexes into tree.
 *  @field count Number of iterms.
 *  @field size Heap storage used.
 *  @field heap_tracking Switch on heap tracking for this tree.
 *  @field allow_duplicates Switch to allow duplicate entries.
 */
typedef struct
{
	struct
	{
		Node* root;                         // Root node pointer.
		int (*compare)(void*, void*, int);  // Comparison function.
	} index[2];
    
    int indexes;
    int count;
    size_t size;
	unsigned int heap_tracking : 1;
	unsigned int allow_duplicates : 1;
} Tree;

/*!
 *  @abstract Allocates and initializes a new tree structure.
 *
 *  @return a pointer to the new tree structure.
 */
Tree* TreeInitialize(int(*compare)(void*, void*, int));

void TreeInitializeNoMalloc(Tree* aTree, int(*compare)(void*, void*, int));

void TreeAddIndex(Tree* aTree, int(*compare)(void*, void*, int));

void* TreeAdd(Tree* aTree, void* content, size_t size);

void* TreeRemove(Tree* aTree, void* content);

void* TreeRemoveKey(Tree* aTree, void* key);

void* TreeRemoveKeyIndex(Tree* aTree, void* key, int index);

/*!
 *  @abstract Remove an item from a tree.
 *
 *  @param aTree the list to which the item is to be added.
 *  @param curnode the list item content itself.
 */
void* TreeRemoveNodeIndex(Tree* aTree, Node* aNode, int index);

void TreeFree(Tree* aTree);

Node* TreeFind(Tree* aTree, void* key);
Node* TreeFindIndex(Tree* aTree, void* key, int index);

Node* TreeNextElement(Tree* aTree, Node* curnode);

#pragma mark Comparison functions

int TreeIntCompare(void* a, void* b, int);
int TreePtrCompare(void* a, void* b, int);
int TreeStringCompare(void* a, void* b, int);
