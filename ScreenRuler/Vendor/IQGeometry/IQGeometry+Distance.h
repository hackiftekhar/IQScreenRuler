//
//  IQGeometry+Distance.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
/*
 A (x1, y1) and B (x2, y2) = sqrt( (x2−x1)2+(y2−y1)2)
 */
CGFloat IQPointGetDistance(CGPoint point1, CGPoint point2);
