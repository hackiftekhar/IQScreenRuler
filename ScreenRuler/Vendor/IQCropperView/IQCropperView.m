//
//  IQCropperView.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQCropperView.h"

#import "IQGeometry+Rect.h"
#import "UIFont+AppFont.h"
#import <QuartzCore/CAShapeLayer.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>

#import "UIColor+ThemeColor.h"

CGFloat circularViewWidth = 44;

@interface IQCropperView()<UIGestureRecognizerDelegate>

@property(nonatomic, readonly) CGRect cropBounds;
@property(nonatomic, readonly) UIView* innerCropperView;
@property(nonatomic, readonly) UIView *tl1, *tl2, *tr1, *tr2, *bl1, *bl2, *br1, *br2;
@property(nonatomic, readonly) UIView *leftVerticalLine, *rightVerticalLine, *topHorizontalLine, *bottomHorizontalLine;
@property(nonatomic, readonly) CAShapeLayer *shapeLayer;

@end

@implementation IQCropperView
{
    UIPanGestureRecognizer *panRecognizer;
    
    CGPoint _beginTouchPoint;
    CGRect _beginRect;
    IQCropViewEdge _beginEdge;
}

@synthesize aspectSize = _aspectSize;

-(void)initialize
{
    _shapeLayer = [[CAShapeLayer alloc] init];
    [_shapeLayer setFillRule:kCAFillRuleEvenOdd];
    [_shapeLayer setFillColor:[UIColor colorWithWhite:0.0 alpha:0.7].CGColor];
    [_shapeLayer setFrame:self.bounds];
    [self.layer addSublayer:_shapeLayer];

    UIColor *originalThemeColor = [UIColor originalThemeColor];

    _innerCropperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_innerCropperView.layer setBorderColor:originalThemeColor.CGColor];
    [_innerCropperView.layer setBorderWidth:1.0];
    [self addSubview:_innerCropperView];
    
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizerAction:)];
    [self addGestureRecognizer:panRecognizer];

    {
        /*-Top Left-*/
        _tl1 = [[UIView alloc] init];
        _tl1.backgroundColor = originalThemeColor;
        [self addSubview:_tl1];
        
        _tl2 = [[UIView alloc] init];
        _tl2.backgroundColor = originalThemeColor;
        [self addSubview:_tl2];

        /*-Top Right-*/
        _tr1 = [[UIView alloc] init];
        _tr1.backgroundColor = originalThemeColor;
        [self addSubview:_tr1];
        
        _tr2 = [[UIView alloc] init];
        _tr2.backgroundColor = originalThemeColor;
        [self addSubview:_tr2];

        /*-Bottom Left-*/
        _bl1 = [[UIView alloc] init];
        _bl1.backgroundColor = originalThemeColor;
        [self addSubview:_bl1];
        
        _bl2 = [[UIView alloc] init];
        _bl2.backgroundColor = originalThemeColor;
        [self addSubview:_bl2];

        /*-Bottom Right-*/
        _br1 = [[UIView alloc] init];
        _br1.backgroundColor = originalThemeColor;
        [self addSubview:_br1];
        
        _br2 = [[UIView alloc] init];
        _br2.backgroundColor = originalThemeColor;
        [self addSubview:_br2];
    }
    
//    _cropRect = self.cropBounds;
    
    _leftVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_innerCropperView.bounds)*2/3, 0, 1, CGRectGetHeight(_innerCropperView.bounds))];
    [_leftVerticalLine setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight)];
    [_leftVerticalLine setBackgroundColor:[originalThemeColor colorWithAlphaComponent:0.2]];
    [_innerCropperView addSubview:_leftVerticalLine];
    
    _rightVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_innerCropperView.bounds)/3, 0, 1, CGRectGetHeight(_innerCropperView.bounds))];
    [_rightVerticalLine setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight)];
    [_rightVerticalLine setBackgroundColor:[originalThemeColor colorWithAlphaComponent:0.2]];
    [_innerCropperView addSubview:_rightVerticalLine];
    
    _topHorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_innerCropperView.bounds)/3, CGRectGetWidth(_innerCropperView.bounds), 1)];
    [_topHorizontalLine setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth)];
    [_topHorizontalLine setBackgroundColor:[originalThemeColor colorWithAlphaComponent:0.2]];
    [_innerCropperView addSubview:_topHorizontalLine];
    
    _bottomHorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_innerCropperView.bounds)*2/3, CGRectGetWidth(_innerCropperView.bounds), 1)];
    [_bottomHorizontalLine setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth)];
    [_bottomHorizontalLine setBackgroundColor:[originalThemeColor colorWithAlphaComponent:0.2]];
    [_innerCropperView addSubview:_bottomHorizontalLine];
}

