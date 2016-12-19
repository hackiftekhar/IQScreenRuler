//
//  UIScrollView+Addition.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "UIScrollView+Addition.h"

@implementation UIScrollView (Addition)

- (void)setZoomScale:(CGFloat)scale withCenter:(CGPoint)center animated:(BOOL)animated
{
    CGSize boundsSize = self.bounds.size;
    CGRect zoomRect;
    
    zoomRect.size.width = boundsSize.width / scale;
    zoomRect.size.height = boundsSize.height / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0f);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0f);
    
    [self zoomToRect:zoomRect animated:YES];
}

-(CGRect)visibleRect
{
    return [self visibleRectWithInsetSize:CGSizeZero];
}

-(CGRect)visibleRectWithInsetSize:(CGSize)insetSize
{
    UIView *zoomView = [self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)] ? [self.delegate viewForZoomingInScrollView:self] : self;
    return [self convertRect:CGRectInset(self.bounds, insetSize.width, insetSize.height) toView:zoomView];
}

-(CGRect)presentationLayerVisibleRect
{
    return [self presentationLayerVisibleRectWithInsetSize:CGSizeZero];
}

-(CGRect)presentationLayerVisibleRectWithInsetSize:(CGSize)insetSize
{
    UIView *zoomView = [self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)] ? [self.delegate viewForZoomingInScrollView:self] : self;
    return [self.layer.presentationLayer convertRect:CGRectInset(self.layer.presentationLayer.bounds, insetSize.width, insetSize.height) toLayer:zoomView.layer.presentationLayer];
}

-(CGSize)minimumSize
{
    if ([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
    {
        UIView *zoomView = [self.delegate viewForZoomingInScrollView:self];
        return CGSizeMake(CGRectGetWidth(zoomView.bounds)*self.minimumZoomScale, CGRectGetHeight(zoomView.bounds)*self.minimumZoomScale);
    }
    else
    {
        return CGSizeZero;
    }
}

-(CGPoint)presentationLayerContentOffset
{
    CALayer *presentationLayer = self.layer.presentationLayer;
    return presentationLayer.bounds.origin;
}

-(CGSize)presentationLayerContentSize
{
    if ([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        UIView *zoomView = [self.delegate viewForZoomingInScrollView:self];
        CALayer *zoomPresentationLayer = zoomView.layer.presentationLayer;
        
        return zoomPresentationLayer.frame.size;
    } else
        return self.contentSize;
}

-(CGFloat)presentationLayerZoomScale
{
    if ([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        UIView *zoomView = [self.delegate viewForZoomingInScrollView:self];
        CALayer *zoomPresentationLayer = zoomView.layer.presentationLayer;
        
        return zoomPresentationLayer.transform.m11;
    } else
        return self.zoomScale;
}

@end
