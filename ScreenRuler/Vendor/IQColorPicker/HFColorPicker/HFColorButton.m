//
//  HFColorButton.m
//  HFColorPickerDemo
//
//  Created by Hendrik Frahmann on 30.04.14.
//  Copyright (c) 2014 Hendrik Frahmann. All rights reserved.
//

#import "HFColorButton.h"

@interface HFColorButton()
{
    CGContextRef context;
}
@end


@implementation HFColorButton

@synthesize color = _color;

static inline float radians(double degrees) { return degrees * M_PI / 180; }

- (void)drawRect:(CGRect)rect
{
    CGRect parentViewBounds = self.bounds;
    
    CGFloat centerX = CGRectGetWidth(parentViewBounds) / 2;
    CGFloat centerY = CGRectGetHeight(parentViewBounds) / 2;
    
    CGFloat radius = self.bounds.size.width / 2;
    
    // Get the graphics context and clear it
    if(context == nil)
        context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGFloat colorRadius = radius * 0.6;
    
    if(self.selected)
    {
        colorRadius = radius * 0.7;
        
        CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 2.0f, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor]);
        CGContextSetFillColor(context, CGColorGetComponents([[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0] CGColor]));
        CGContextMoveToPoint(context, centerX, centerY);
        CGContextAddArc(context, centerX, centerY, radius*0.9,  radians(0), radians(360), 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    
    
    CGContextSetShadow(context, CGSizeMake(0,0), 0);
    CGContextSetFillColor(context, CGColorGetComponents([_color CGColor]));
    CGContextMoveToPoint(context, centerX, centerY);
    CGContextAddArc(context, centerX, centerY, colorRadius,  radians(0), radians(360), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end
