//
//  IQGeometry+CGSize.m
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import "IQGeometry+Size.h"

CGSize IQSizeScale(CGSize aSize, CGFloat wScale, CGFloat hScale)
{
    return CGSizeMake(aSize.width * wScale, aSize.height * hScale);
}

CGSize IQSizeGetScale(CGSize sourceSize, CGSize destSize)
{
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height;
    
    return CGSizeMake(scaleW, scaleH);
}

CGSize IQSizeFlip(CGSize size)
{
    return CGSizeMake(size.height, size.width);
}

CGSize IQSizeFitInSize(CGSize sourceSize, CGSize destSize)
{
	CGFloat destScale;
	CGSize newSize = sourceSize;
    
	if (newSize.height && (newSize.height > destSize.height))
	{
		destScale = destSize.height / newSize.height;
		newSize.width *= destScale;
		newSize.height *= destScale;
	}
    
	if (newSize.width && (newSize.width >= destSize.width))
	{
		destScale = destSize.width / newSize.width;
		newSize.width *= destScale;
		newSize.height *= destScale;
	}
    
	return newSize;
}

