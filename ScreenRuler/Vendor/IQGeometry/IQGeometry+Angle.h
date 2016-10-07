//
//  IQGeometry+Angle.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

/*Angle conversion*/
CGFloat IQDegreeToRadian(CGFloat angle);
CGFloat IQRadianToDegree(CGFloat radians);

/*Angle between two point*/
//    Say the distances are P1-P2 = A, P2-P3 = B and P3-P1 = C:
//    Angle = arccos ( (B^2-A^2-C^2) / 2AC )
CGFloat IQPointGetAngle(CGPoint centerPoint, CGPoint point1, CGPoint point2);
