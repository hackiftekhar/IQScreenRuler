//
//  IQGeometry+Convenience.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

/*Set Origin*/
CGRect IQRectSetX(CGRect rect, CGFloat x);
CGRect IQRectSetY(CGRect rect, CGFloat y);
CGRect IQRectSetOrigin(CGRect rect, CGPoint origin);
CGRect IQRectMakeOrigin(CGRect rect, CGFloat x, CGFloat y);

/*Set Size*/
CGRect IQRectSetHeight(CGRect rect, CGFloat height);
CGRect IQRectSetWidth(CGRect rect, CGFloat width);
CGRect IQRectSetSize(CGRect rect, CGSize size);
CGRect IQRectMakeSize(CGRect rect, CGFloat width, CGFloat height);

/*Set Center*/
CGRect IQRectSetCenter(CGRect rect, CGPoint center);
CGPoint IQRectGetCenter(CGRect rect);
CGRect IQRectWithCenterSize(CGPoint center, CGSize size);
CGRect IQRectCenteredInRect(CGRect rect, CGRect mainRect);

/*Rect from Points*/
CGRect IQRectFromPoint(CGPoint startPoint, CGPoint endPoint);

CGPoint IQRectGetTopLeft(CGRect rect);
CGPoint IQRectGetTopRight(CGRect rect);
CGPoint IQRectGetBottomLeft(CGRect rect);
CGPoint IQRectGetBottomRight(CGRect rect);

/*Flip Rect Origin and Size*/
CGRect IQRectFlipHorizontal(CGRect rect, CGRect outerRect);
CGRect IQRectFlipVertical(CGRect rect, CGRect outerRect);
CGRect IQRectFlipFlop(CGRect rect);
// Does not affect size
CGRect IQRectFlipOrigin(CGRect rect);
// Does not affect point of origin
CGRect IQRectFlipSize(CGRect rect);

/*Scale*/
CGRect IQRectScale(CGRect rect, CGFloat wScale, CGFloat hScale);
CGRect IQRectScaleOrigin(CGRect rect, CGFloat wScale, CGFloat hScale);
CGRect IQRectScaleSize(CGRect rect, CGFloat wScale, CGFloat hScale);

/*Aspect Fit*/
CGRect IQRectAspectFit(CGSize sourceSize, CGRect destRect);
CGFloat IQAspectScaleFit(CGSize sourceSize, CGRect destRect);
// Only scales down, not up, and centers result
CGRect IQRectFitSizeInRect(CGSize sourceSize, CGRect destRect);

/*Aspect Fill*/
CGRect IQRectAspectFillRect(CGSize sourceSize, CGRect destRect);
CGFloat IQAspectScaleFill(CGSize sourceSize, CGRect destRect);

CGRect IQBoundAspectFillRectWithAngle(CGRect rect, CGFloat angle);
CGRect IQBoundAspectFitRectWithAngle(CGRect rect, CGFloat angle);
