//
//  IQGeometry+CGAffineTransform.m
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import "IQGeometry+AffineTransform.h"

CGFloat IQAffineTransformGetAngle(CGAffineTransform t)
{
    return atan2(t.b, t.a);
}

CGSize IQAffineTransformGetScale(CGAffineTransform t)
{
    return CGSizeMake(sqrt(t.a * t.a + t.c * t.c), sqrt(t.b * t.b + t.d * t.d)) ;
}

