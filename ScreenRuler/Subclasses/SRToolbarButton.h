//
//  SRToolbarButton.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@interface SRToolbarButton : UIButton

@property(nonatomic, strong) IBInspectable UIColor *normalStateColor;
@property(nonatomic, strong) IBInspectable UIColor *highlightedStateColor;
@property(nonatomic, strong) IBInspectable UIColor *disabledStateColor;
@property(nonatomic, strong) IBInspectable UIColor *selectedStateColor;

@end
