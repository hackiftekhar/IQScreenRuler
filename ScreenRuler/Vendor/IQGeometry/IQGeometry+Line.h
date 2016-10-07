//
//  IQGeometry+CGLine.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

struct IQLine {
    CGPoint beginPoint;
    CGPoint endPoint;
};
typedef struct IQLine IQLine;

IQLine IQLineMake(CGPoint beginPoint, CGPoint endPoint);



@interface NSValue (Line)

+ (id)valueWithIQLine:(IQLine)line;

- (IQLine)lineValue;

@end
