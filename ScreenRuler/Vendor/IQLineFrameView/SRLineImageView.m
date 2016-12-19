//
//  SRLineView.m
//  Screen Ruler
//
//  Created by IEMacBook02 on 06/11/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import "SRLineImageView.h"
#import "NSMutableArray+Stack.h"
#import "IQRulerScrollView.h"
#import "UIScrollView+Addition.h"

@implementation SRLineImageView
{
    NSMutableArray<CALayer *> *cachedHorizontalLineLayers;
    NSMutableArray<CALayer *> *cachedVerticalLineLayers;
    NSMutableArray<CALayer *> *inUseHorizontalLineLayers;
    NSMutableArray<CALayer *> *inUseVerticalLineLayers;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

-(void)initialize
{
    _zoomScale = 1;
    _deviceScale = 1;
    _hideLine = YES;
    
    cachedHorizontalLineLayers = [[NSMutableArray alloc] init];
    cachedVerticalLineLayers = [[NSMutableArray alloc] init];
    inUseHorizontalLineLayers = [[NSMutableArray alloc] init];
    inUseVerticalLineLayers = [[NSMutableArray alloc] init];
    
    [self updateUIAnimated:NO];
}

-(void)setHideLine:(BOOL)hideLine
{
    _hideLine = hideLine;
    
    [self updateUIAnimated:YES];
}

#pragma mark - Overrided methods

-(void)setZoomScale:(CGFloat)zoomScale
{
    [self setZoomScale:zoomScale animated:NO];
}

-(void)setZoomScale:(CGFloat)zoomScale animated:(BOOL)animated
{
    _zoomScale = zoomScale;
    
    [self updateUIAnimated:animated];
}

-(void)setDeviceScale:(CGFloat)deviceScale
{
    _deviceScale = deviceScale;
    
    [self updateUIAnimated:YES];
}

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    
    CGColorRef colorRefAlpha = [lineColor colorWithAlphaComponent:0.5].CGColor;
    
    NSMutableArray<CALayer*> *linelayers = [[NSMutableArray alloc] init];
    [linelayers addObjectsFromArray:cachedHorizontalLineLayers];
    [linelayers addObjectsFromArray:cachedVerticalLineLayers];
    [linelayers addObjectsFromArray:inUseHorizontalLineLayers];
    [linelayers addObjectsFromArray:inUseVerticalLineLayers];
    
    for (CALayer *layer in linelayers)
    {
        layer.backgroundColor = colorRefAlpha;
    }
}

-(void)setStartingScalePoint:(CGPoint)startingScalePoint
{
    _startingScalePoint = startingScalePoint;
    
    [self updateUIAnimated:NO];
}

