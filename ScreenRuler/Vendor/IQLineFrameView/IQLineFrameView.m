//
//  IQLineFrameView.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQLineFrameView.h"
#import "UIColor+HexColors.h"

CGFloat const lineAlpha = 0.5;

CGFloat const longLineHeight = 8;
CGFloat const mediumLineHeight = 6;
CGFloat const shortLineHeight = 4;

@implementation NSMutableArray (Stack)

-(void)push:(id)object
{
    [self addObject:object];
}

-(void)pushObjects:(NSArray*)objects
{
    [self addObjectsFromArray:objects];
}

-(id)pop
{
    id object = [self lastObject];
    [self removeLastObject];
    return object;
}

@end


typedef NS_ENUM(NSUInteger, PositionSelector) {
    PositionSelectorNone,
    PositionSelectorX,
    PositionSelectorY,
};

@implementation IQLineFrameView
{
    CGPoint _startingScalePointAtBegin;
    
    UIPanGestureRecognizer *panGesture;
    UILongPressGestureRecognizer *longPressGesture;
    
    CAShapeLayer *backgroundLayer;

    NSMutableArray<CALayer *> *cachedHorizontalLineLayers;
    NSMutableArray<CALayer *> *cachedVerticalLineLayers;
    NSMutableArray<CALayer *> *inUseHorizontalLineLayers;
    NSMutableArray<CALayer *> *inUseVerticalLineLayers;
    
    NSMutableArray<CATextLayer *> *cachedHorizontalTextLineLayers;
    NSMutableArray<CATextLayer *> *cachedVerticalTextLineLayers;
    NSMutableArray<CATextLayer *> *inUseHorizontalTextLineLayers;
    NSMutableArray<CATextLayer *> *inUseVerticalTextLineLayers;
    
    NSMutableArray<CALayer *> *cachedHorizontalShortLineLayers;
    NSMutableArray<CALayer *> *cachedVerticalShortLineLayers;
    NSMutableArray<CALayer *> *inUseHorizontalShortLineLayers;
    NSMutableArray<CALayer *> *inUseVerticalShortLineLayers;
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

    cachedHorizontalLineLayers = [[NSMutableArray alloc] init];
    cachedVerticalLineLayers = [[NSMutableArray alloc] init];
    inUseHorizontalLineLayers = [[NSMutableArray alloc] init];
    inUseVerticalLineLayers = [[NSMutableArray alloc] init];

    cachedHorizontalTextLineLayers = [[NSMutableArray alloc] init];
    cachedVerticalTextLineLayers = [[NSMutableArray alloc] init];
    inUseHorizontalTextLineLayers = [[NSMutableArray alloc] init];
    inUseVerticalTextLineLayers = [[NSMutableArray alloc] init];

    cachedHorizontalShortLineLayers = [[NSMutableArray alloc] init];
    cachedVerticalShortLineLayers = [[NSMutableArray alloc] init];
    inUseHorizontalShortLineLayers = [[NSMutableArray alloc] init];
    inUseVerticalShortLineLayers = [[NSMutableArray alloc] init];

    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizer:)];
    [self addGestureRecognizer:panGesture];

    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
    [self addGestureRecognizer:longPressGesture];

    backgroundLayer = [[CAShapeLayer alloc] init];
    backgroundLayer.lineWidth = 1.0;
    [backgroundLayer setFillRule:kCAFillRuleEvenOdd];
    [backgroundLayer setFillColor:self.rulerColor.CGColor];
    backgroundLayer.strokeColor = self.lineColor.CGColor;
    [self.layer insertSublayer:backgroundLayer atIndex:0];
    
    [self updateUIAnimated:NO];
}

#pragma mark - Overrided methods

-(void)setRespectiveView:(UIView *)respectiveView
{
    _respectiveView = respectiveView;

    [self updateUIAnimated:NO];
}

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

