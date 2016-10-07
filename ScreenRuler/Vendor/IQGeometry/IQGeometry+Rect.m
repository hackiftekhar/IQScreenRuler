//
//  IQGeometry+Convenience.m
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import "IQGeometry+Rect.h"
#import "IQGeometry+Size.h"
#import "IQGeometry+Point.h"

CGRect IQRectSetX(CGRect rect, CGFloat x)
{
    rect.origin.x = x;  return rect;
}

CGRect IQRectSetY(CGRect rect, CGFloat y)
{
    rect.origin.y = y;  return rect;
}

CGRect IQRectSetOrigin(CGRect rect, CGPoint origin)
{
    rect.origin = origin;   return rect;
}

CGRect IQRectMakeOrigin(CGRect rect, CGFloat x, CGFloat y)
{
    rect.origin = CGPointMake(x, y);    return rect;
}


CGRect IQRectSetWidth(CGRect rect, CGFloat width)
{
    rect.size.width =   width;  return rect;
}

CGRect IQRectSetHeight(CGRect rect, CGFloat height)
{
    rect.size.height = height;  return rect;
}

CGRect IQRectSetSize(CGRect rect, CGSize size)
{
    rect.size = size;   return rect;
}

CGRect IQRectMakeSize(CGRect rect, CGFloat width, CGFloat height)
{
    rect.size = CGSizeMake(width, height);  return rect;
}



CGRect IQRectFromPoint(CGPoint startPoint, CGPoint endPoint)
{
    return CGRectMake(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y);
}


CGPoint IQRectGetTopLeft(CGRect rect)
{
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
}

CGPoint IQRectGetTopRight(CGRect rect)
{
    return CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
}

CGPoint IQRectGetBottomLeft(CGRect rect)
{
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
}

CGPoint IQRectGetBottomRight(CGRect rect)
{
    return CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
}


CGRect IQRectSetCenter(CGRect rect, CGPoint center)
{
    return CGRectMake(center.x-CGRectGetWidth(rect)/2, center.y-CGRectGetHeight(rect)/2, CGRectGetWidth(rect), CGRectGetHeight(rect));
}

CGPoint IQRectGetCenter(CGRect rect)
{
    return CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
}

CGRect IQRectWithCenterSize(CGPoint center, CGSize size)
{
	return CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
}

CGRect IQRectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect IQRectFlipHorizontal(CGRect innerRect, CGRect outerRect)
{
    CGRect rect = innerRect;
    rect.origin.x = outerRect.origin.x + outerRect.size.width - (rect.origin.x + rect.size.width);
    return rect;
}

CGRect IQRectFlipVertical(CGRect innerRect, CGRect outerRect)
{
    CGRect rect = innerRect;
    rect.origin.y = outerRect.origin.y + outerRect.size.height - (rect.origin.y + rect.size.height);
    return rect;
}

CGRect IQRectScale(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
}

CGRect IQRectScaleSize(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * wScale, rect.size.height * hScale);
}

CGRect  IQRectScaleOrigin(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width, rect.size.height);
}

CGRect IQRectFitSizeInRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGSize targetSize = IQSizeFitInSize(sourceSize, destSize);
	float dWidth = destSize.width - targetSize.width;
	float dHeight = destSize.height - targetSize.height;
    
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, targetSize.width, targetSize.height);
}

CGFloat IQAspectScaleFill(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height;
    return MAX(scaleW, scaleH);
}

CGRect IQRectAspectFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = IQAspectScaleFit(sourceSize, destRect);
    
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
    
	float dWidth = ((destSize.width - newWidth) / 2.0f);
	float dHeight = ((destSize.height - newHeight) / 2.0f);
    
	CGRect rect = CGRectMake(dWidth, dHeight, newWidth, newHeight);
	return rect;
}

CGFloat IQAspectScaleFit(CGSize sourceSize, CGRect destRect)
{
    if (CGSizeEqualToSize(sourceSize, CGSizeZero) == false)
    {
        CGSize destSize = destRect.size;
        CGFloat scaleW = destSize.width / sourceSize.width;
        CGFloat scaleH = destSize.height / sourceSize.height;
        return MIN(scaleW, scaleH);
    }
    else
    {
        return 1;
    }
}

CGRect IQRectAspectFillRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = IQAspectScaleFill(sourceSize, destRect);
    
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
    
	float dWidth = ((destSize.width - newWidth) / 2.0f);
	float dHeight = ((destSize.height - newHeight) / 2.0f);
    
	CGRect rect = CGRectMake(dWidth, dHeight, newWidth, newHeight);
	return rect;
}

CGRect IQRectFlipFlop(CGRect rect)
{
    return CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
}

