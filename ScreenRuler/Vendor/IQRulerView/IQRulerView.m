//
//  IQRulerView.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQRulerView.h"
#import "IQGeometry+AffineTransform.h"
#import "IQGeometry+Angle.h"
#import "UIColor+HexColors.h"

@interface IQRulerView ()<UIGestureRecognizerDelegate>
{
    CGFloat _previousAngle;
    BOOL _isAngleLocked;
    BOOL isInvertedUI;
}

@property(nonatomic, strong, readonly) IQAngleView *angleView;

@property(strong, readonly) UIPanGestureRecognizer *panRecognizer;
@property(strong, readonly) UIRotationGestureRecognizer *rotateRecognizer;

@end


@implementation IQRulerView

#pragma mark - Initialization

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
    self.layer.borderWidth = 1.0;
    _zoomScale = 1;
    _deviceScale = 1;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _angleView = [[IQAngleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    }
    else
    {
        _angleView = [[IQAngleView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    }
    
    _angleView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _angleView.autoresizesSubviews = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_angleView];
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizer:)];
    _panRecognizer.delegate = self;
    _panRecognizer.maximumNumberOfTouches = 2;
    [self addGestureRecognizer:_panRecognizer];
    
    _rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateRecognizer:)];
    _rotateRecognizer.delegate = self;
    [self addGestureRecognizer:_rotateRecognizer];

    self.lineColor = [UIColor darkGrayColor];
    self.rulerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
}

#pragma mark - Overrided methods

-(void)setZoomScale:(CGFloat)zoomScale
{
    _zoomScale = zoomScale;
    [self setNeedsLayout];
}

-(void)setDeviceScale:(CGFloat)deviceScale
{
    _deviceScale = deviceScale;
    [self setNeedsLayout];
}

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    
    self.layer.borderColor = _lineColor.CGColor;
    self.angleView.textColor = _lineColor;
    [self setNeedsLayout];
}

-(void)setRulerColor:(UIColor *)rulerColor
{
    _rulerColor = rulerColor;
    self.backgroundColor = [_rulerColor colorWithAlphaComponent:0.8];
    self.angleView.backgroundColor = _rulerColor;
    [self setNeedsLayout];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSArray *layers = [self.layer.sublayers copy];
    
    for (CALayer *layer in layers)
    {
        if (layer != self.angleView.layer)
        {
            [layer removeFromSuperlayer];
        }
    }
    
    CGFloat multiplier = 1;
    
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
    
    CGFloat singleStep = self.zoomScale*multiplier;

    {
        NSInteger i = 1;
        for (CGFloat currentStep = singleStep; currentStep<=self.bounds.size.width; currentStep+=singleStep, i++)
        {
            if (currentStep!=0)
            {
                CALayer *layer1 = [[CALayer alloc] init];
                layer1.contentsScale = [[UIScreen mainScreen] scale];
                CALayer *layer2 = [[CALayer alloc] init];
                layer2.contentsScale = [[UIScreen mainScreen] scale];
                
                if (i % 10 == 0)
                {
                    layer1.frame = CGRectMake(currentStep-0.4, 0, 0.8, 10);
                    layer2.frame = CGRectMake(currentStep-0.4, self.bounds.size.height-10, 0.8, 10);
                }
                else if (i % 5 == 0)
                {
                    layer1.frame = CGRectMake(currentStep-0.3, 0, 0.6, 7);
                    layer2.frame = CGRectMake(currentStep-0.3, self.bounds.size.height-7, 0.6, 7);
                }
                else
                {
                    layer1.frame = CGRectMake(currentStep-0.25, 0, 0.5, 5);
                    layer2.frame = CGRectMake(currentStep-0.25, self.bounds.size.height-5, 0.5, 5);
                }
                
                if (isInvertedUI)
                {
                    layer1.backgroundColor = _rulerColor.CGColor;
                    layer2.backgroundColor = _rulerColor.CGColor;
                }
                else
                {
                    layer1.backgroundColor = _lineColor.CGColor;
                    layer2.backgroundColor = _lineColor.CGColor;
                }

                [self.layer addSublayer:layer1];
                [self.layer addSublayer:layer2];
                
                if (singleStep > 40 || (singleStep*5 >= 40 && i%5 == 0) || (singleStep*10 >= 40 && i%10 == 0))
                {
                    CATextLayer *textLayer = [CATextLayer layer];
                    textLayer.contentsScale = [[UIScreen mainScreen] scale];
                    textLayer.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
                    textLayer.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?16:10;
                    textLayer.alignmentMode = kCAAlignmentCenter;
                    textLayer.string = [NSString localizedStringWithFormat:@"%.0f",i*multiplier/_deviceScale];
                    textLayer.frame = CGRectMake(currentStep-20, self.bounds.size.height/2-10, 40, 20);
                    textLayer.position = CGPointMake(layer1.frame.origin.x, CGRectGetMidY(self.bounds));
                    
                    textLayer.affineTransform = CGAffineTransformInvert(CGAffineTransformMakeRotation(IQAffineTransformGetAngle(self.transform)));

                    if (isInvertedUI)
                    {
                        textLayer.foregroundColor = _rulerColor.CGColor;
                    }
                    else
                    {
                        textLayer.foregroundColor = _lineColor.CGColor;
                    }

                    [self.layer addSublayer:textLayer];
                }
            }
        }
    }

    [self bringSubviewToFront:self.angleView];
    self.angleView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark - Gesture Recognizers

-(void)switchToInvertedUI
{
    isInvertedUI = YES;
    
    self.layer.borderColor = _rulerColor.CGColor;
    self.angleView.textColor = _rulerColor;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [_rulerColor colorWithAlphaComponent:0.2];
        self.angleView.backgroundColor = _lineColor;
    }];

    [self setNeedsLayout];
}

