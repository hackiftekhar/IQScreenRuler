//
//  IQRulerView.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>
#import "IQAngleView.h"

@interface IQRulerView : UIView

@property(nonatomic,assign) CGFloat deviceScale;
@property(nonatomic,assign) CGFloat zoomScale;
@property(nonatomic,weak) UIView *respectiveView;

@property(nonatomic,strong) UIColor *lineColor;
@property(nonatomic,strong) UIColor *rulerColor;

@end
