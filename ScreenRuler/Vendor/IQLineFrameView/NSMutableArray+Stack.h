//
//  NSMutableArray+Stack.h
//  Screen Ruler
//
//  Created by IEMacBook02 on 06/11/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Stack)

-(void)push:(id)object;
-(void)pushObjects:(NSArray*)objects;
-(id)pop;

@end
