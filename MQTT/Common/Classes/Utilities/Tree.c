#define NO_HEAP_TRACKING 1

#include "Tree.h"       // Header
#include <stdio.h>      // C Standard
#include <string.h>     // C Standard
#include <memory.h>     // C Standard
#include "Heap.h"       // MQTT (Utilities)

#pragma mark - Definitions

#define LEFT 0
#define RIGHT 1
#if !defined(max)
    #define max(a, b) (a > b) ? a : b;
#endif

#pragma mark - Private prototypes

int isRed(Node* aNode);
int isBlack(Node* aNode);
int TreeWalk(Node* curnode, int depth);
int TreeMaxDepth(Tree *aTree);
void TreeRotate(Tree* aTree, Node* curnode, int direction, int index);
Node* TreeBAASub(Tree* aTree, Node* curnode, int which, int index);
void TreeBalanceAfterAdd(Tree* aTree, Node* curnode, int index);
void* TreeAddByIndex(Tree* aTree, void* content, size_t size, int index);
Node* TreeFindIndex1(Tree* aTree, void* key, int index, int value);
Node* TreeFindContentIndex(Tree* aTree, void* key, int index);
Node* TreeMinimum(Node* curnode);
Node* TreeSuccessor(Node* curnode);
Node* TreeNextElementIndex(Tree* aTree, Node* curnode, int index);
Node* TreeBARSub(Tree* aTree, Node* curnode, int which, int index);
void TreeBalanceAfterRemove(Tree* aTree, Node* curnode, int index);
void* TreeRemoveIndex(Tree* aTree, void* content, int index);

#pragma mark - Public APIs

Tree* TreeInitialize(int(*compare)(void*, void*, int))
{
    Tree* newt = mymalloc(__FILE__, __LINE__, sizeof(Tree));
    TreeInitializeNoMalloc(newt, compare);
    return newt;
}

void TreeInitializeNoMalloc(Tree* aTree, int(*compare)(void*, void*, int))
{
    memset(aTree, '\0', sizeof(Tree));
    aTree->heap_tracking = 1;
    aTree->index[0].compare = compare;
    aTree->indexes = 1;
}

void TreeAddIndex(Tree* aTree, int(*compare)(void*, void*, int))
{
    aTree->index[aTree->indexes].compare = compare;
    ++(aTree->indexes);
}

void* TreeAdd(Tree* aTree, void* content, size_t size)
{
    void* rc = NULL;
    for (int i = 0; i < aTree->indexes; ++i) { rc = TreeAddByIndex(aTree, content, size, i); }
    return rc;
}

void* TreeRemoveNodeIndex(Tree* aTree, Node* curnode, int index)
{
    Node* redundant = curnode;
    Node* curchild = NULL;
    size_t size = curnode->size;
    void* content = curnode->content;
    
    /* if the node to remove has 0 or 1 children, it can be removed without involving another node */
    if (curnode->child[LEFT] && curnode->child[RIGHT]) /* 2 children */
    { redundant = TreeSuccessor(curnode); } 	/* now redundant must have at most one child */
    
    curchild = redundant->child[(redundant->child[LEFT] != NULL) ? LEFT : RIGHT];
    if (curchild) /* we could have no children at all */
        curchild->parent = redundant->parent;
    
    if (redundant->parent == NULL)
        aTree->index[index].root = curchild;
    else
    {
        if (redundant == redundant->parent->child[LEFT])
            redundant->parent->child[LEFT] = curchild;
        else
            redundant->parent->child[RIGHT] = curchild;
    }
    
    if (redundant != curnode)
    {
        curnode->content = redundant->content;
        curnode->size = redundant->size;
    }
    
    if (isBlack(redundant))
    {
        if (curchild == NULL)
        {
            if (redundant->parent)
            {
                Node temp;
                memset(&temp, '\0', sizeof(Node));
                temp.parent = (redundant) ? redundant->parent : NULL;
                temp.red = 0;
                TreeBalanceAfterRemove(aTree, &temp, index);
            }
        }
        else
            TreeBalanceAfterRemove(aTree, curchild, index);
    }
    
    (aTree->heap_tracking) ? myfree(__FILE__, __LINE__, redundant) : free(redundant);
    if (index == 0)
    {
        aTree->size -= size;
        --(aTree->count);
    }
    return content;
}

void* TreeRemove(Tree* aTree, void* content)
{
    int i;
    void* rc = NULL;
    
    for (i = 0; i < aTree->indexes; ++i)
        rc = TreeRemoveIndex(aTree, content, i);
    
    return rc;
}