-(CGRect)cropBounds
{
    return UIEdgeInsetsInsetRect(self.bounds, self.edgeInset);
}

-(void)setCropRect:(CGRect)cropRect
{
    [self setCropRect:cropRect animated:NO];
}

-(void)updateCropRectAnimated:(BOOL)animated
{
    [self setCropRect:_cropRect animated:YES];
}

-(void)setCropRect:(CGRect)cropRect animated:(BOOL)animated
{
    _cropRect = cropRect;
    
    {
        _cropRect = CGRectIntersection(self.cropBounds, _cropRect);
        _cropRect = CGRectIntersection(self.bounds, _cropRect);
    }

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:animated?0.3:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

        weakSelf.innerCropperView.frame = weakSelf.cropRect;
        
        {
            CGFloat widthHeight = 2;
            
            /*-Top Left-*/
            weakSelf.tl1.frame = CGRectMake(CGRectGetMinX(weakSelf.cropRect)-widthHeight, CGRectGetMinY(weakSelf.cropRect)-widthHeight, 20, widthHeight);
            weakSelf.tl2.frame = CGRectMake(CGRectGetMinX(weakSelf.cropRect)-widthHeight, CGRectGetMinY(weakSelf.cropRect)-widthHeight, widthHeight, 20);
            
            /*-Top Right-*/
            weakSelf.tr1.frame = CGRectMake(CGRectGetMaxX(weakSelf.cropRect)-20+widthHeight, CGRectGetMinY(weakSelf.cropRect)-widthHeight, 20, widthHeight);
            weakSelf.tr2.frame = CGRectMake(CGRectGetMaxX(weakSelf.cropRect),CGRectGetMinY(weakSelf.cropRect)-widthHeight, widthHeight, 20);
            
            /*-Bottom Left-*/
            weakSelf.bl1.frame = CGRectMake(CGRectGetMinX(weakSelf.cropRect)-widthHeight, CGRectGetMaxY(weakSelf.cropRect), 20, widthHeight);
            weakSelf.bl2.frame = CGRectMake(CGRectGetMinX(weakSelf.cropRect)-widthHeight, CGRectGetMaxY(weakSelf.cropRect)-20+widthHeight, widthHeight, 20);
            
            /*-Bottom Right-*/
            weakSelf.br1.frame = CGRectMake(CGRectGetMaxX(weakSelf.cropRect)-20+widthHeight, CGRectGetMaxY(weakSelf.cropRect), 20, widthHeight);
            weakSelf.br2.frame = CGRectMake(CGRectGetMaxX(weakSelf.cropRect),CGRectGetMaxY(weakSelf.cropRect)-20+widthHeight, widthHeight, 20);
        }
        
        {
            [weakSelf.leftVerticalLine setFrame:CGRectMake(CGRectGetWidth(weakSelf.innerCropperView.bounds)*2/3, 0, 1, CGRectGetHeight(weakSelf.innerCropperView.bounds))];
            [weakSelf.rightVerticalLine setFrame:CGRectMake(CGRectGetWidth(weakSelf.innerCropperView.bounds)/3, 0, 1, CGRectGetHeight(weakSelf.innerCropperView.bounds))];
            [weakSelf.topHorizontalLine setFrame:CGRectMake(0,CGRectGetHeight(weakSelf.innerCropperView.bounds)/3, CGRectGetWidth(weakSelf.innerCropperView.bounds), 1)];
            [weakSelf.bottomHorizontalLine setFrame:CGRectMake(0,CGRectGetHeight(weakSelf.innerCropperView.bounds)*2/3, CGRectGetWidth(weakSelf.innerCropperView.bounds), 1)];
        }
        
        {
            UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
            [bezierPath appendPath:[UIBezierPath bezierPathWithRect:weakSelf.bounds]];
            [bezierPath appendPath:[UIBezierPath bezierPathWithRect:weakSelf.innerCropperView.frame]];

            if (animated)
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
                animation.duration = 0.3;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [weakSelf.shapeLayer addAnimation:animation forKey:@"pathAnimation"];
            }

            [weakSelf.shapeLayer setPath:bezierPath.CGPath];
        }
    } completion:^(BOOL finished) {

        if ([weakSelf.delegate respondsToSelector:@selector(cropViewDidChangedCropRect:)])
        {
            [weakSelf.delegate cropViewDidChangedCropRect:weakSelf];
        }
    }];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _shapeLayer.frame = self.bounds;
}

