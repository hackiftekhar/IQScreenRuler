//
//  IQScrollContainerView.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>
#import "IQRulerScrollView.h"

@interface IQScrollContainerView : UIView

@property(nonatomic) UIViewContentMode contentMode; //UIViewContentModeScaleAspectFit & UIViewContentModeScaleAspectFill are only supported

@property(nonatomic,weak) IBOutlet id<UIScrollViewDelegate> delegate;

@property(nonatomic, readonly) IQRulerScrollView *scrollView;

@property(nonatomic, readonly) UIImageView *imageView;

@property(nonatomic) UIImage *image;

@property(nonatomic) CGFloat zoomScale;
@property(nonatomic) CGFloat minimumZoomScale;
@property(nonatomic) CGFloat maximumZoomScale;

@property(nonatomic) CGPoint contentOffset;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated;

- (void)zoomToMinimumScaleAnimated:(BOOL)animated;
- (void)zoomToOriginalScaleAnimated:(BOOL)animated;
- (void)zoomToMaximumScaleAnimated:(BOOL)animated;

@end
