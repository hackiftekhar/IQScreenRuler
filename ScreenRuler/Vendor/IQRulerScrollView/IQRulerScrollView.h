//
//  IQRulerScrollView.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@interface IQRulerScrollView : UIScrollView

@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) UIImageView *imageView;

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, readonly) CGSize minimumSize;

@property(nonatomic, readonly) CGRect visibleRect;

- (void)setZoomScale:(CGFloat)scale withCenter:(CGPoint)center animated:(BOOL)animated;

@property (strong, nonatomic, readonly) UITapGestureRecognizer *doubleTapRecognizer;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapTwoFingerRecognizer;

@end