//-(void)dealloc
//{
//}

-(void)setAspectSize:(IQ_IQAspectSize)aspectSize
{
    _aspectSize = aspectSize;
    
    CGRect newRect;
    
    CGRect cropBounds = self.cropBounds;
    
    CGFloat width = CGRectGetWidth(cropBounds);
    CGFloat height = CGRectGetHeight(cropBounds);
    
    BOOL isWidthMinimum = (MIN(width, height) == width);
    
    switch (aspectSize)
    {
        case IQ_IQAspectSizeOriginal:
            newRect = cropBounds;
            break;
            
        case IQ_IQAspectSizeSquare:
        {
            if (isWidthMinimum) newRect = IQRectSetCenter(CGRectMake(0, 0, width, width), IQRectGetCenter(cropBounds));
            else                newRect = IQRectSetCenter(CGRectMake(0, 0, height, height), IQRectGetCenter(cropBounds));
        }
            break;
            
            
        case IQ_IQAspectSize3x4:
        {
            if (isWidthMinimum)
            {
                CGFloat suggestedHeight = MIN(height, width*4/3);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedHeight*3/4, suggestedHeight), IQRectGetCenter(cropBounds));
            }
            else
                newRect = IQRectSetCenter(CGRectMake(0, 0, height*3/4, height), IQRectGetCenter(cropBounds));
        }
            break;
            
        case IQ_IQAspectSize2x3:
        {
            if (isWidthMinimum)
            {
                CGFloat suggestedHeight = MIN(height, width*3/2);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedHeight*2/3, suggestedHeight), IQRectGetCenter(cropBounds));
            }
            else
                newRect = IQRectSetCenter(CGRectMake(0, 0, height*2/3, height), IQRectGetCenter(cropBounds));
        }
            break;
            
        case IQ_IQAspectSize5x7:
        {
            if (isWidthMinimum)
            {
                CGFloat suggestedHeight = MIN(height, width*7/5);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedHeight*5/7, suggestedHeight), IQRectGetCenter(cropBounds));
            }
            else
                newRect = IQRectSetCenter(CGRectMake(0, 0, height*5/7, height), IQRectGetCenter(cropBounds));
        }
            break;
            
        case IQ_IQAspectSize4x5:
        {
            if (isWidthMinimum)
            {
                CGFloat suggestedHeight = MIN(height, width*5/4);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedHeight*4/5, suggestedHeight), IQRectGetCenter(cropBounds));
            }
            else
                newRect = IQRectSetCenter(CGRectMake(0, 0, height*4/5, height), IQRectGetCenter(cropBounds));
        }
            break;
            
        case IQ_IQAspectSize9x16:
        {
            if (isWidthMinimum)
            {
                CGFloat suggestedHeight = MIN(height, width*16/9);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedHeight*9/16, suggestedHeight), IQRectGetCenter(cropBounds));
            }
            else
                newRect = IQRectSetCenter(CGRectMake(0, 0, height*9/16, height), IQRectGetCenter(cropBounds));
        }
            break;
            
        case IQ_IQAspectSize1x235:
        {
            if (isWidthMinimum)
            {
                CGFloat suggestedHeight = MIN(height, width*2.35);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedHeight*1/2.35, suggestedHeight), IQRectGetCenter(cropBounds));
            }
            else
                newRect = IQRectSetCenter(CGRectMake(0, 0, height*1/2.35, height), IQRectGetCenter(cropBounds));
        }
            break;
            
        case IQ_IQAspectSize4x3:
        {
            if (isWidthMinimum)
                newRect = IQRectSetCenter(CGRectMake(0, 0, width, width*3/4), IQRectGetCenter(cropBounds));
            else
            {
                CGFloat suggestedWidth = MIN(width, height*4/3);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedWidth, suggestedWidth*3/4), IQRectGetCenter(cropBounds));
            }
        }
            break;
            
        case IQ_IQAspectSize3x2:
        {
            if (isWidthMinimum)
                newRect = IQRectSetCenter(CGRectMake(0, 0, width, width*2/3), IQRectGetCenter(cropBounds));
            else
            {
                CGFloat suggestedWidth = MIN(width, height*3/2);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedWidth, suggestedWidth*2/3), IQRectGetCenter(cropBounds));
            }
        }
            break;
            
        case IQ_IQAspectSize7x5:
        {
            if (isWidthMinimum)
                newRect = IQRectSetCenter(CGRectMake(0, 0, width, width*5/7), IQRectGetCenter(cropBounds));
            else
            {
                CGFloat suggestedWidth = MIN(width, height*7/5);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedWidth, suggestedWidth*5/7), IQRectGetCenter(cropBounds));
            }
        }
            break;
            
        case IQ_IQAspectSize5x4:
        {
            if (isWidthMinimum)
                newRect = IQRectSetCenter(CGRectMake(0, 0, width, width*4/5), IQRectGetCenter(cropBounds));
            else
            {
                CGFloat suggestedWidth = MIN(width, height*5/4);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedWidth, suggestedWidth*4/5), IQRectGetCenter(cropBounds));
            }
        }
            break;
            
        case IQ_IQAspectSize16x9:
        {
            if (isWidthMinimum)
                newRect = IQRectSetCenter(CGRectMake(0, 0, width, width*9/16), IQRectGetCenter(cropBounds));
            else
            {
                CGFloat suggestedWidth = MIN(width, height*16/9);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedWidth, suggestedWidth*9/16), IQRectGetCenter(cropBounds));
            }
        }
            break;
            
        case IQ_IQAspectSize235x1:
        {
            if (isWidthMinimum)
                newRect = IQRectSetCenter(CGRectMake(0, 0, width, width*1/2.35), IQRectGetCenter(cropBounds));
            else
            {
                CGFloat suggestedWidth = MIN(width, height*2.35);
                newRect = IQRectSetCenter(CGRectMake(0, 0, suggestedWidth, suggestedWidth*1/2.35), IQRectGetCenter(cropBounds));
            }
        }
            break;
            
        default:
            break;
    }
    
    [self setCropRect:newRect animated:YES];
}

