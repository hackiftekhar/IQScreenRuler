//
//  IQGeometry+CGSize.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

CGSize  IQSizeScale(CGSize aSize, CGFloat wScale, CGFloat hScale);

CGSize  IQSizeFlip(CGSize size);

CGSize  IQSizeFitInSize(CGSize sourceSize, CGSize destSize);

CGSize  IQSizeGetScale(CGSize sourceSize, CGSize destSize);
