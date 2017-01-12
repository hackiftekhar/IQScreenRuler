//
//  SRNavigationBar.m
//  Screen Ruler
//
//  Created by IEMacBook02 on 01/01/17.
//  Copyright © 2017 InfoEnum Software Systems. All rights reserved.
//

#import "SRNavigationBar.h"
#import "SRToolbarButton.h"
#import "UIImage+Color.h"

@implementation SRNavigationBar

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

//barStyle

-(void)updateColors
{
    UIColor *tintColor = [[self tintColor] colorWithAlphaComponent:1];
    UIColor *barTintColor = [[self barTintColor] colorWithAlphaComponent:1];

    for (UINavigationItem *item in self.items)
    {
        for (UIBarButtonItem *barItem in item.leftBarButtonItems)
        {
            barItem.tintColor = tintColor;
        }

        for (UIBarButtonItem *barItem in item.rightBarButtonItems)
        {
            barItem.tintColor = tintColor;
        }
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
            }
            
            UIImage *selectedImage = [button imageForState:UIControlStateSelected];
            
            if (selectedImage)
            {
                [button setImage:[selectedImage imageWithColor:barTintColor] forState:UIControlStateSelected];
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