void* TreeRemoveKey(Tree* aTree, void* key)
{
    return TreeRemoveKeyIndex(aTree, key, 0);
}

void* TreeRemoveKeyIndex(Tree* aTree, void* key, int index)
{
    Node* curnode = TreeFindIndex(aTree, key, index);
    void* content = NULL;
    int i;
    
    if (curnode == NULL)
        return NULL;
    
    content = TreeRemoveNodeIndex(aTree, curnode, index);
    for (i = 0; i < aTree->indexes; ++i)
    {
        if (i != index)
            content = TreeRemoveIndex(aTree, content, i);
    }
    return content;
}

void TreeFree(Tree* aTree)
{
    (aTree->heap_tracking) ? myfree(__FILE__, __LINE__, aTree) : free(aTree);
}

Node* TreeFindIndex(Tree* aTree, void* key, int index)
{
    return TreeFindIndex1(aTree, key, index, 0);
}

Node* TreeFind(Tree* aTree, void* key)
{
    return TreeFindIndex(aTree, key, 0);
}

Node* TreeNextElement(Tree* aTree, Node* curnode)
{
    return TreeNextElementIndex(aTree, curnode, 0);
}

int TreeIntCompare(void* a, void* b, int content)
{
    int i = *((int*)a);
    int j = *((int*)b);
    
    //printf("comparing %d %d\n", *((int*)a), *((int*)b));
    return (i > j) ? -1 : (i == j) ? 0 : 1;
}

int TreePtrCompare(void* a, void* b, int content)
{
    return (a > b) ? -1 : (a == b) ? 0 : 1;
}

int TreeStringCompare(void* a, void* b, int content)
{
    return strcmp((char*)a, (char*)b);
}

#pragma mark - Private functionality

int isRed(Node* aNode)
{
	return (aNode != NULL) && (aNode->red);
}

int isBlack(Node* aNode)
{
	return (aNode == NULL) || (aNode->red == 0);
}

int TreeWalk(Node* curnode, int depth)
{
	if (curnode)
	{
		int left = TreeWalk(curnode->child[LEFT], depth+1);
		int right = TreeWalk(curnode->child[RIGHT], depth+1);
		depth = max(left, right);
		if (curnode->red)
		{
			/*if (isRed(curnode->child[LEFT]) || isRed(curnode->child[RIGHT]))
			{
				printf("red/black tree violation %p\n", curnode->content);
				exit(-99);
			}*/;
		}
	}
	return depth;
}

int TreeMaxDepth(Tree *aTree)
{
	int rc = TreeWalk(aTree->index[0].root, 0);
	/*if (aTree->root->red)
	{
		printf("root node should not be red %p\n", aTree->root->content);
		exit(-99);
	}*/
	return rc;
}


void TreeRotate(Tree* aTree, Node* curnode, int direction, int index)
{
	Node* other = curnode->child[!direction];

	curnode->child[!direction] = other->child[direction];
	if (other->child[direction] != NULL)
		other->child[direction]->parent = curnode;
	other->parent = curnode->parent;
	if (curnode->parent == NULL)
		aTree->index[index].root = other;
	else if (curnode == curnode->parent->child[direction])
		curnode->parent->child[direction] = other;
	else
		curnode->parent->child[!direction] = other;
	other->child[direction] = curnode;
	curnode->parent = other;
}

Node* TreeBAASub(Tree* aTree, Node* curnode, int which, int index)
{
	Node* uncle = curnode->parent->parent->child[which];

	if (isRed(uncle))
	{
		curnode->parent->red = uncle->red = 0;
		curnode = curnode->parent->parent;
		curnode->red = 1;
	}
	else
	{
		if (curnode == curnode->parent->child[which])
		{
			curnode = curnode->parent;
			TreeRotate(aTree, curnode, !which, index);
		}
		curnode->parent->red = 0;
		curnode->parent->parent->red = 1;
		TreeRotate(aTree, curnode->parent->parent, which, index);
	}
	return curnode;
}

void TreeBalanceAfterAdd(Tree* aTree, Node* curnode, int index)
{
	while (curnode && isRed(curnode->parent) && curnode->parent->parent)
	{
		if (curnode->parent == curnode->parent->parent->child[LEFT])
			curnode = TreeBAASub(aTree, curnode, RIGHT, index);
		else
			curnode = TreeBAASub(aTree, curnode, LEFT, index);
  }
  aTree->index[index].root->red = 0;
}

/*!
 *  @abstract Add an item to a tree
 *
 *  @param aTree The list to which the item is to be added
 *  @param content The list item content itself
 *  @param size The size of the element
 */
