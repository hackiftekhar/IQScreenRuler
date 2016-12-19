//
//  LinkedList.m
//  NSDataLinkedList
//
//  Created by Sam Davies on 26/09/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import "LinkedListStack.h"

@implementation LinkedListStack

#pragma mark - Initialisation
/*
    A linked List is create with size of <capicity>.
    When you add more element that <capicity> than Lisk List is incressed by size <increment>
    mul is value for H (for H see comment Stack methods)
*/
- (id)init
{
    return [self initWithCapacity:500];
}

- (id)initWithCapacity:(NSInteger)capacity
{
    return [self initWithCapacity:capacity incrementSize:500 andMultiplier:1000];
}

- (id)initWithCapacity:(NSInteger)capacity incrementSize:(NSInteger)increment andMultiplier:(NSInteger)mul
{
    self = [super init];
    
    if(self)
    {
        _cacheSizeIncrements = increment;
        
        NSInteger bytesRequired = capacity * sizeof(PointNode);
        
        nodeCache = [[NSMutableData alloc] initWithLength:bytesRequired];
        
        [self initialiseNodesAtOffset:0 count:capacity];
        
        freeNodeOffset = 0;
        topNodeOffset = FINAL_NODE_OFFSET;
        
        multiplier = mul;
    }
    
    return self;
}

#pragma mark - Stack methods
/*
    X and Y are converted in single integer value (P) to push in stack.
    And again that value (P) are converted to X and Y when pop by using following equation:
    
    P = H * X + Y
 
    X = P / H;
    Y = P % H;
 
    H is same for all X and Y and must be grater than Y. So generaly Height is prefered value;
*/
- (void)pushFrontX:(NSInteger)x andY:(NSInteger)y;
{
    NSInteger p = multiplier * x + y;
    
    PointNode *node = [self getNextFreeNode];
    
    node->point = p;
    node->nextNodeOffset = topNodeOffset;
    
    topNodeOffset = [self offsetOfNode:node];
}

- (NSInteger)popFront:(NSInteger *)x andY:(NSInteger *)y;
{
    if(topNodeOffset == FINAL_NODE_OFFSET)
    {
        return INVALID_NODE_CONTENT;
    }
    
    PointNode *node = [self nodeAtOffset:topNodeOffset];
    
    NSInteger thisNodeOffset = topNodeOffset;
    
    // Remove this node from the queue
    topNodeOffset = node->nextNodeOffset;
    NSInteger value = node->point;
    
    // Reset it and add it to the free node cache
    node->point = 0;
    node->nextNodeOffset = freeNodeOffset;
    
    freeNodeOffset = thisNodeOffset;
    
    *x = value / multiplier;
    *y = value % multiplier;
    
    return value;
}

#pragma mark - utility functions
- (NSInteger)offsetOfNode:(PointNode *)node
{
    return node - (PointNode *)nodeCache.mutableBytes;
}

- (PointNode *)nodeAtOffset:(NSInteger)offset
{
    return (PointNode *)nodeCache.mutableBytes + offset;
}

- (PointNode *)getNextFreeNode
{
    if(freeNodeOffset < 0)
    {
        // Need to extend the size of the nodeCache
        NSInteger currentSize = nodeCache.length / sizeof(PointNode);
        [nodeCache increaseLengthBy:_cacheSizeIncrements * sizeof(PointNode)];
    
        // Set these new nodes to be the free ones
        [self initialiseNodesAtOffset:currentSize count:_cacheSizeIncrements];
        freeNodeOffset = currentSize;
    }
    
    PointNode *node = (PointNode*)nodeCache.mutableBytes + freeNodeOffset;
    freeNodeOffset = node->nextNodeOffset;
    
    return node;
}

- (void)initialiseNodesAtOffset:(NSInteger)offset count:(NSInteger)count
{
    PointNode *node = (PointNode *)nodeCache.mutableBytes + offset;
    
    for (int i=0; i<count - 1; i++)
    {
        node->point = 0;
        node->nextNodeOffset = offset + i + 1;
        node++;
    }
    
    node->point = 0;
    
    // Set the next node offset to make sure we don't continue
    node->nextNodeOffset = FINAL_NODE_OFFSET;
}

@end
