//
//  IQLineFrameView.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQLineFrameView.h"
#import "UIColor+HexColors.h"
#import "NSMutableArray+Stack.h"

CGFloat const lineAlpha = 0.5;

CGFloat const longLineHeight = 8;
CGFloat const mediumLineHeight = 6;
CGFloat const shortLineHeight = 4;

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

    NSMutableArray<CATextLayer *> *cachedHorizontalTextLineLayers;
    NSMutableArray<CATextLayer *> *cachedVerticalTextLineLayers;
    NSMutableArray<CATextLayer *> *inUseHorizontalTextLineLayers;
    NSMutableArray<CATextLayer *> *inUseVerticalTextLineLayers;
    
    NSMutableArray<CALayer *> *cachedHorizontalShortLineLayers;
    NSMutableArray<CALayer *> *cachedVerticalShortLineLayers;
    NSMutableArray<CALayer *> *inUseHorizontalShortLineLayers;
    NSMutableArray<CALayer *> *inUseVerticalShortLineLayers;
}

@synthesize lineColor = _lineColor;

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

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    
    backgroundLayer.strokeColor = _lineColor.CGColor;

    CGColorRef colorRef = lineColor.CGColor;
    
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

-(void)setStartingScalePoint:(CGPoint)startingScalePoint
{
    _startingScalePoint = startingScalePoint;
    
    [self updateUIAnimated:NO];
    
    if ([self.delegate respondsToSelector:@selector(lineFrameDidChangeStartingScalePoint:)])
    {
        [self.delegate lineFrameDidChangeStartingScalePoint:self];
    }
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
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"set_scale_point_location", nil) preferredStyle:UIAlertControllerStyleActionSheet];
            
            __weak typeof(self) weakSelf = self;

            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"reset_scale_to_original", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.startingScalePoint = CGPointZero;
            }]];
            
            CGPoint point = [gesture locationInView:self];

            
            PositionSelector position = PositionSelectorNone;

            if (point.x <= self.scaleMargin.width || point.x >= (self.frame.size.width-self.scaleMargin.width))
            {
                position = PositionSelectorY;
            }
            else if (point.y <= self.scaleMargin.height || point.y >= (self.frame.size.height-self.scaleMargin.height))
            {
                position = PositionSelectorX;
            }

            [alertController addAction:[UIAlertAction actionWithTitle:(position == PositionSelectorX? NSLocalizedString(@"mark_as_x_reference", nil):NSLocalizedString(@"mark_as_y_reference", nil)) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                CGPoint referencePoint = [weakSelf convertPoint:point toView:weakSelf.respectiveView];
                
                if (position == PositionSelectorY)
                {
                    CGPoint scalePoint = weakSelf.startingScalePoint;
                    scalePoint.y = roundf(referencePoint.y);
                    weakSelf.startingScalePoint = scalePoint;
                }
                else if (position == PositionSelectorX)
                {
                    CGPoint scalePoint = weakSelf.startingScalePoint;
                    scalePoint.x = roundf(referencePoint.x);
                    weakSelf.startingScalePoint = scalePoint;
                }
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
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

        if (point.x <= self.scaleMargin.width || point.x >= (self.frame.size.width-self.scaleMargin.width))
        {
            position = PositionSelectorY;
            
            CGPoint scalePoint = self.startingScalePoint;
            scalePoint.y = _startingScalePointAtBegin.y + roundf(translation.y);
            self.startingScalePoint = scalePoint;
        }
        else if (point.y <= self.scaleMargin.height || point.y >= (self.frame.size.height-self.scaleMargin.height))
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
    
    NSMutableArray *currentHorizontalTextLines = [inUseHorizontalTextLineLayers mutableCopy];
    NSMutableArray *currentVerticalTextLines = [inUseVerticalTextLineLayers mutableCopy];
    
    NSMutableArray *currentHorizontalShortLines = [inUseHorizontalShortLineLayers mutableCopy];
    NSMutableArray *currentVerticalShortLines = [inUseVerticalShortLineLayers mutableCopy];
    
    CGRect newRect =self.bounds;
    CGSize scaleMargin = self.scaleMargin;
    
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

    CGPoint respectivePoint = [self.respectiveView convertPoint:self.startingScalePoint toView:self];

    CGFloat singleStep = self.zoomScale*multiplier;
    
    CGFloat  minX = CGRectGetMinX(newRect)+scaleMargin.width;
    CGFloat  minY = CGRectGetMinY(newRect)+scaleMargin.height;
    CGFloat  maxX = CGRectGetMaxX(newRect)-scaleMargin.width;
    CGFloat  maxY = CGRectGetMaxY(newRect)-scaleMargin.height;

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
        
        NSDictionary* disabledActions = @{@"frame":[NSNull null],
                                          @"string":[NSNull null],
                                          @"transform":[NSNull null],
                                          @"bounds":[NSNull null],
                                          @"position":[NSNull null],
                                          @"onOrderIn":[NSNull null],
                                          @"onOrderOut":[NSNull null],
                                          @"opacity":[NSNull null]};

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
                        layer1.actions = disabledActions;
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
                        layer2.actions = disabledActions;
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
                            topTextLayer.actions = disabledActions;
                            topTextLayer.foregroundColor = self.lineColor.CGColor;
                            topTextLayer.contentsScale = [[UIScreen mainScreen] scale];
                            topTextLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                            topTextLayer.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?16:10;
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
                            bottomTextLayer.actions = disabledActions;
                            bottomTextLayer.foregroundColor = self.lineColor.CGColor;
                            bottomTextLayer.contentsScale = [[UIScreen mainScreen] scale];
                            bottomTextLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                            bottomTextLayer.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?16:10;
                            bottomTextLayer.alignmentMode = kCAAlignmentCenter;
                            [inUseHorizontalTextLineLayers push:bottomTextLayer];
                            [self.layer insertSublayer:bottomTextLayer above:backgroundLayer];
                        }
                        
                        topTextLayer.string = [NSString localizedStringWithFormat:@"%.0f",i*multiplier/_deviceScale];
                        topTextLayer.frame = CGRectMake(currentStep-scaleMargin.height, minY-scaleMargin.height, 40, scaleMargin.height-longLineHeight);

                        bottomTextLayer.string = [NSString localizedStringWithFormat:@"%.0f",i*multiplier/_deviceScale];
                        bottomTextLayer.frame = CGRectMake(currentStep-scaleMargin.width, maxY+longLineHeight, 40, scaleMargin.height-longLineHeight);
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
                        layer1.actions = disabledActions;
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
                        layer2.actions = disabledActions;
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
                            leftTextLayer.actions = disabledActions;
                            leftTextLayer.foregroundColor = self.lineColor.CGColor;
                            leftTextLayer.contentsScale = [[UIScreen mainScreen] scale];
                            leftTextLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                            leftTextLayer.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?16:10;
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
                            rightTextLayer.actions = disabledActions;
                            rightTextLayer.foregroundColor = self.lineColor.CGColor;
                            rightTextLayer.contentsScale = [[UIScreen mainScreen] scale];
                            rightTextLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                            rightTextLayer.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?16:10;
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

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    if (backgroundLayer.superlayer && backgroundLayer.opacity != 0.0)
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
