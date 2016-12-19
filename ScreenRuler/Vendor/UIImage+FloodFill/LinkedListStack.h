//
//  LinkedList.h
//  NSDataLinkedList
//
//  Created by Sam Davies on 26/09/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FINAL_NODE_OFFSET -1
#define INVALID_NODE_CONTENT INT_MIN
typedef struct PointNode
{
    NSInteger nextNodeOffset;
    
    NSInteger point;
    
} PointNode;

@interface LinkedListStack : NSObject
{
    NSMutableData *nodeCache;
    
    NSInteger freeNodeOffset;
    NSInteger topNodeOffset;
    NSInteger _cacheSizeIncrements;
    
    NSInteger multiplier;
}

- (id)initWithCapacity:(NSInteger)capacity incrementSize:(NSInteger)increment andMultiplier:(NSInteger)mul;
- (id)initWithCapacity:(NSInteger)capacity;

- (void)pushFrontX:(NSInteger)x andY:(NSInteger)y;
- (NSInteger)popFront:(NSInteger *)x andY:(NSInteger *)y;
@end
