//
//  IQRulerScrollView.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>
#import "SRLineImageView.h"

@interface IQRulerScrollView : UIScrollView

@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) SRLineImageView *imageView;

@property(nonatomic, strong) UIImage *image;

@property (strong, nonatomic, readonly) UITapGestureRecognizer *doubleTapRecognizer;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapTwoFingerRecognizer;

@end