-(void)panRecognizerAction:(UIPanGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:self];

    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _beginTouchPoint = location;
        _beginRect =_cropRect;
        _beginEdge = [self cropEdgeForPoint:location];
    }

    CGRect newFrame = _beginRect;
    
    CGPoint pointDiff = CGPointMake(location.x - _beginTouchPoint.x, location.y - _beginTouchPoint.y);
    
    CGFloat minWidthHeight = 50;
    
    switch (_beginEdge)
    {
        case IQCropViewEdgeTopLeft:
        {
            newFrame.origin.x += pointDiff.x;
            newFrame.origin.y += pointDiff.y;
            newFrame.size.width = MAX(0,newFrame.size.width-pointDiff.x);
            newFrame.size.height = MAX(0,newFrame.size.height-pointDiff.y);
            
            if (newFrame.size.width<minWidthHeight)
            {
                newFrame.origin.x = CGRectGetMaxX(_beginRect)-minWidthHeight;
                newFrame.size.width = minWidthHeight;
            }
            
            if (newFrame.size.height<minWidthHeight)
            {
                newFrame.origin.y = CGRectGetMaxY(_beginRect)-minWidthHeight;
                newFrame.size.height = minWidthHeight;
            }
        }
            break;
        case IQCropViewEdgeTopRight:
        {
            newFrame.origin.y += pointDiff.y;
            newFrame.size.width = MAX(0,newFrame.size.width+pointDiff.x);
            newFrame.size.height = MAX(0,newFrame.size.height-pointDiff.y);

            if (newFrame.size.width<minWidthHeight)
                newFrame.size.width = minWidthHeight;

            if (newFrame.size.height<minWidthHeight)
            {
                newFrame.origin.y = CGRectGetMaxY(_beginRect)-minWidthHeight;
                newFrame.size.height = minWidthHeight;
            }
        }
            break;
        case IQCropViewEdgeBottomLeft:
        {
            newFrame.origin.x += pointDiff.x;
            newFrame.size.width = MAX(0,newFrame.size.width-pointDiff.x);
            newFrame.size.height = MAX(0,newFrame.size.height+pointDiff.y);

            if (newFrame.size.width<minWidthHeight)
            {
                newFrame.origin.x = CGRectGetMaxX(_beginRect)-minWidthHeight;
                newFrame.size.width = minWidthHeight;
            }

            if (newFrame.size.height<minWidthHeight)
                newFrame.size.height = minWidthHeight;
        }
            break;
        case IQCropViewEdgeBottomRight:
        {
            newFrame.size.width = MAX(0,newFrame.size.width+pointDiff.x);
            newFrame.size.height = MAX(0,newFrame.size.height+pointDiff.y);

            if (newFrame.size.width<minWidthHeight)
                newFrame.size.width = minWidthHeight;
            if (newFrame.size.height<minWidthHeight)
                newFrame.size.height = minWidthHeight;
        }
            break;
        case IQCropViewEdgeTop:
        {
            newFrame.origin.y += pointDiff.y;
            newFrame.size.height = MAX(0,newFrame.size.height-pointDiff.y);

            if (newFrame.size.height<minWidthHeight)
            {
                newFrame.origin.y = CGRectGetMaxY(_beginRect)-minWidthHeight;
                newFrame.size.height = minWidthHeight;
            }
        }
            break;
        case IQCropViewEdgeBottom:
        {
            newFrame.size.height = MAX(0,newFrame.size.height+pointDiff.y);

            if (newFrame.size.height<minWidthHeight)
                newFrame.size.height = minWidthHeight;
        }
            break;
        case IQCropViewEdgeLeft:
        {
            newFrame.origin.x += pointDiff.x;
            newFrame.size.width = MAX(0,newFrame.size.width-pointDiff.x);

            if (newFrame.size.width<minWidthHeight)
            {
                newFrame.origin.x = CGRectGetMaxX(_beginRect)-minWidthHeight;
                newFrame.size.width = minWidthHeight;
            }
        }
            break;
        case IQCropViewEdgeRight:
        {
            newFrame.size.width = MAX(0,newFrame.size.width+pointDiff.x);

            if (newFrame.size.width<minWidthHeight)
            {
                newFrame.origin.x = CGRectGetMaxX(_beginRect)-minWidthHeight;
                newFrame.size.width = minWidthHeight;
            }
        }
            break;
        case IQCropViewEdgeNone:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    self.cropRect = newFrame;
}