-(void)setInset:(UIEdgeInsets)inset
{
    _inset = inset;
}

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    
    backgroundLayer.strokeColor = _lineColor.CGColor;

    CGColorRef colorRef = lineColor.CGColor;
    CGColorRef colorRefAlpha = [lineColor colorWithAlphaComponent:lineAlpha].CGColor;
    
    NSMutableArray<CALayer*> *linelayers = [[NSMutableArray alloc] init];
    [linelayers addObjectsFromArray:cachedHorizontalLineLayers];
    [linelayers addObjectsFromArray:cachedVerticalLineLayers];
    [linelayers addObjectsFromArray:inUseHorizontalLineLayers];
    [linelayers addObjectsFromArray:inUseVerticalLineLayers];

    for (CALayer *layer in linelayers)
    {
        layer.backgroundColor = colorRefAlpha;
    }
    
    NSMutableArray<CALayer*> *scaleLinelayers = [[NSMutableArray alloc] init];
    [scaleLinelayers addObjectsFromArray:cachedHorizontalShortLineLayers];
    [scaleLinelayers addObjectsFromArray:cachedVerticalShortLineLayers];
    [scaleLinelayers addObjectsFromArray:inUseHorizontalShortLineLayers];
    [scaleLinelayers addObjectsFromArray:inUseVerticalShortLineLayers];
    
    for (CALayer *layer in scaleLinelayers)
    {
        layer.backgroundColor = colorRef;
    }
    
    NSMutableArray<CATextLayer*> *textLayers = [[NSMutableArray alloc] init];
    [textLayers addObjectsFromArray:cachedHorizontalTextLineLayers];
    [textLayers addObjectsFromArray:cachedVerticalTextLineLayers];
    [textLayers addObjectsFromArray:inUseHorizontalTextLineLayers];
    [textLayers addObjectsFromArray:inUseVerticalTextLineLayers];

    for (CATextLayer *layer in textLayers)
    {
        layer.foregroundColor = colorRef;
    }
}

-(void)setHideRuler:(BOOL)hideRuler
{
    _hideRuler = hideRuler;
    [self updateUIAnimated:YES];
}

-(void)setHideLine:(BOOL)hideLine
{
    _hideLine = hideLine;
    
    [self updateUIAnimated:YES];
}

-(void)setStartingScalePoint:(CGPoint)startingScalePoint
{
    _startingScalePoint = startingScalePoint;
    
    [self updateUIAnimated:NO];
}

-(void)setRulerColor:(UIColor *)rulerColor
{
    _rulerColor = rulerColor;
    backgroundLayer.fillColor = _rulerColor.CGColor;
}

-(void)longPressRecognizer:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        UIResponder *nextResponder =  self;
        
        do
        {
            nextResponder = [nextResponder nextResponder];
            
            if ([nextResponder isKindOfClass:[UIViewController class]])
            {
                break;
            }
            
        } while (nextResponder != nil);

        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Set Scale point location", nil) preferredStyle:UIAlertControllerStyleActionSheet];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reset Scale to Original", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                self.startingScalePoint = CGPointZero;
            }]];
            
            CGPoint point = [gesture locationInView:self];

            
            PositionSelector position = PositionSelectorNone;

            if (point.x <= 20 || point.x >= (self.frame.size.width-20))
            {
                position = PositionSelectorY;
            }
            else if (point.y <= 20 || point.y >= (self.frame.size.height-20))
            {
                position = PositionSelectorX;
            }

            
            [alertController addAction:[UIAlertAction actionWithTitle:(position == PositionSelectorX? NSLocalizedString(@"Mark as X reference", nil):NSLocalizedString(@"Mark as Y reference", nil)) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                CGPoint referencePoint = [self convertPoint:point toView:self.respectiveView];
                
                if (position == PositionSelectorY)
                {
                    CGPoint scalePoint = self.startingScalePoint;
                    scalePoint.y = roundf(referencePoint.y);
                    self.startingScalePoint = scalePoint;
                }
                else if (position == PositionSelectorX)
                {
                    CGPoint scalePoint = self.startingScalePoint;
                    scalePoint.x = roundf(referencePoint.x);
                    self.startingScalePoint = scalePoint;
                }
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            alertController.popoverPresentationController.sourceView = gesture.view;
            
            CGPoint touchPoint = [gesture locationInView:gesture.view];
            alertController.popoverPresentationController.sourceRect = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);

            [(UIViewController*)nextResponder presentViewController:alertController animated:YES completion:^{
            }];
        }
    }
}

