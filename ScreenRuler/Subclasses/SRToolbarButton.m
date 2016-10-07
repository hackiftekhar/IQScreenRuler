//
//  SRToolbarButton.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRToolbarButton.h"
#import "UIImage+Color.h"

@implementation SRToolbarButton

-(void)setNormalStateColor:(UIColor *)normalStateColor
{
    _normalStateColor = normalStateColor;
    
    UIImage *image = [[UIImage imageWithColor:_normalStateColor] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

-(void)setHighlightedStateColor:(UIColor *)highlightedStateColor
{
    _highlightedStateColor = highlightedStateColor;
    
    UIImage *image = [[UIImage imageWithColor:_highlightedStateColor] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
}

-(void)setDisabledStateColor:(UIColor *)disabledStateColor
{
    _disabledStateColor = disabledStateColor;
    
    UIImage *image = [[UIImage imageWithColor:_disabledStateColor] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:image forState:UIControlStateDisabled];
}

-(void)setSelectedStateColor:(UIColor *)selectedStateColor
{
    _selectedStateColor = selectedStateColor;
    
    UIImage *image = [[UIImage imageWithColor:_selectedStateColor] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:image forState:UIControlStateSelected];
}

@end