void* TreeAddByIndex(Tree* aTree, void* content, size_t size, int index)
{
	Node* curparent = NULL;
	Node* curnode = aTree->index[index].root;
	Node* newel = NULL;
	int left = 0;
	int result = 1;
	void* rc = NULL;

	while (curnode)
	{
		result = aTree->index[index].compare(curnode->content, content, 1);
		left = (result > 0);
		if (result == 0)
			break;
		else
		{
			curparent = curnode;
			curnode = curnode->child[left];
		}
	}

	if (result == 0)
	{
		if (aTree->allow_duplicates)
			exit(-99);
		{
			newel = curnode;
			rc = newel->content;
			if (index == 0)
				aTree->size += (size - curnode->size);
		}
	}
	else
	{
        newel = (aTree->heap_tracking) ? mymalloc(__FILE__, __LINE__, sizeof(Node)) : malloc(sizeof(Node));
		memset(newel, '\0', sizeof(Node));
		if (curparent)
			curparent->child[left] = newel;
		else
			aTree->index[index].root = newel;
		newel->parent = curparent;
		newel->red = 1;
		if (index == 0)
		{
			++(aTree->count);
			aTree->size += size;
		}
	}
	newel->content = content;
	newel->size = size;
	TreeBalanceAfterAdd(aTree, newel, index);
	return rc;
}

Node* TreeFindIndex1(Tree* aTree, void* key, int index, int value)
{
	int result = 0;
	Node* curnode = aTree->index[index].root;

	while (curnode)
	{
		result = aTree->index[index].compare(curnode->content, key, value);
		if (result == 0)
			break;
		else
			curnode = curnode->child[result > 0];
	}
	return curnode;
}

Node* TreeFindContentIndex(Tree* aTree, void* key, int index)
{
	return TreeFindIndex1(aTree, key, index, 1);
}

Node* TreeMinimum(Node* curnode)
{
    if (curnode)
        while (curnode->child[LEFT])
            curnode = curnode->child[LEFT];
    return curnode;
}

Node* TreeSuccessor(Node* curnode)
{
    if (curnode->child[RIGHT])
        curnode = TreeMinimum(curnode->child[RIGHT]);
    else
    {
        Node* curparent = curnode->parent;
        while (curparent && curnode == curparent->child[RIGHT])
        {
            curnode = curparent;
            curparent = curparent->parent;
        }
        curnode = curparent;
    }
    return curnode;
}

Node* TreeNextElementIndex(Tree* aTree, Node* curnode, int index)
{
    if (curnode == NULL)
        curnode = TreeMinimum(aTree->index[index].root);
    else
        curnode = TreeSuccessor(curnode);
    return curnode;
}

Node* TreeBARSub(Tree* aTree, Node* curnode, int which, int index)
{
	Node* sibling = curnode->parent->child[which];

	if (isRed(sibling))
	{
		sibling->red = 0;
		curnode->parent->red = 1;
		TreeRotate(aTree, curnode->parent, !which, index);
		sibling = curnode->parent->child[which];
	}
	if (!sibling)
		curnode = curnode->parent;
	else if (isBlack(sibling->child[!which]) && isBlack(sibling->child[which]))
	{
		sibling->red = 1;
		curnode = curnode->parent;
	}
	else
	{
		if (isBlack(sibling->child[which]))
		{
			sibling->child[!which]->red = 0;
			sibling->red = 1;
			TreeRotate(aTree, sibling, which, index);
			sibling = curnode->parent->child[which];
		}
		sibling->red = curnode->parent->red;
		curnode->parent->red = 0;
		sibling->child[which]->red = 0;
		TreeRotate(aTree, curnode->parent, !which, index);
		curnode = aTree->index[index].root;
	}
	return curnode;
}


void TreeBalanceAfterRemove(Tree* aTree, Node* curnode, int index)
{
	while (curnode != aTree->index[index].root && isBlack(curnode))
	{
		/* curnode->content == NULL must equal curnode == NULL */
		if (((curnode->content) ? curnode : NULL) == curnode->parent->child[LEFT])
			curnode = TreeBARSub(aTree, curnode, RIGHT, index);
		else
			curnode = TreeBARSub(aTree, curnode, LEFT, index);
    }
	curnode->red = 0;
}

/*!
 * Remove an item from a tree
 * @param aTree the list to which the item is to be added
 * @param curnode the list item content itself
 */
void* TreeRemoveIndex(Tree* aTree, void* content, int index)
{
	Node* curnode = TreeFindContentIndex(aTree, content, index);

	if (curnode == NULL)
		return NULL;

	return TreeRemoveNodeIndex(aTree, curnode, index);
}
