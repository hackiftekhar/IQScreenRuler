//
//  NSMutableArray+Queue.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

- (void)push:(id)object;
- (id)pop;

@end
