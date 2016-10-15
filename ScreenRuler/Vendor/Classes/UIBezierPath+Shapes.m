//
//  UIBezierPath+Shapes.m
//  CBZSplashView
//
//  Created by Mazyad Alabduljaleel on 8/8/14.
//  Copyright (c) 2014 Callum Boddy. All rights reserved.
//

#import "UIBezierPath+Shapes.h"

@implementation UIBezierPath (Shapes)

+ (instancetype)twitterShape
{
    UIBezierPath* nPath = [UIBezierPath bezierPath];
    
    CGSize size = CGSizeMake(200, 200);
    CGFloat diff = size.width/17.0;

    [nPath moveToPoint:CGPointMake(diff*3, diff*3)];
    
    [nPath addLineToPoint: CGPointMake(diff*0.5, diff*5.5)];
    [nPath addQuadCurveToPoint:CGPointMake(diff*0.5, diff*6.5) controlPoint:CGPointMake(0, diff*6)];

    [nPath addLineToPoint: CGPointMake(diff*10.5, diff*16.5)];
    [nPath addQuadCurveToPoint:CGPointMake(diff*11.5, diff*16.5) controlPoint:CGPointMake(diff*11, size.height)];

    [nPath addLineToPoint: CGPointMake(diff*16.5, diff*11.5)];
    [nPath addQuadCurveToPoint:CGPointMake(diff*16.5, diff*10.5) controlPoint:CGPointMake(size.width, diff*11)];
    
    [nPath addLineToPoint: CGPointMake(diff*6.5, diff*0.5)];
    [nPath addQuadCurveToPoint:CGPointMake(diff*5.5, diff*0.5) controlPoint:CGPointMake(diff*6, 0)];
    [nPath closePath];

    [nPath moveToPoint: CGPointMake(diff*4, diff*4)];
    
    [nPath addLineToPoint:CGPointMake(diff*2, diff*6)];
    [nPath addLineToPoint:CGPointMake(diff*3, diff*7)];

    for (NSInteger i = 0; i<4; i++)
    {
        CGPoint topPoint = CGPointMake(diff*(5.5+i*2), diff*(4.5+i*2));
        
        if (i%2 != 0)
        {
            topPoint = CGPointMake(diff*(4.2+i*2), diff*(5.8+i*2));
        }

        CGPoint bottomPoint = CGPointMake(topPoint.x+diff, topPoint.y+diff);

        [nPath addLineToPoint: topPoint];
        
        [nPath addCurveToPoint: bottomPoint controlPoint1: CGPointMake(topPoint.x + diff*0.75, topPoint.y - diff*0.75) controlPoint2: CGPointMake(bottomPoint.x + diff*0.75, bottomPoint.y - diff*0.75)];
        
        [nPath addLineToPoint: CGPointMake(diff*(4+i*2), diff*(8+i*2))];
        [nPath addLineToPoint: CGPointMake(diff*(5+i*2),  diff*(9+i*2))];
    }
    
    [nPath addLineToPoint: CGPointMake(diff*15, diff*11)];
    [nPath addLineToPoint: CGPointMake(diff*6, diff*2)];
    [nPath closePath];

    return nPath;
}

@end