-(void)panRecognizer:(UIPanGestureRecognizer*)gesture
{
    static PositionSelector position = PositionSelectorNone;

    CGPoint translation = [gesture translationInView:self.respectiveView];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _startingScalePointAtBegin = self.startingScalePoint;
        
        CGPoint point = [gesture locationInView:self];

        if (point.x <= 20 || point.x >= (self.frame.size.width-20))
        {
            position = PositionSelectorY;
            
            CGPoint scalePoint = self.startingScalePoint;
            scalePoint.y = _startingScalePointAtBegin.y + roundf(translation.y);
            self.startingScalePoint = scalePoint;
        }
        else if (point.y <= 20 || point.y >= (self.frame.size.height-20))
        {
            position = PositionSelectorX;

            CGPoint scalePoint = self.startingScalePoint;
            scalePoint.x = _startingScalePointAtBegin.x + roundf(translation.x);
            self.startingScalePoint = scalePoint;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        switch (position)
        {
            case PositionSelectorX:
            {
                CGPoint scalePoint = self.startingScalePoint;
                scalePoint.x = _startingScalePointAtBegin.x + roundf(translation.x);
                self.startingScalePoint = scalePoint;
            }
                break;
            case PositionSelectorY:
            {
                CGPoint scalePoint = self.startingScalePoint;
                scalePoint.y = _startingScalePointAtBegin.y + roundf(translation.y);
                self.startingScalePoint = scalePoint;
            }
                break;
            default:
                break;
        }
    }

    [self updateUIAnimated:NO];
}

-(void)updateUIAnimated:(BOOL)animated
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
    
    NSMutableArray *currentHorizontalLines = [inUseHorizontalLineLayers mutableCopy];
    NSMutableArray *currentVerticalLines = [inUseVerticalLineLayers mutableCopy];

    NSMutableArray *currentHorizontalTextLines = [inUseHorizontalTextLineLayers mutableCopy];
    NSMutableArray *currentVerticalTextLines = [inUseVerticalTextLineLayers mutableCopy];
    
    NSMutableArray *currentHorizontalShortLines = [inUseHorizontalShortLineLayers mutableCopy];
    NSMutableArray *currentVerticalShortLines = [inUseVerticalShortLineLayers mutableCopy];
    
    CGRect newRect = UIEdgeInsetsInsetRect(self.bounds, self.inset);

    CGSize scaleMargin = CGSizeMake(20, 20);

    if (_hideRuler == YES)
    {
        scaleMargin = CGSizeZero;
    }

    CGFloat multiplier = 1.0;
    
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
    
    multiplier *=_deviceScale;

    CGRect respectiveBounds = CGRectZero;
    
    if (_respectiveView)
    {
        respectiveBounds = [self.respectiveView convertRect:self.respectiveView.bounds toView:self];
    }
    else
    {
        respectiveBounds = newRect;
    }
    
    CGPoint respectivePoint = [self.respectiveView convertPoint:self.startingScalePoint toView:self];

    CGFloat singleStep = self.zoomScale*multiplier;
    
    CGFloat  minX = CGRectGetMinX(newRect)+scaleMargin.width;
    CGFloat  minY = CGRectGetMinY(newRect)+scaleMargin.height;
    CGFloat  maxX = CGRectGetMaxX(newRect)-scaleMargin.width;
    CGFloat  maxY = CGRectGetMaxY(newRect)-scaleMargin.height;
    CGFloat  width = newRect.size.width-scaleMargin.width*2;
    CGFloat  height = newRect.size.height-scaleMargin.height*2;

    if (_hideLine == NO)
    {
        CGColorRef colorRefAlpha = [self.lineColor colorWithAlphaComponent:lineAlpha].CGColor;

        //Horizontal Lines
        {
            CGFloat currentStep = respectivePoint.y;
            
            NSInteger i = 0;
            
            while (currentStep > 0)
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
                if (currentStep!=0)
                {
                    CALayer *layer = [currentHorizontalLines pop];
                    
                    if (layer == nil)
                    {
                        layer = [cachedHorizontalLineLayers pop];
                        
                        if (layer)
                        {
                            [inUseHorizontalLineLayers push:layer];
                            [self.layer insertSublayer:layer below:backgroundLayer];
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
                        [self.layer insertSublayer:layer below:backgroundLayer];
                    }
                    
                    layer.frame = CGRectMake(minX, currentStep-0.5, width, 1);
                    
                    if (i % 10 == 0)
                    {
                        layer.opacity = 10;
                    }
                    else
                    {
                        NSInteger minStep = 4*_deviceScale;
                        layer.opacity = (singleStep-minStep)/(minStep*9);
                    }
                }
            }
        }

        //Vertical lines
        {
            CGFloat currentStep = respectivePoint.x;
            
            NSInteger i = 0;
            
            while (currentStep > 0)
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
                if (currentStep!=0)
                {
                    CALayer *layer = [currentVerticalLines pop];
                    
                    if (layer == nil)
                    {
                        layer = [cachedVerticalLineLayers pop];
                        
                        if (layer)
                        {
                            [inUseVerticalLineLayers push:layer];
                            [self.layer insertSublayer:layer below:backgroundLayer];
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
                        [self.layer insertSublayer:layer below:backgroundLayer];
                    }

                    layer.frame = CGRectMake(currentStep-0.5, minY, 1, height);
                    
                    if (i % 10 == 0)
                    {
                        layer.opacity = 1.0;
                    }
                    else
                    {
                        NSInteger minStep = 4*_deviceScale;
                        layer.opacity = (singleStep-minStep)/(minStep*9);
                    }
                }
            }
        }
    }
    
    if (_hideRuler == NO)
    {
        //Background layer
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:newRect];
            UIBezierPath *innerPath = [UIBezierPath bezierPathWithRect:CGRectInset(newRect, scaleMargin.width, scaleMargin.height)];
            [path appendPath:innerPath];
            
