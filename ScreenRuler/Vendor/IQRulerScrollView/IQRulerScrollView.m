//
//  IQRulerScrollView.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQRulerScrollView.h"
#import "tgmath.h"
#import "IQGeometry+AffineTransform.h"
#import "SRLineImageView.h"
#import "UIScrollView+Addition.h"

@interface IQRulerScrollView ()<UIGestureRecognizerDelegate>

@end

@implementation IQRulerScrollView
{

}
-(void)initialize
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    self.contentView = [[UIView alloc] init];
    self.contentView.layer.shadowOffset = CGSizeZero;
    self.contentView.layer.shadowOpacity = 0.2;
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    [self addSubview:self.contentView];
    self.contentView.layer.magnificationFilter = kCAFilterNearest;

    self.imageView = [[SRLineImageView alloc] init];
    self.imageView.layer.magnificationFilter = kCAFilterNearest;
    [self.contentView addSubview:self.imageView];
    
    _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognizer:)];
    _doubleTapRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_doubleTapRecognizer];
    
    [self.panGestureRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
    [self.pinchGestureRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
    
    _doubleTapTwoFingerRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapDoubleFingerRecognizer:)];
    _doubleTapTwoFingerRecognizer.numberOfTapsRequired = 2;
    _doubleTapTwoFingerRecognizer.numberOfTouchesRequired = 2;
    _doubleTapTwoFingerRecognizer.delegate = self;
    [_doubleTapRecognizer requireGestureRecognizerToFail:_doubleTapTwoFingerRecognizer];
    [self addGestureRecognizer:_doubleTapTwoFingerRecognizer];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _doubleTapTwoFingerRecognizer)
    {
        if (otherGestureRecognizer == self.panGestureRecognizer ||
            otherGestureRecognizer == self.pinchGestureRecognizer)
        {
            return YES;
        }
    }
    
    return NO;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(UIImage *)image
{
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;

    if (image)
    {
        self.zoomScale = 1;
        self.imageView.frame = self.contentView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    else
    {
        self.zoomScale = 1;
        self.imageView.frame = self.contentView.frame = CGRectMake(0, 0, 0, 0);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.layer.shadowRadius = 10.0/IQAffineTransformGetScale(self.contentView.transform).width;

    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.imageView.zoomScale = self.zoomScale;
}

-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    [self centerContent];
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    [self centerContent];
}

-(void)centerContent
{
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.contentView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;

    if (CGRectEqualToRect(frameToCenter, self.contentView.frame) == false)
    {
        self.contentView.frame = frameToCenter;

        if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
        {
            [self.delegate scrollViewDidScroll:self];
        }
    }
}

-(void)doubleTapRecognizer:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self setZoomScale:MIN(self.maximumZoomScale,self.zoomScale*2) withCenter:[recognizer locationInView:self.contentView] animated:YES];
    }
}

-(void)doubleTapDoubleFingerRecognizer:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self setZoomScale:self.zoomScale/2 animated:YES];
    }
}

@end



@implementation UIView (IQRulerScrollViewHierarchy)

-(IQRulerScrollView *)rulerView
{
    UIView *superview = self.superview;
    
    while (superview) {
        if ([superview isKindOfClass:[IQRulerScrollView class]]) {
            return (IQRulerScrollView*)superview;
            break;
        }
        else {
            superview = superview.superview;
        }
    }
    
    return nil;
}

@end

