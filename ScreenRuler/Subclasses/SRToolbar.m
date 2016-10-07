//
//  SRToolbar.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRToolbar.h"
#import "IQGeometry+AffineTransform.h"
#import "SRToolbarButton.h"
#import "UIImage+Color.h"

@implementation SRToolbar

Class IQUIToolbarBackgroundClass;

+(void)load
{
    IQUIToolbarBackgroundClass = NSClassFromString(@"_UIToolbarBackground");
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIView *barButtonItemView in self.subviews)
    {
        if ([barButtonItemView isKindOfClass:IQUIToolbarBackgroundClass] == NO &&
            [barButtonItemView isKindOfClass:[UIImageView class]] == NO)
        {
//            barButtonItemView.transform = CGAffineTransformMakeRotation(-IQAffineTransformGetAngle(self.transform));
        }
    }
}

-(void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];

    [self updateColors];
}

-(void)setBarTintColor:(UIColor *)barTintColor
{
    [super setBarTintColor:barTintColor];
    
    [self updateColors];
}

-(void)updateColors
{
    UIColor *tintColor = [self tintColor];
    UIColor *barTintColor = [self barTintColor];
    
    for (UIBarButtonItem *item in self.items)
    {
        item.tintColor = tintColor;
    }
    
    for (UIView *barButtonItemView in self.subviews)
    {
        if ([barButtonItemView isKindOfClass:[SRToolbarButton class]])
        {
            SRToolbarButton *button = (SRToolbarButton*)barButtonItemView;
            button.highlightedStateColor = tintColor;
            button.selectedStateColor = tintColor;
            button.tintColor = tintColor;
            
            UIImage *image = [button imageForState:UIControlStateNormal];
            
            if (image)
            {
                [button setImage:[image imageWithColor:tintColor] forState:UIControlStateNormal];
                [button setImage:[image imageWithColor:barTintColor] forState:UIControlStateSelected];
            }
        }
    }
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = 44;
    return sizeThatFits;
}

@end