- (IQCropViewEdge)cropEdgeForPoint:(CGPoint)point
{
    CGRect frame = self.cropRect;
    
    //account for padding around the box
    frame = CGRectInset(frame, -32.0f, -32.0f);
    
    //Make sure the corners take priority
    CGRect topLeftRect = (CGRect){frame.origin, {64,64}};
    if (CGRectContainsPoint(topLeftRect, point))
        return IQCropViewEdgeTopLeft;
    
    CGRect topRightRect = topLeftRect;
    topRightRect.origin.x = CGRectGetMaxX(frame) - 64.0f;
    if (CGRectContainsPoint(topRightRect, point))
        return IQCropViewEdgeTopRight;
    
    CGRect bottomLeftRect = topLeftRect;
    bottomLeftRect.origin.y = CGRectGetMaxY(frame) - 64.0f;
    if (CGRectContainsPoint(bottomLeftRect, point))
        return IQCropViewEdgeBottomLeft;
    
    CGRect bottomRightRect = topRightRect;
    bottomRightRect.origin.y = bottomLeftRect.origin.y;
    if (CGRectContainsPoint(bottomRightRect, point))
        return IQCropViewEdgeBottomRight;
    
    //Check for edges
    CGRect topRect = (CGRect){frame.origin, {CGRectGetWidth(frame), 64.0f}};
    if (CGRectContainsPoint(topRect, point))
        return IQCropViewEdgeTop;
    
    CGRect bottomRect = topRect;
    bottomRect.origin.y = CGRectGetMaxY(frame) - 64.0f;
    if (CGRectContainsPoint(bottomRect, point))
        return IQCropViewEdgeBottom;
    
    CGRect leftRect = (CGRect){frame.origin, {64.0f, CGRectGetHeight(frame)}};
    if (CGRectContainsPoint(leftRect, point))
        return IQCropViewEdgeLeft;
    
    CGRect rightRect = leftRect;
    rightRect.origin.x = CGRectGetMaxX(frame) - 64.0f;
    if (CGRectContainsPoint(rightRect, point))
        return IQCropViewEdgeRight;
    
    return IQCropViewEdgeNone;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    IQCropViewEdge edge = [self cropEdgeForPoint:point];
    
    return (edge != IQCropViewEdgeNone);
}

@end
