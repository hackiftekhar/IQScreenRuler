//
//  IQGeometry+CGLine.m
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import "IQGeometry+Line.h"

IQLine IQLineMake(CGPoint beginPoint, CGPoint endPoint)
{
    IQLine line;        line.beginPoint = beginPoint;       line.endPoint = endPoint; return line;
}



@implementation NSValue (Line)

+ (id)valueWithIQLine:(IQLine)line
{
    return [NSValue value:&line withObjCType:@encode(IQLine)];
}

- (IQLine)lineValue;
{
    IQLine line; [self getValue:&line]; return line;
}

@end