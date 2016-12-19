//
//  NSMutableArray+Stack.m
//  Screen Ruler
//
//  Created by IEMacBook02 on 06/11/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

-(void)push:(id)object
{
    [self addObject:object];
}

-(void)pushObjects:(NSArray*)objects
{
    [self addObjectsFromArray:objects];
}

-(id)pop
{
    id object = [self lastObject];
    [self removeLastObject];
    return object;
}

@end


