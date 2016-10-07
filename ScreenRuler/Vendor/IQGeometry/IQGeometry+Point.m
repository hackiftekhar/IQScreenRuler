//
//  IQGeometry+CGPoint.m
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import "IQGeometry+Point.h"
#import "IQGeometry+Distance.h"
#import <UIKit/UIGeometry.h>

CGPoint IQPointGetMidPoint(CGPoint point1, CGPoint point2)
{
    return CGPointMake((point1.x+point2.x)/2, (point1.y+point2.y)/2);
}

CGPoint IQPointWithDistance(CGPoint point1, CGPoint point2, CGFloat distance)
{
    if (CGPointEqualToPoint(point1, point2))
    {
        return CGPointZero;
    }
    else
    {
        //Finding relative percent from point1 till distance ( 0.0 - 1.0).
        CGFloat relativePercent = distance/IQPointGetDistance(point1, point2);
        //Calculating distance from point1.
        CGFloat px = point1.x + relativePercent * (point2.x - point1.x);
        CGFloat py = point1.y + relativePercent * (point2.y - point1.y);
        
        //Returning Points
        return CGPointMake(px, py);
    }
}

CGPoint IQPointOfIntersect(IQLine line1, IQLine line2)
{
    CGFloat d = (line1.beginPoint.x-line1.endPoint.x)*(line2.beginPoint.y-line2.endPoint.y) - (line1.beginPoint.y-line1.endPoint.y)*(line2.beginPoint.x-line2.endPoint.x);
    
    CGFloat xi = ((line2.beginPoint.x-line2.endPoint.x)*(line1.beginPoint.x*line1.endPoint.y-line1.beginPoint.y*line1.endPoint.x)-(line1.beginPoint.x-line1.endPoint.x)*(line2.beginPoint.x*line2.endPoint.y-line2.beginPoint.y*line2.endPoint.x))/d;
    CGFloat yi = ((line2.beginPoint.y-line2.endPoint.y)*(line1.beginPoint.x*line1.endPoint.y-line1.beginPoint.y*line1.endPoint.x)-(line1.beginPoint.y-line1.endPoint.y)*(line2.beginPoint.x*line2.endPoint.y-line2.beginPoint.y*line2.endPoint.x))/d;
    
    return CGPointMake(xi, yi);
}

CGFloat IQPointGetDistanceOfPoint(CGPoint point, IQLine line)
{
    CGFloat normalLength = sqrt((line.endPoint.x-line.beginPoint.x)*(line.endPoint.x-line.beginPoint.x)+(line.endPoint.y-line.beginPoint.y)*(line.endPoint.y-line.beginPoint.y));
    return fabs((point.x-line.beginPoint.x)*(line.endPoint.y-line.beginPoint.y)-(point.y-line.beginPoint.y)*(line.endPoint.x-line.beginPoint.x))/normalLength;
}

CGPoint IQPointCentroidOfPoints(NSArray* points)
{
    CGFloat x = 0;
    CGFloat y = 0;
    
    for (NSValue *value in points)
    {
        x += [value CGPointValue].x;
        y += [value CGPointValue].y;
    }
    
    x = x/[points count];
    y = y/[points count];
    
    return CGPointMake(x, y);
}

CGPoint IQPointRotate(CGPoint basePoint, CGPoint point, CGFloat angle)
{
    CGFloat x = cos(angle) * (point.x-basePoint.x) - sin(angle) * (point.y-basePoint.y) + basePoint.x;
    CGFloat y = sin(angle) * (point.x-basePoint.x) + cos(angle) * (point.y-basePoint.y) + basePoint.y;
    
//    CGFloat x = cos(angle) * (basePoint.x-point.x) - sin(angle) * (basePoint.y-point.y) + point.x;
//    CGFloat y = sin(angle) * (basePoint.x-point.x) + cos(angle) * (basePoint.y-point.y) + point.y;
    
    return CGPointMake(x,y);
}

CGPoint IQPointGetNearPoint(CGPoint basePoint, NSArray *points)
{
    CGFloat minimumDistance = 10000;
    CGPoint nearbyPoint = basePoint;
    
    for (NSValue *aValue in points)
    {
        CGPoint aPoint = [aValue CGPointValue];
        
        CGFloat currentDistance = IQPointGetDistance(basePoint, aPoint);
        if (minimumDistance>currentDistance)
        {
            nearbyPoint = aPoint;
            minimumDistance = currentDistance;
        }
    }
    return nearbyPoint;
}

//CGPoint CGPointAspectFit(CGPoint point, CGSize destSize, CGRect sourceRect)
//{
//    CGRect innerRect = CGRectAspectFitRect(destSize, sourceRect);
//    
//    point = CGPointAspectFill(point, destSize, sourceRect);
//    
//    CGFloat ratioPointWidth = point.x/CGRectGetWidth(sourceRect);
//    CGFloat ratioPointHeight = point.y/CGRectGetHeight(sourceRect);
//    
//    CGFloat pointX = (innerRect.origin.x+CGRectGetWidth(innerRect)*ratioPointWidth);;
//    CGFloat pointY = (innerRect.origin.y+CGRectGetHeight(innerRect)*ratioPointHeight);
//    
//    return CGPointMake(pointX, pointY);
//}

CGPoint IQPointFlipHorizontal(CGPoint point, CGRect outerRect)
{
    CGPoint newPoint = point;
    newPoint.x = outerRect.origin.x + outerRect.size.width - point.x;
    return newPoint;
    
}

CGPoint IQPointFlipVertical(CGPoint point, CGRect outerRect)
{
    CGPoint newPoint = point;
    newPoint.y = outerRect.origin.y + outerRect.size.height - point.y;
    return newPoint;
}

CGPoint IQPointAspectFill(CGPoint point, CGSize destSize, CGRect sourceRect)
{
    return CGPointMake(point.x*(sourceRect.size.width/destSize.width), point.y*(sourceRect.size.height/destSize.height));
}

CGPoint IQPointOffset(CGPoint aPoint, CGFloat dx, CGFloat dy)
{
    return CGPointMake(aPoint.x + dx, aPoint.y + dy);
}

CGPoint IQPointScale(CGPoint aPoint, CGFloat wScale, CGFloat hScale)
{
    return CGPointMake(aPoint.x * wScale, aPoint.y * hScale);
}

CGPoint IQPointFlip(CGPoint point)
{
    return CGPointMake(point.y, point.x);
}








