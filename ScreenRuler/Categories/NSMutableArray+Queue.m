//
//  NSMutableArray+Queue.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (void)push:(id)object
{
    [self addObject:object];
}

- (id)pop
{
    id lastObject = [self lastObject];
    [self removeLastObject];
    return lastObject;
}

@end