CGRect IQRectFlipSize(CGRect rect)
{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

CGRect  IQRectFlipOrigin(CGRect rect)
{
    return CGRectMake(rect.origin.y, rect.origin.x, rect.size.width, rect.size.height);
}

CGRect IQBoundAspectFillRectWithAngle(CGRect rect, CGFloat angle)
{
    CGPoint topLeftPoint = CGPointZero;
    CGPoint bottomLeftPoint = CGPointMake(0, rect.size.height);
    CGPoint topRightPoint = CGPointMake(rect.size.width, 0);
    CGPoint midPoint = IQRectGetCenter(rect);
    
    CGFloat angleRadianForCalculation = ABS(angle);
    angleRadianForCalculation = fmodf(angleRadianForCalculation, M_PI);
    
    if (angleRadianForCalculation >= M_PI_2)
    {
        angleRadianForCalculation = M_PI_2 - fmodf(angleRadianForCalculation, M_PI_2);
    }
    
    CGPoint rotatedBottomLeftPoint = IQPointRotate(midPoint,bottomLeftPoint,angleRadianForCalculation);
    CGPoint rotatedTopLeftPoint = IQPointRotate(midPoint,topLeftPoint,angleRadianForCalculation);
    CGPoint rotatedTopRightPoint = IQPointRotate(midPoint,topRightPoint,angleRadianForCalculation);
    
    CGFloat horizontalScale = 1;
    CGFloat verticalScale = 1;
    
    {
        IQLine rotatedTopLine = IQLineMake(rotatedTopLeftPoint,rotatedTopRightPoint);
        
        CGFloat distance = IQPointGetDistanceOfPoint(topRightPoint, rotatedTopLine);
        
        horizontalScale = 1 + distance/(rect.size.height/2);
    }
    
    {
        IQLine rotatedLeftLine = IQLineMake(rotatedBottomLeftPoint,rotatedTopLeftPoint);
        
        CGFloat distance = IQPointGetDistanceOfPoint(topLeftPoint, rotatedLeftLine);
        
        verticalScale = 1 + distance/(rect.size.width/2);
    }
    
    CGFloat newWidth = rect.size.width*verticalScale;
    CGFloat newHeight = rect.size.height*horizontalScale;
    
    return CGRectMake(rect.origin.x+((rect.size.width-newWidth)/2),rect.origin.y+((rect.size.height-newHeight)/2),newWidth,newHeight);
}
//{
//    CGPoint topLeftPoint = CGPointZero;
//    CGPoint bottomLeftPoint = CGPointMake(0, rect.size.height);
//    CGPoint topRightPoint = CGPointMake(rect.size.width, 0);
//    CGPoint midPoint = CGPointMake(rect.size.width/2,rect.size.height/2);
//    
//    CGFloat angleRadianForCalculation = ABS(angle);
//    angleRadianForCalculation = fmodf(angleRadianForCalculation, M_PI);
//    
//    if (angleRadianForCalculation >= M_PI_2)
//    {
//        angleRadianForCalculation = M_PI_2 - fmodf(angleRadianForCalculation, M_PI_2);
//    }
//    
//    CGPoint rotatedBottomLeftPoint = IQPointRotate(midPoint,bottomLeftPoint,angleRadianForCalculation);
//    CGPoint rotatedTopLeftPoint = IQPointRotate(midPoint,topLeftPoint,angleRadianForCalculation);
//    CGPoint rotatedTopRightPoint = IQPointRotate(midPoint,topRightPoint,angleRadianForCalculation);
//    
//    IQLine rotatedTopLine = IQLineMake(rotatedTopLeftPoint, rotatedTopRightPoint);
//    IQLine rotatedLeftLine = IQLineMake(rotatedBottomLeftPoint, rotatedTopLeftPoint);
//    
//    CGFloat horizontalScale = 1;
//    CGFloat verticalScale = 1;
//    
//    {
//        CGFloat distance = IQPointGetDistanceOfPoint(topRightPoint, rotatedTopLine);
//        
//        horizontalScale = 1 + distance/(rect.size.height/2);
//    }
//    
//    {
//        CGFloat distance = IQPointGetDistanceOfPoint(topLeftPoint, rotatedLeftLine);
//        
//        verticalScale = 1 + distance/(rect.size.width/2);
//    }
//    
//    CGFloat newWidth = rect.size.width*verticalScale;
//    CGFloat newHeight = rect.size.height*horizontalScale;
//    
//    return CGRectMake(rect.origin.x+((rect.size.width-newWidth)/2),rect.origin.y+((rect.size.height-newHeight)/2),newWidth,newHeight);
//}

CGRect IQBoundAspectFitRectWithAngle(CGRect rect, CGFloat angle)
{
    CGPoint topLeftPoint = CGPointZero;
    CGPoint bottomLeftPoint = CGPointMake(0, rect.size.height);
    CGPoint topRightPoint = CGPointMake(rect.size.width, 0);
    CGPoint midPoint = CGPointMake(rect.size.width/2,rect.size.height/2);
    
    CGFloat angleRadianForCalculation = ABS(angle);
    angleRadianForCalculation = fmodf(angleRadianForCalculation, M_PI);
    
    if (angleRadianForCalculation >= M_PI_2)
    {
        angleRadianForCalculation = M_PI_2 - fmodf(angleRadianForCalculation, M_PI_2);
    }
    
    CGPoint rotatedBottomLeftPoint = IQPointRotate(midPoint,bottomLeftPoint,angleRadianForCalculation);
    CGPoint rotatedTopLeftPoint = IQPointRotate(midPoint,topLeftPoint,angleRadianForCalculation);
    CGPoint rotatedTopRightPoint = IQPointRotate(midPoint,topRightPoint,angleRadianForCalculation);
    
    IQLine rotatedTopLine = IQLineMake(rotatedTopLeftPoint, rotatedTopRightPoint);
    IQLine rotatedLeftLine = IQLineMake(rotatedBottomLeftPoint, rotatedTopLeftPoint);
    
    CGFloat horizontalScale = 1;
    CGFloat verticalScale = 1;
    
    {
        CGFloat distance = IQPointGetDistanceOfPoint(topRightPoint, rotatedTopLine);
        
        horizontalScale = 1 + distance/(rect.size.height/2);
    }
    
    {
        CGFloat distance = IQPointGetDistanceOfPoint(topLeftPoint, rotatedLeftLine);
        
        verticalScale = 1 + distance/(rect.size.width/2);
    }
    
    CGFloat newWidth = rect.size.width*verticalScale;
    CGFloat newHeight = rect.size.height*horizontalScale;
    
    return CGRectMake(rect.origin.x+((rect.size.width-newWidth)/2),rect.origin.y+((rect.size.height-newHeight)/2),newWidth,newHeight);
}