-(void)updateUIAnimated:(BOOL)animated
{
    NSMutableArray *currentHorizontalLines = [inUseHorizontalLineLayers mutableCopy];
    NSMutableArray *currentVerticalLines = [inUseVerticalLineLayers mutableCopy];
    
    if (_hideLine == NO && self.image)
    {
        if (animated)
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.3];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [CATransaction setDisableActions:NO];
        }
        else
        {
            [CATransaction setDisableActions:YES];
        }
        
        IQRulerScrollView *scrollView = [self rulerView];
        
        CGRect newRect = self.bounds;
        
        if (scrollView)
        {
            CGSize insetSize = CGSizeMake(-self.scaleMargin.width, -self.scaleMargin.height);
            
            CGRect visibleRect = [scrollView visibleRectWithInsetSize:insetSize];
            CGRect presentationRect = [scrollView presentationLayerVisibleRectWithInsetSize:insetSize];
            
            newRect.origin.x = MIN(CGRectGetMinX(visibleRect), CGRectGetMinX(presentationRect));
            newRect.origin.y = MIN(CGRectGetMinY(visibleRect), CGRectGetMinY(presentationRect));
            newRect.size.width = MAX(CGRectGetWidth(visibleRect), CGRectGetWidth(presentationRect));
            newRect.size.height = MAX(CGRectGetHeight(visibleRect), CGRectGetHeight(presentationRect));
            newRect.size.width += visibleRect.origin.x-newRect.origin.x;
            newRect.size.height += visibleRect.origin.y-newRect.origin.y;
        }
        
        NSInteger multiplier = 1;
        
        if (self.zoomScale >= 4)
        {
            multiplier = 1;
        }
        else if (self.zoomScale >= 0.4)
        {
            multiplier = 10;
        }
        else if (self.zoomScale >= 0.04)
        {
            multiplier = 100;
        }
        else if (self.zoomScale >= 0.004)
        {
            multiplier = 1000;
        }
        else
        {
            multiplier = 10000;
        }
        
        NSInteger singleStep = multiplier*_deviceScale;
        
        CGPoint respectivePoint = self.startingScalePoint;

        CGFloat  minX = CGRectGetMinX(newRect);
        CGFloat  minY = CGRectGetMinY(newRect);
        CGFloat  maxX = CGRectGetMaxX(newRect);
        CGFloat  maxY = CGRectGetMaxY(newRect);
        CGFloat  width = newRect.size.width;
        CGFloat  height = newRect.size.height;
        
        CGFloat thikness = (1/_zoomScale);
        
        {
            CGColorRef colorRefAlpha = [self.lineColor colorWithAlphaComponent:0.5].CGColor;
            
            //Horizontal Lines
            {
                NSInteger currentStep = respectivePoint.y;
                
                NSInteger i = 0;
                
                while (currentStep >= minY)
                {
                    currentStep -= singleStep;
                    i--;
                }
                
                while (currentStep <= minY)
                {
                    currentStep += singleStep;
                    i++;
                }
                
                for ( ; currentStep<=maxY; currentStep+=singleStep, i ++)
                {
                    CALayer *layer = [currentHorizontalLines pop];
                    
                    if (layer == nil)
                    {
                        layer = [cachedHorizontalLineLayers pop];
                        
                        if (layer)
                        {
                            [inUseHorizontalLineLayers push:layer];
                            [self.layer addSublayer:layer];
                        }
                    }
                    
                    if (layer == nil)
                    {
                        layer = [[CALayer alloc] init];
                        layer.actions = @{@"frame":[NSNull null],
                                          @"transform":[NSNull null],
                                          @"bounds":[NSNull null],
                                          @"position":[NSNull null],
                                          @"opacity":[NSNull null]};
                        layer.contentsScale = [[UIScreen mainScreen] scale];
                        layer.backgroundColor = colorRefAlpha;
                        [inUseHorizontalLineLayers push:layer];
                        [self.layer addSublayer:layer];
                    }
                    
                    layer.frame = CGRectMake(minX, currentStep-(thikness/2), width, thikness);
                    
                    NSInteger currentStepWithOffset = currentStep-respectivePoint.y;

                    if ((currentStepWithOffset % (singleStep*10) == 0))
                    {
                        layer.opacity = 1;
                    }
                    else
                    {
                        CGFloat value = _zoomScale*multiplier;
                        layer.opacity = (value-4)/(40.0-4);
                    }
                }
            }
            
            //Vertical lines
            {
                NSInteger currentStep = respectivePoint.x;
                
                NSInteger i = 0;
                
                while (currentStep >= minX)
                {
                    currentStep -= singleStep;
                    i--;
                }
                
                while (currentStep <= minX)
                {
                    currentStep += singleStep;
                    i++;
                }
                
                for (; currentStep <= maxX; currentStep+=singleStep, i++)
                {
                    CALayer *layer = [currentVerticalLines pop];
                    
                    if (layer == nil)
                    {
                        layer = [cachedVerticalLineLayers pop];
                        
                        if (layer)
                        {
                            [inUseVerticalLineLayers push:layer];
                            [self.layer addSublayer:layer];
                        }
                    }
                    
                    if (layer == nil)
                    {
                        layer = [[CALayer alloc] init];
                        layer.actions = @{@"frame":[NSNull null],
                                          @"transform":[NSNull null],
                                          @"bounds":[NSNull null],
                                          @"position":[NSNull null],
                                          @"opacity":[NSNull null]};
                        layer.contentsScale = [[UIScreen mainScreen] scale];
                        layer.backgroundColor = colorRefAlpha;
                        [inUseVerticalLineLayers push:layer];
                        [self.layer addSublayer:layer];
                    }
                    
                    layer.frame = CGRectMake(currentStep-(thikness/2), minY, thikness, height);
                    
                    NSInteger currentStepWithOffset = currentStep-respectivePoint.x;
                    
                    if (currentStepWithOffset % (singleStep*10) == 0)
                    {
                        layer.opacity = 1;
                    }
                    else
                    {
                        CGFloat value = _zoomScale*multiplier;
                        layer.opacity = (value-4)/(40.0-4);
                    }
                }
            }
        }
        
        if (animated)
        {
            [CATransaction commit];
        }
    }

    for (CALayer *layer in currentHorizontalLines)
    {
        [inUseHorizontalLineLayers removeObject:layer];
        [layer removeFromSuperlayer];
    }
    
    for (CALayer *layer in currentVerticalLines)
    {
        [inUseVerticalLineLayers removeObject:layer];
        [layer removeFromSuperlayer];
    }
    
    [cachedHorizontalLineLayers addObjectsFromArray:currentHorizontalLines];
    [cachedVerticalLineLayers addObjectsFromArray:currentVerticalLines];
    
}

-(id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    if (layer == self.layer)
    {
        return nil;
    }
    else
    {
        return [NSNull null];
    }
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
//{
//    if (backgroundLayer.superlayer)
//    {
//        bool isEventOdd = backgroundLayer.fillRule == kCAFillRuleEvenOdd;
//        
//        bool result = CGPathContainsPoint(backgroundLayer.path,
//                                          NULL, point, isEventOdd);
//        
//        return result;
//    }
//    else
//    {
//        return NO;
//    }
//}

@end