//            if (animated)
//            {
//                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
//                animation.duration = 0.3;
//                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//                [backgroundLayer addAnimation:animation forKey:@"pathAnimation"];
//            }

            backgroundLayer.path = path.CGPath;
            backgroundLayer.opacity = 1.0;
        }
        
        //Horizontal Scale
        {
            CGFloat currentStep = respectivePoint.x;
            NSInteger i = 0;
            
            while (currentStep > 0)
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
                if (currentStep!=0)
                {
                    CALayer *layer1 = [currentHorizontalShortLines pop];
                    
                    if (layer1 == nil)
                    {
                        layer1 = [cachedHorizontalShortLineLayers pop];
                        
                        if (layer1)
                        {
                            [inUseHorizontalShortLineLayers push:layer1];
                            [self.layer insertSublayer:layer1 above:backgroundLayer];
                        }
                    }
                    
                    if (layer1 == nil)
                    {
                        layer1 = [[CALayer alloc] init];
                        layer1.actions = @{@"frame":[NSNull null],
                                           @"transform":[NSNull null],
                                           @"bounds":[NSNull null],
                                           @"position":[NSNull null],
                                           @"opacity":[NSNull null]};
                        layer1.backgroundColor = self.lineColor.CGColor;
                        layer1.contentsScale = [[UIScreen mainScreen] scale];
                        [inUseHorizontalShortLineLayers push:layer1];
                        [self.layer insertSublayer:layer1 above:backgroundLayer];
                    }
                    
                    CALayer *layer2 = [currentHorizontalShortLines pop];
                    
                    if (layer2 == nil)
                    {
                        layer2 = [cachedHorizontalShortLineLayers pop];
                        
                        if (layer2)
                        {
                            [inUseHorizontalShortLineLayers push:layer2];
                            [self.layer insertSublayer:layer2 above:backgroundLayer];
                        }
                    }
                    
                    if (layer2 == nil)
                    {
                        layer2 = [[CALayer alloc] init];
                        layer2.actions = @{@"frame":[NSNull null],
                                           @"transform":[NSNull null],
                                           @"bounds":[NSNull null],
                                           @"position":[NSNull null],
                                           @"opacity":[NSNull null]};
                        layer2.backgroundColor = self.lineColor.CGColor;
                        layer2.contentsScale = [[UIScreen mainScreen] scale];
                        [inUseHorizontalShortLineLayers push:layer2];
                        [self.layer insertSublayer:layer2 above:backgroundLayer];
                    }

                    if (i % 10 == 0)
                    {
                        layer1.frame = CGRectMake(currentStep-0.5, minY-longLineHeight, 1, longLineHeight);
                        layer2.frame = CGRectMake(currentStep-0.5, maxY, 1, longLineHeight);
                    }
                    else if (i % 5 == 0)
                    {
                        layer1.frame = CGRectMake(currentStep-0.5, minY-mediumLineHeight, 1, mediumLineHeight);
                        layer2.frame = CGRectMake(currentStep-0.5, maxY, 1, mediumLineHeight);
                    }
                    else
                    {
                        layer1.frame = CGRectMake(currentStep-0.5, minY-shortLineHeight, 1, shortLineHeight);
                        layer2.frame = CGRectMake(currentStep-0.5, maxY, 1, shortLineHeight);
                    }
                    
                    if (singleStep > 40 || (singleStep*5 >= 40 && i%5 == 0) || (singleStep*10 >= 40 && i%10 == 0))
                    {
                        CATextLayer *topTextLayer  = [currentHorizontalTextLines pop];
                        
                        if (topTextLayer == nil)
                        {
                            topTextLayer = [cachedHorizontalTextLineLayers pop];
                            
                            if (topTextLayer)
                            {
                                [inUseHorizontalTextLineLayers push:topTextLayer];
                                [self.layer insertSublayer:topTextLayer above:backgroundLayer];
                            }
                        }
                        
                        if (topTextLayer == nil)
                        {
                            topTextLayer = [[CATextLayer alloc] init];
                            topTextLayer.actions = @{@"frame":[NSNull null],
                                                     @"transform":[NSNull null],
                                                     @"bounds":[NSNull null],
                                                     @"position":[NSNull null],
                                                     @"string":[NSNull null],
                                                     @"opacity":[NSNull null]};
                            topTextLayer.foregroundColor = self.lineColor.CGColor;
                            topTextLayer.contentsScale = [[UIScreen mainScreen] scale];
                            topTextLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                            topTextLayer.fontSize = 10;
                            topTextLayer.alignmentMode = kCAAlignmentCenter;
                            [inUseHorizontalTextLineLayers push:topTextLayer];
                            [self.layer insertSublayer:topTextLayer above:backgroundLayer];
                        }

                        CATextLayer *bottomTextLayer  = [currentHorizontalTextLines pop];
                        
                        if (bottomTextLayer == nil)
                        {
                            bottomTextLayer = [cachedHorizontalTextLineLayers pop];
                            
                            if (bottomTextLayer)
                            {
                                [inUseHorizontalTextLineLayers push:bottomTextLayer];
                                [self.layer insertSublayer:bottomTextLayer above:backgroundLayer];
                            }
                        }
                        
                        if (bottomTextLayer == nil)
                        {
                            bottomTextLayer = [[CATextLayer alloc] init];
                            bottomTextLayer.actions = @{@"frame":[NSNull null],
                                                        @"transform":[NSNull null],
                                                        @"bounds":[NSNull null],
                                                        @"position":[NSNull null],
                                                        @"string":[NSNull null],
                                                        @"opacity":[NSNull null]};
                            bottomTextLayer.foregroundColor = self.lineColor.CGColor;
                            bottomTextLayer.contentsScale = [[UIScreen mainScreen] scale];
                            bottomTextLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                            bottomTextLayer.fontSize = 10;
                            bottomTextLayer.alignmentMode = kCAAlignmentCenter;
                            [inUseHorizontalTextLineLayers push:bottomTextLayer];
                            [self.layer insertSublayer:bottomTextLayer above:backgroundLayer];
                        }
                        
                        topTextLayer.string = [NSString localizedStringWithFormat:@"%.0f",i*multiplier/_deviceScale];
                        topTextLayer.frame = CGRectMake(currentStep-20, minY-scaleMargin.height, 40, scaleMargin.height-longLineHeight);

                        bottomTextLayer.string = [NSString localizedStringWithFormat:@"%.0f",i*multiplier/_deviceScale];
                        bottomTextLayer.frame = CGRectMake(currentStep-20, maxY+longLineHeight, 40, scaleMargin.height-longLineHeight);
                    }
                }
            }
        }
        
        //Vertical Scale
        {
            CGFloat currentStep = respectivePoint.y;
            
            NSInteger i = 0;
            
            while (currentStep > 0)
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
                if (currentStep!=0)
                {
                    CALayer *layer1 = [currentVerticalShortLines pop];
                    
                    if (layer1 == nil)
                    {
                        layer1 = [cachedVerticalShortLineLayers pop];
                        
                        if (layer1)
                        {
                            [inUseVerticalShortLineLayers push:layer1];
                            [self.layer insertSublayer:layer1 above:backgroundLayer];
                        }
                    }
                    
                    if (layer1 == nil)
                    {
                        layer1 = [[CALayer alloc] init];
                        layer1.actions = @{@"frame":[NSNull null],
                                           @"transform":[NSNull null],
                                           @"bounds":[NSNull null],
                                           @"position":[NSNull null],
                                           @"opacity":[NSNull null]};
                        layer1.backgroundColor = self.lineColor.CGColor;
                        layer1.contentsScale = [[UIScreen mainScreen] scale];
                        [inUseVerticalShortLineLayers push:layer1];
                        [self.layer insertSublayer:layer1 above:backgroundLayer];
                    }
                    
                    
                    CALayer *layer2 = [currentVerticalShortLines pop];
                    
                    if (layer2 == nil)
                    {
                        layer2 = [cachedVerticalShortLineLayers pop];
                        
                        if (layer2)
                        {
                            [inUseVerticalShortLineLayers push:layer2];
                            [self.layer insertSublayer:layer2 above:backgroundLayer];
                        }
                    }
                    
                    if (layer2 == nil)
                    {
                        layer2 = [[CALayer alloc] init];
                        layer2.actions = @{@"frame":[NSNull null],
                                           @"transform":[NSNull null],
                                           @"bounds":[NSNull null],
                                           @"position":[NSNull null],
                                           @"opacity":[NSNull null]};
                        layer2.backgroundColor = self.lineColor.CGColor;
                        layer2.contentsScale = [[UIScreen mainScreen] scale];
                        [inUseVerticalShortLineLayers push:layer2];
                        [self.layer insertSublayer:layer2 above:backgroundLayer];
                    }
                    
                    if (i % 10 == 0)
                    {
                        layer1.frame = CGRectMake(minX-longLineHeight, currentStep-0.5, longLineHeight, 1);
                        layer2.frame = CGRectMake(maxX, currentStep-0.5, longLineHeight, 1);
                    }
                    else if (i % 5 == 0)
                    {
                        layer1.frame = CGRectMake(minX-mediumLineHeight, currentStep-0.5, mediumLineHeight, 1);
                        layer2.frame = CGRectMake(maxX, currentStep-0.5, mediumLineHeight, 1);
                    }
                    else
                    {
                        layer1.frame = CGRectMake(minX-shortLineHeight, currentStep-0.5, shortLineHeight, 1);
                        layer2.frame = CGRectMake(maxX, currentStep-0.5, shortLineHeight, 1);
                    }
                    
                    if (singleStep > 40 || (singleStep*5 >= 40 && i%5 == 0) || (singleStep*10 >= 40 && i%10 == 0))
                    {
                        CGFloat remainingWidth = (scaleMargin.width-longLineHeight);
                        
                        CATextLayer *leftTextLayer  = [currentVerticalTextLines pop];
                        
                        if (leftTextLayer == nil)
                        {
                            leftTextLayer = [cachedVerticalTextLineLayers pop];
                            
                            if (leftTextLayer)
                            {
                                [inUseVerticalTextLineLayers push:leftTextLayer];
                                [self.layer insertSublayer:leftTextLayer above:backgroundLayer];
                            }
                        }
                        
                        if (leftTextLayer == nil)
                        {
                            leftTextLayer = [[CATextLayer alloc] init];
                            leftTextLayer.actions = @{@"frame":[NSNull null],
                                                      @"transform":[NSNull null],
                                                      @"bounds":[NSNull null],
                                                      @"position":[NSNull null],
                                                      @"string":[NSNull null],
                                                      @"opacity":[NSNull null]};
                            leftTextLayer.foregroundColor = self.lineColor.CGColor;
                            leftTextLayer.contentsScale = [[UIScreen mainScreen] scale];
                            leftTextLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                            leftTextLayer.fontSize = 10;
                            leftTextLayer.alignmentMode = kCAAlignmentCenter;
                            [inUseVerticalTextLineLayers push:leftTextLayer];
                            [self.layer insertSublayer:leftTextLayer above:backgroundLayer];
                        }
                        
                        
                        CATextLayer *rightTextLayer  = [currentVerticalTextLines pop];
                        
                        if (rightTextLayer == nil)
                        {
                            rightTextLayer = [cachedVerticalTextLineLayers pop];
                            
                            if (rightTextLayer)
                            {
                                [inUseVerticalTextLineLayers push:rightTextLayer];
                                [self.layer insertSublayer:rightTextLayer above:backgroundLayer];
                            }
                        }
                        
                        if (rightTextLayer == nil)
                        {
                            rightTextLayer = [[CATextLayer alloc] init];
                            rightTextLayer.actions = @{@"frame":[NSNull null],
                                                       @"transform":[NSNull null],
                                                       @"bounds":[NSNull null],
                                                       @"position":[NSNull null],
                                                       @"string":[NSNull null],
                                                       @"opacity":[NSNull null]};
                            rightTextLayer.foregroundColor = self.lineColor.CGColor;
                            rightTextLayer.contentsScale = [[UIScreen mainScreen] scale];
                            rightTextLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                            rightTextLayer.fontSize = 10;
                            rightTextLayer.alignmentMode = kCAAlignmentCenter;
                            [inUseVerticalTextLineLayers push:rightTextLayer];
                            [self.layer insertSublayer:rightTextLayer above:backgroundLayer];
                        }
                        
                        leftTextLayer.string = [NSString localizedStringWithFormat:@"%.0f",i*multiplier/_deviceScale];
                        leftTextLayer.transform = CATransform3DIdentity;
                        leftTextLayer.frame = CGRectMake((remainingWidth/2)-20, currentStep-remainingWidth/2, 40, remainingWidth);
                        leftTextLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(-M_PI_2));
                        
                        rightTextLayer.string = [NSString localizedStringWithFormat:@"%.0f",i*multiplier/_deviceScale];
                        rightTextLayer.transform = CATransform3DIdentity;
                        rightTextLayer.frame = CGRectMake(self.frame.size.width-(remainingWidth/2)-20, currentStep-remainingWidth/2, 40, remainingWidth);
                        rightTextLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(M_PI_2));
                    }
                }
            }
        }
    }
    else
    {
        backgroundLayer.opacity = 0.0;
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
    
    for (CATextLayer *layer in currentHorizontalTextLines)
    {
        [inUseHorizontalTextLineLayers removeObject:layer];
        [layer removeFromSuperlayer];
    }
    
    for (CATextLayer *layer in currentVerticalTextLines)
    {
        [inUseVerticalTextLineLayers removeObject:layer];
        [layer removeFromSuperlayer];
    }
    
    for (CALayer *layer in currentHorizontalShortLines)
    {
        [inUseHorizontalShortLineLayers removeObject:layer];
        [layer removeFromSuperlayer];
    }
    
    for (CALayer *layer in currentVerticalShortLines)
    {
        [inUseVerticalShortLineLayers removeObject:layer];
        [layer removeFromSuperlayer];
    }
    
    [cachedHorizontalLineLayers addObjectsFromArray:currentHorizontalLines];
    [cachedVerticalLineLayers addObjectsFromArray:currentVerticalLines];
    
    [cachedHorizontalTextLineLayers addObjectsFromArray:currentHorizontalTextLines];
    [cachedVerticalTextLineLayers addObjectsFromArray:currentVerticalTextLines];
    
    [cachedHorizontalShortLineLayers addObjectsFromArray:currentHorizontalShortLines];
    [cachedVerticalShortLineLayers addObjectsFromArray:currentVerticalShortLines];
    
    if (animated)
    {
        [CATransaction commit];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    backgroundLayer.frame = self.layer.bounds;
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

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    if (backgroundLayer.superlayer)
    {
        bool isEventOdd = backgroundLayer.fillRule == kCAFillRuleEvenOdd;
        
        bool result = CGPathContainsPoint(backgroundLayer.path,
                                          NULL, point, isEventOdd);
        
        return result;
    }
    else
    {
        return NO;
    }
}

@end