-(void)switchToNormalUI
{
    isInvertedUI = NO;
    
    self.layer.borderColor = _lineColor.CGColor;
    self.angleView.textColor = _lineColor;

    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [_rulerColor colorWithAlphaComponent:0.8];
        self.angleView.backgroundColor = _rulerColor;
    }];

    [self setNeedsLayout];
}


-(void)panRecognizer:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self switchToInvertedUI];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self switchToNormalUI];
    }
    

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
//        [self bringSubviewToFront:self];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:recognizer.view];

        recognizer.view.transform = CGAffineTransformTranslate(recognizer.view.transform, translation.x, translation.y);

        [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
    }
}

-(void)rotateRecognizer:(UIRotationGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self switchToInvertedUI];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self switchToNormalUI];
    }
    

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
//        [self bringSubviewToFront:self];
    }

    CGFloat const recognizerAngleInDegree = IQRadianToDegree(recognizer.rotation);
    CGFloat const currentAngleInRadian = IQAffineTransformGetAngle(self.transform);
    CGFloat const currentAngleInDegree = IQRadianToDegree(currentAngleInRadian);
    CGFloat finalAngleInDegree = recognizerAngleInDegree + currentAngleInDegree;
    
    NSInteger minimumRotationAngle = fabs(recognizer.velocity * 10);
        
    if (minimumRotationAngle > 2 || _isAngleLocked)
    {
        minimumRotationAngle = 2;
    }
    else
    {
        minimumRotationAngle = 1;
    }
    
    NSMutableArray *lockDegrees = [[NSMutableArray alloc] init];

    [lockDegrees addObject:@(0)];

    for (NSInteger i = 15; i< 360; i+= 15)
    {
        [lockDegrees addObject:@(i)];
        [lockDegrees addObject:@(-i)];
    }
    
    BOOL isLocked = NO;
    
    for (NSNumber *degree in lockDegrees)
    {
        NSInteger integerDegree = [degree integerValue];
        
        if ((finalAngleInDegree < integerDegree && (finalAngleInDegree+minimumRotationAngle) >= integerDegree) ||
            (finalAngleInDegree > integerDegree && (finalAngleInDegree-minimumRotationAngle) <= integerDegree))
        {
            finalAngleInDegree = integerDegree;
            isLocked = YES;
            break;
        }
    }
    
    _isAngleLocked = isLocked;
    
    {
        CGFloat finalAngleInRadian = IQDegreeToRadian(finalAngleInDegree);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(finalAngleInRadian);
        transform.tx = recognizer.view.transform.tx;
        transform.ty = recognizer.view.transform.ty;
        
        recognizer.view.transform = transform;
        
        if (_isAngleLocked == NO)
        {
            recognizer.rotation = 0.0;
        }
        
        _angleView.angle = IQAffineTransformGetAngle(self.transform);
        
        for (CALayer *layer in self.layer.sublayers)
        {
            if ([layer isKindOfClass:[CATextLayer class]])
            {
                layer.affineTransform = CGAffineTransformInvert(self.transform);
            }
        }
        
        _previousAngle = recognizerAngleInDegree;
    }
}

#pragma mark - Gesture Recognizer Delegates

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == _rotateRecognizer && otherGestureRecognizer == _panRecognizer) ||
        (gestureRecognizer == _panRecognizer && otherGestureRecognizer == _rotateRecognizer))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
