//
//  UIScrollView+Addition.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@interface UIScrollView (Addition)

- (void)setZoomScale:(CGFloat)scale withCenter:(CGPoint)center animated:(BOOL)animated;

@property(nonatomic, readonly) CGSize minimumSize;

@property(nonatomic, readonly) CGRect visibleRect;

@property(nonatomic, readonly) CGRect presentationLayerVisibleRect;

/**
 * The receiver's `contentOffset` property, during animations. (read-only)
 *
 * `contentOffset` returns the wrong value if the receiver is animating, for example when `zoomBouncing` is `YES`.
 *
 * @see contentOffset
 */
@property (nonatomic, assign, readonly) CGPoint presentationLayerContentOffset;

/**
 * The receiver's `contentSize` property, during animations. (read-only)
 *
 * `contentSize` returns the wrong value if the receiver is animating, for example when `zoomBouncing` is `YES`.
 *
 * @see contentSize
 */
@property (nonatomic, assign, readonly) CGSize presentationLayerContentSize;

/**
 * The receiver's `zoomScale` property, during animations. (read-only)
 *
 * `zoomScale` returns the wrong value if the receiver is animating, for example when `zoomBouncing` is `YES`.
 *
 * @see zoomScale
 */
@property (nonatomic, assign, readonly) CGFloat presentationLayerZoomScale;

@end
