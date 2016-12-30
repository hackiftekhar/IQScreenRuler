//
//  IQProtractorView.m
//  Screen Ruler
//
//  Created by IEMacBook02 on 24/12/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import "IQProtractorView.h"
#import "IQGeometry+Point.h"
#import "IQGeometry+Distance.h"
#import "IQGeometry+Angle.h"
#import "IQGeometry+AffineTransform.h"
#import "UIFont+AppFont.h"
#import "UIColor+HexColors.h"
#import <Crashlytics/Answers.h>

CGFloat lineTapWidth = 44;

typedef NS_ENUM(NSUInteger, TapLocation) {
    TapLocationHorizontalBegin,
    TapLocationHorizontalEnd,
    TapLocationVerticalBegin,
    TapLocationVerticalEnd,
};

typedef NS_ENUM(NSUInteger, DirectionLock) {
    DirectionLockNone,
    DirectionLockHorizontal,
    DirectionLockVertical,
};

@interface IQProtractorView ()<UIGestureRecognizerDelegate>

@property(strong, readonly) UIPanGestureRecognizer *panRecognizer;
@property(strong, readonly) UIPanGestureRecognizer *linePanRecognizer;
@property(strong, readonly) UIRotationGestureRecognizer *rotateRecognizer;
@property(strong, readonly) UIPinchGestureRecognizer *pinchRecognizer;
@property(strong, readonly) UILongPressGestureRecognizer *longPressRecognizer;

@property(strong, readonly) CAShapeLayer *layerCircle;

@property(strong, readonly) CAShapeLayer *dashLayer;
@property(strong, readonly) CAShapeLayer *arcLayer;

@property(strong, readonly) CAShapeLayer *layerHorizontalLine;
@property(strong, readonly) CAShapeLayer *layerVerticalLine;

@property(strong, readonly) CAShapeLayer *invertLayerHorizontalLine;
@property(strong, readonly) CAShapeLayer *invertLayerVerticalLine;

@property(strong, readonly) CATextLayer *layerDegree1;
@property(strong, readonly) CATextLayer *layerDegree2;
@property(strong, readonly) CATextLayer *layerDegree3;
@property(strong, readonly) CATextLayer *layerDegree4;

@end

@implementation IQProtractorView
{
    //UIRotationGestureRecognizer
    BOOL _isAngleLocked;
    
    //UIPinchGestureRecognizer
    CGRect _beginBounds;
    
    //linePanRecognizer
    TapLocation tapLocation;
    
    //panRecognizer
    DirectionLock directionLock;
}

-(CGPoint)horizontalStartPoint
{
    CGPoint pointToBeConverted = CGPointMake(CGRectGetMinX(_layerHorizontalLine.bounds), CGRectGetMidY(_layerHorizontalLine.bounds));
    CGPoint point = [self.layer convertPoint:pointToBeConverted fromLayer:_layerHorizontalLine];
    return point;
}

-(CGPoint)verticalStartPoint
{
    CGPoint pointToBeConverted = CGPointMake(CGRectGetMinX(_layerVerticalLine.bounds), CGRectGetMidY(_layerVerticalLine.bounds));
    CGPoint point = [self.layer convertPoint:pointToBeConverted fromLayer:_layerVerticalLine];
    return point;
}

-(CGPoint)horizontalEndPoint
{
    CGPoint pointToBeConverted = CGPointMake(CGRectGetMaxX(_layerHorizontalLine.bounds), CGRectGetMidY(_layerHorizontalLine.bounds));
    CGPoint point = [self.layer convertPoint:pointToBeConverted fromLayer:_layerHorizontalLine];
    return point;
}

-(CGPoint)verticalEndPoint
{
    CGPoint pointToBeConverted = CGPointMake(CGRectGetMaxX(_layerVerticalLine.bounds), CGRectGetMidY(_layerVerticalLine.bounds));
    CGPoint point = [self.layer convertPoint:pointToBeConverted fromLayer:_layerVerticalLine];
    return point;
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    _layerDegree1.foregroundColor =
    _layerDegree2.foregroundColor =
    _layerDegree3.foregroundColor =
    _layerDegree4.foregroundColor =
    _layerHorizontalLine.strokeColor =
    _layerVerticalLine.strokeColor =
    _arcLayer.strokeColor =
    _dashLayer.strokeColor = [textColor CGColor];

    [self setNeedsLayout];
}

-(void)setProtractorColor:(UIColor *)protractorColor
{
    _protractorColor = protractorColor;
    
    _layerCircle.fillColor =
    _layerDegree1.backgroundColor =
    _layerDegree2.backgroundColor =
    _layerDegree3.backgroundColor =
    _layerDegree4.backgroundColor = [_protractorColor colorWithAlphaComponent:0.8].CGColor;
    
    _invertLayerHorizontalLine.strokeColor =
    _invertLayerVerticalLine.strokeColor = [_protractorColor CGColor];
    
    [self setNeedsLayout];
}

-(void)initialize
{
    self.backgroundColor = [UIColor clearColor];

    NSDictionary *disabledActions = @{@"frame":[NSNull null],
                                      @"transform":[NSNull null],
                                      @"bounds":[NSNull null],
                                      @"position":[NSNull null],
                                      @"cornerRadius":[NSNull null],
                                      @"opacity":[NSNull null]};
    
    {
        _layerCircle = [[CAShapeLayer alloc] init];
        _layerCircle.fillRule = kCAFillRuleEvenOdd;
        _layerCircle.contentsScale = [[UIScreen mainScreen] scale];
        _layerCircle.frame = self.bounds;
        _layerCircle.masksToBounds = YES;
        _layerCircle.actions = disabledActions;
        [self.layer addSublayer:_layerCircle];
    }
    
    {
        _arcLayer = [[CAShapeLayer alloc] init];
        _arcLayer.fillColor = [UIColor clearColor].CGColor;
        _arcLayer.contentsScale = [[UIScreen mainScreen] scale];
        _arcLayer.actions = disabledActions;
        [self.layer addSublayer:_arcLayer];
        
        _dashLayer = [[CAShapeLayer alloc] init];
        _dashLayer.fillColor = [UIColor clearColor].CGColor;
        _dashLayer.contentsScale = [[UIScreen mainScreen] scale];
        _dashLayer.actions = disabledActions;
        [self.layer addSublayer:_dashLayer];
        
        _invertLayerHorizontalLine = [[CAShapeLayer alloc] init];
        _invertLayerHorizontalLine.fillColor = [UIColor clearColor].CGColor;
        _invertLayerHorizontalLine.contentsScale = [[UIScreen mainScreen] scale];
        _invertLayerHorizontalLine.actions = disabledActions;
        [self.layer addSublayer:_invertLayerHorizontalLine];
        
        _invertLayerVerticalLine = [[CAShapeLayer alloc] init];
        _invertLayerVerticalLine.fillColor = [UIColor clearColor].CGColor;
        _invertLayerVerticalLine.contentsScale = [[UIScreen mainScreen] scale];
        _invertLayerVerticalLine.actions = disabledActions;
        _invertLayerVerticalLine.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
        [self.layer addSublayer:_invertLayerVerticalLine];

        _layerHorizontalLine = [[CAShapeLayer alloc] init];
        _layerHorizontalLine.fillColor = [UIColor clearColor].CGColor;
        _layerHorizontalLine.contentsScale = [[UIScreen mainScreen] scale];
        _layerHorizontalLine.actions = disabledActions;
        [self.layer addSublayer:_layerHorizontalLine];
        
        _layerVerticalLine = [[CAShapeLayer alloc] init];
        _layerVerticalLine.fillColor = [UIColor clearColor].CGColor;
        _layerVerticalLine.contentsScale = [[UIScreen mainScreen] scale];
        _layerVerticalLine.actions = disabledActions;
        _layerVerticalLine.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
        [self.layer addSublayer:_layerVerticalLine];
    }
    
    {
        _layerDegree1 = [[CATextLayer alloc] init];
        _layerDegree1.masksToBounds = YES;
        _layerDegree1.frame = CGRectMake(0, 0, 40, 40);
        _layerDegree1.actions = disabledActions;
        _layerDegree1.contentsScale = [[UIScreen mainScreen] scale];
        _layerDegree1.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
        _layerDegree1.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?24:15;
        _layerDegree1.alignmentMode = kCAAlignmentCenter;
        [self.layer addSublayer:_layerDegree1];
        
        _layerDegree2 = [[CATextLayer alloc] init];
        _layerDegree2.masksToBounds = YES;
        _layerDegree2.actions = disabledActions;
        _layerDegree2.frame = CGRectMake(0, 0, 40, 40);
        _layerDegree2.contentsScale = [[UIScreen mainScreen] scale];
        _layerDegree2.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
        _layerDegree2.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?24:15;
        _layerDegree2.alignmentMode = kCAAlignmentCenter;
        [self.layer addSublayer:_layerDegree2];

        _layerDegree3 = [[CATextLayer alloc] init];
        _layerDegree3.masksToBounds = YES;
        _layerDegree3.frame = CGRectMake(0, 0, 40, 40);
        _layerDegree3.actions = disabledActions;
        _layerDegree3.contentsScale = [[UIScreen mainScreen] scale];
        _layerDegree3.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
        _layerDegree3.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?24:15;
        _layerDegree3.alignmentMode = kCAAlignmentCenter;
        [self.layer addSublayer:_layerDegree3];
        
        _layerDegree4 = [[CATextLayer alloc] init];
        _layerDegree4.masksToBounds = YES;
        _layerDegree4.actions = disabledActions;
        _layerDegree4.frame = CGRectMake(0, 0, 40, 40);
        _layerDegree4.contentsScale = [[UIScreen mainScreen] scale];
        _layerDegree4.font = (__bridge CFTypeRef)@"KohinoorBangla-Semibold";
        _layerDegree4.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?24:15;
        _layerDegree4.alignmentMode = kCAAlignmentCenter;
        [self.layer addSublayer:_layerDegree4];
    }
    
    {
        _linePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(linePanRecognizer:)];
        _linePanRecognizer.delegate = self;
        _linePanRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:_linePanRecognizer];

        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizer:)];
        _panRecognizer.delegate = self;
        _panRecognizer.maximumNumberOfTouches = 2;
        [_panRecognizer requireGestureRecognizerToFail:_linePanRecognizer];
        [self addGestureRecognizer:_panRecognizer];
        
        _rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateRecognizer:)];
        _rotateRecognizer.delegate = self;
        [self addGestureRecognizer:_rotateRecognizer];
        
        _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchRecognizer:)];
        _pinchRecognizer.delegate = self;
        [self addGestureRecognizer:_pinchRecognizer];
        
        _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
        _longPressRecognizer.delegate = self;
        _longPressRecognizer.minimumPressDuration = 1;
        _longPressRecognizer.allowableMovement = 3;
        [self addGestureRecognizer:_longPressRecognizer];
    }
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

-(void)layoutSubviews
{
    [super layoutSubviews];

    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    _arcLayer.frame = _dashLayer.frame = self.bounds;

    CGFloat innerRadius = 10;

    {
        CGFloat radius = self.bounds.size.width/2;
        _layerCircle.frame = self.bounds;

        {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, centerPoint.y)];
            [path addArcWithCenter:centerPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
            [path closePath];
            
            [path moveToPoint:CGPointMake(centerPoint.x-innerRadius, centerPoint.y)];
            [path addArcWithCenter:centerPoint radius:innerRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
            [path closePath];
            
            _layerCircle.path = path.CGPath;
        }
        
    }
    
    {
        CGRect bounds = CGRectMake(0, 0, CGRectGetWidth(self.bounds), lineTapWidth);
        
        _layerHorizontalLine.bounds = _layerVerticalLine.bounds = bounds;
        _layerHorizontalLine.position = _layerVerticalLine.position = centerPoint;

        //White lines
        {
            CGPoint beginPoint = CGPointMake(CGRectGetMinX(bounds), lineTapWidth/2);
            CGPoint stopPoint1 = CGPointMake(CGRectGetMidX(bounds)-innerRadius, lineTapWidth/2);
            CGPoint stopPoint2 = CGPointMake(CGRectGetMidX(bounds)+innerRadius, lineTapWidth/2);
            CGPoint endPoint = CGPointMake(CGRectGetMaxX(bounds), lineTapWidth/2);
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:beginPoint];
            [path addLineToPoint:stopPoint1];
            [path closePath];
            [path moveToPoint:stopPoint2];
            [path addLineToPoint:endPoint];
            [path closePath];

            _layerHorizontalLine.path = _layerVerticalLine.path = path.CGPath;
        }

        //Color long lines
        {
            CGFloat maxWidthHeight = MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);

            CGRect bounds = CGRectMake(0, 0, maxWidthHeight*2, lineTapWidth);
            
            _invertLayerHorizontalLine.bounds = _invertLayerVerticalLine.bounds = bounds;
            _invertLayerHorizontalLine.position = _invertLayerVerticalLine.position = centerPoint;

            CGPoint beginPoint = CGPointMake(CGRectGetMinX(bounds), lineTapWidth/2);
            CGPoint stopPoint1 = CGPointMake(CGRectGetMidX(bounds)-1.25, lineTapWidth/2);
            CGPoint stopPoint2 = CGPointMake(CGRectGetMidX(bounds)+1.25, lineTapWidth/2);
            CGPoint endPoint = CGPointMake(CGRectGetMaxX(bounds), lineTapWidth/2);
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:beginPoint];
            [path addLineToPoint:stopPoint1];
            [path closePath];
            [path moveToPoint:stopPoint2];
            [path addLineToPoint:endPoint];
            [path closePath];

            _invertLayerHorizontalLine.path = _invertLayerVerticalLine.path = path.CGPath;
        }
    }
    
    //Arch and dashes
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint P1 = CGPointMake(1, self.bounds.size.width/2);
        
        CGFloat smallWidth = CGRectGetWidth(self.bounds)*0.04;
        CGFloat mediumWidth = CGRectGetWidth(self.bounds)*0.07;
        CGFloat largeWidth = CGRectGetWidth(self.bounds)*0.10;
        
        for (NSInteger i = 0; i<72; i++)
        {
            CGPoint topPoint = IQPointRotate(centerPoint, P1, IQDegreeToRadian(i*(360.0/72.0)));
            CGPoint bottomPoint;

            if (i%9 == 0)
            {
                bottomPoint = IQPointWithDistance(topPoint,centerPoint,largeWidth);
            }
            else if (i%3 == 0)
            {
                bottomPoint = IQPointWithDistance(topPoint,centerPoint,mediumWidth);
            }
            else
            {
                bottomPoint = IQPointWithDistance(topPoint,centerPoint,smallWidth);
            }
            
            [path moveToPoint:topPoint];
            [path addLineToPoint:bottomPoint];
            [path closePath];
        }
        
        _dashLayer.path = path.CGPath;
    }
    
    //Arc
    {
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGPoint basePoint2 = CGPointMake(centerPoint.x+10, centerPoint.y);
        
        {
            CGFloat radius = innerRadius*1.5;
            CGPoint point1 = IQPointWithDistance(centerPoint, self.horizontalStartPoint, radius);
            CGPoint point2 = IQPointWithDistance(centerPoint, self.verticalEndPoint, radius);
            
            CGFloat beginAngle = IQPointGetAngle(centerPoint, basePoint2, point1);
            CGFloat endAngle = IQPointGetAngle(centerPoint, basePoint2, point2);
            
            [path moveToPoint:point1];
            [path addArcWithCenter:centerPoint radius:radius startAngle:beginAngle endAngle:endAngle clockwise:YES];
        }
        
        {
            CGFloat radius = innerRadius*2;
            CGPoint point1 = IQPointWithDistance(centerPoint, self.horizontalEndPoint, radius);
            CGPoint point2 = IQPointWithDistance(centerPoint, self.verticalEndPoint, radius);
            
            CGFloat beginAngle = IQPointGetAngle(centerPoint, basePoint2, point1);
            CGFloat endAngle = IQPointGetAngle(centerPoint, basePoint2, point2);
            
            [path moveToPoint:point1];
            [path addArcWithCenter:centerPoint radius:radius startAngle:beginAngle endAngle:endAngle clockwise:NO];
        }

        {
            CGFloat radius = innerRadius*2.5;
            CGPoint point1 = IQPointWithDistance(centerPoint, self.horizontalStartPoint, radius);
            CGPoint point2 = IQPointWithDistance(centerPoint, self.verticalStartPoint, radius);
            
            CGFloat beginAngle = IQPointGetAngle(centerPoint, basePoint2, point1);
            CGFloat endAngle = IQPointGetAngle(centerPoint, basePoint2, point2);
            
            [path moveToPoint:point1];
            [path addArcWithCenter:centerPoint radius:radius startAngle:beginAngle endAngle:endAngle clockwise:YES];
        }
        
        {
            CGFloat radius = innerRadius*3;
            CGPoint point1 = IQPointWithDistance(centerPoint, self.horizontalEndPoint, radius);
            CGPoint point2 = IQPointWithDistance(centerPoint, self.verticalStartPoint, radius);
            
            CGFloat beginAngle = IQPointGetAngle(centerPoint, basePoint2, point1);
            CGFloat endAngle = IQPointGetAngle(centerPoint, basePoint2, point2);
            
            [path moveToPoint:point1];
            [path addArcWithCenter:centerPoint radius:radius startAngle:beginAngle endAngle:endAngle clockwise:NO];
        }
        
        _arcLayer.path = path.CGPath;
    }

    //Horizontal and vertical lines
    {
        CGFloat radius = CGRectGetWidth(self.bounds)/4;

        CGPoint verticalStartPoint = IQPointWithDistance(centerPoint, self.verticalStartPoint, radius);
        CGFloat originalAngle = IQPointGetAngle(centerPoint, CGPointMake(centerPoint.x-10, centerPoint.y), verticalStartPoint);
        CGFloat verticalBeginAngle = originalAngle;
        
        if (verticalBeginAngle > M_PI)
        {
            verticalBeginAngle = fmodf(verticalBeginAngle, M_PI);
        }
        
        _layerDegree1.affineTransform = CGAffineTransformIdentity;
        _layerDegree2.affineTransform = CGAffineTransformIdentity;
        _layerDegree3.affineTransform = CGAffineTransformIdentity;
        _layerDegree4.affineTransform = CGAffineTransformIdentity;
        
        {
            CGFloat degree1 = IQRadianToDegree(verticalBeginAngle);
            CGFloat degree2 = IQRadianToDegree(M_PI-verticalBeginAngle);
            
            _layerDegree1.string = [NSString stringWithFormat:@"%.0f°",degree1];
            _layerDegree2.string = [NSString stringWithFormat:@"%.0f°",degree2];
            _layerDegree3.string = [NSString stringWithFormat:@"%.0f°",degree1+180];
            _layerDegree4.string = [NSString stringWithFormat:@"%.0f°",degree2+180];
        }
        
        {
            CGRect layer1Rect = [_layerDegree1.string boundingRectWithSize:CGSizeMake(40, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"KohinoorBangla-Semibold" size:_layerDegree1.fontSize]} context:nil];
            layer1Rect.size.width +=10;
            _layerDegree1.cornerRadius = layer1Rect.size.height/2;
            _layerDegree1.bounds = layer1Rect;
            
            CGRect layer2Rect = [_layerDegree2.string boundingRectWithSize:CGSizeMake(40, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"KohinoorBangla-Semibold" size:_layerDegree2.fontSize]} context:nil];
            layer2Rect.size.width +=10;
            _layerDegree2.cornerRadius = layer2Rect.size.height/2;
            _layerDegree2.bounds = layer2Rect;

            CGRect layer3Rect = [_layerDegree3.string boundingRectWithSize:CGSizeMake(40, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"KohinoorBangla-Semibold" size:_layerDegree3.fontSize]} context:nil];
            layer3Rect.size.width +=10;
            _layerDegree3.cornerRadius = layer3Rect.size.height/2;
            _layerDegree3.bounds = layer3Rect;
            
            CGRect layer4Rect = [_layerDegree4.string boundingRectWithSize:CGSizeMake(40, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"KohinoorBangla-Semibold" size:_layerDegree4.fontSize]} context:nil];
            layer4Rect.size.width +=10;
            _layerDegree4.cornerRadius = layer4Rect.size.height/2;
            _layerDegree4.bounds = layer4Rect;
        }
        
        if (originalAngle > M_PI)
        {
            CGPoint rotatedPoint1 = IQPointRotate(centerPoint,self.horizontalStartPoint, verticalBeginAngle/2);
            _layerDegree1.position = IQPointGetMidPoint(rotatedPoint1, centerPoint);

            CGPoint rotatedPoint2 = IQPointRotate(centerPoint,self.horizontalEndPoint, (verticalBeginAngle-M_PI)/2);
            _layerDegree2.position = IQPointGetMidPoint(rotatedPoint2, centerPoint);

            CGPoint rotatedPoint3 = IQPointRotate(centerPoint,self.horizontalEndPoint, verticalBeginAngle/2);
            _layerDegree3.position = IQPointGetMidPoint(rotatedPoint3, centerPoint);
            
            CGPoint rotatedPoint4 = IQPointRotate(centerPoint,self.horizontalStartPoint, (verticalBeginAngle-M_PI)/2);
            _layerDegree4.position = IQPointGetMidPoint(rotatedPoint4, centerPoint);
        }
        else
        {
            CGPoint rotatedPoint1 = IQPointRotate(centerPoint,self.horizontalStartPoint, verticalBeginAngle/2);
            _layerDegree1.position = IQPointGetMidPoint(rotatedPoint1, centerPoint);

            CGPoint rotatedPoint2 = IQPointRotate(centerPoint,self.horizontalEndPoint, (verticalBeginAngle-M_PI)/2);
            _layerDegree2.position = IQPointGetMidPoint(rotatedPoint2, centerPoint);

            CGPoint rotatedPoint3 = IQPointRotate(centerPoint,self.horizontalEndPoint, verticalBeginAngle/2);
            _layerDegree3.position = IQPointGetMidPoint(rotatedPoint3, centerPoint);
            
            CGPoint rotatedPoint4 = IQPointRotate(centerPoint,self.horizontalStartPoint, (verticalBeginAngle-M_PI)/2);
            _layerDegree4.position = IQPointGetMidPoint(rotatedPoint4, centerPoint);
        }
        
        
        CGFloat finalAngleInRadian = IQAffineTransformGetAngle(self.transform);
        
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(-finalAngleInRadian);
        _layerDegree1.affineTransform = rotationTransform;
        _layerDegree2.affineTransform = rotationTransform;
        _layerDegree3.affineTransform = rotationTransform;
        _layerDegree4.affineTransform = rotationTransform;
    }
}

#pragma mark - Gesture Recognizers

-(void)panRecognizer:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint velocity = [recognizer velocityInView:self];

        CGFloat x = fabs(velocity.x);
        CGFloat y = fabs(velocity.y);
        
        if (x > 1 && y < 1)
        {
            directionLock = DirectionLockHorizontal;
        }
        else if (x < 1 && y > 1)
        {
            directionLock = DirectionLockVertical;
        }
        else
        {
            directionLock = DirectionLockNone;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        
        switch (directionLock) {
            case DirectionLockHorizontal:
                translation.y = 0;
                break;
            case DirectionLockVertical:
                translation.x = 0;
                break;
            default:
                break;
        }
        recognizer.view.transform = CGAffineTransformTranslate(recognizer.view.transform, translation.x, translation.y);
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        directionLock = DirectionLockNone;
    }
}

-(void)rotateRecognizer:(UIRotationGestureRecognizer*)recognizer
{
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
        if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
        {
            finalAngleInDegree = roundf(finalAngleInDegree);
        }

        CGFloat finalAngleInRadian = IQDegreeToRadian(finalAngleInDegree);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(finalAngleInRadian);
        transform.tx = recognizer.view.transform.tx;
        transform.ty = recognizer.view.transform.ty;
        
        recognizer.view.transform = transform;
        
        if (_isAngleLocked == NO)
        {
            recognizer.rotation = 0.0;
        }
        
        [self setNeedsLayout];
    }
}

-(void)linePanRecognizer:(UIPanGestureRecognizer*)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _dashLayer.strokeColor =
        _arcLayer.strokeColor = [_protractorColor colorWithAlphaComponent:0.5].CGColor;
        
        _layerDegree1.foregroundColor =
        _layerDegree2.foregroundColor =
        _layerDegree3.foregroundColor =
        _layerDegree4.foregroundColor = _protractorColor.CGColor;
        
        _layerDegree1.backgroundColor =
        _layerDegree2.backgroundColor =
        _layerDegree3.backgroundColor =
        _layerDegree4.backgroundColor = [_textColor colorWithAlphaComponent:0.8].CGColor;
        
        _layerHorizontalLine.opacity =
        _layerVerticalLine.opacity = 0.0;
        
        _layerCircle.fillColor = [_protractorColor colorWithAlphaComponent:0.1].CGColor;

    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        _dashLayer.strokeColor =
        _arcLayer.strokeColor = _textColor.CGColor;
        
        _layerDegree1.foregroundColor =
        _layerDegree2.foregroundColor =
        _layerDegree3.foregroundColor =
        _layerDegree4.foregroundColor = _textColor.CGColor;
        
        _layerDegree1.backgroundColor =
        _layerDegree2.backgroundColor =
        _layerDegree3.backgroundColor =
        _layerDegree4.backgroundColor =
        _layerCircle.fillColor = [_protractorColor colorWithAlphaComponent:0.8].CGColor;

        _layerHorizontalLine.opacity = _layerVerticalLine.opacity = 1.0;
    }
    
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    switch (tapLocation) {
        case TapLocationVerticalBegin:
        case TapLocationVerticalEnd:
        {
            CGFloat finalAngleInDegree = 0;
            
            if (tapLocation == TapLocationVerticalBegin)
            {
                CGFloat angle = IQPointGetAngle(centerPoint, self.horizontalStartPoint, touchPoint);
                finalAngleInDegree = IQRadianToDegree(angle);
            }
            else
            {
                CGFloat angle = IQPointGetAngle(centerPoint, self.horizontalEndPoint, touchPoint);
                finalAngleInDegree = IQRadianToDegree(angle);
            }
            
            NSInteger minimumRotationAngle = 1;
            
            NSMutableArray *lockDegrees = [[NSMutableArray alloc] init];
            
            [lockDegrees addObject:@(0)];
            
            for (NSInteger i = 5; i< 360; i+= 5)
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

            finalAngleInDegree = fmodf(finalAngleInDegree, 180);
            
            if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
            {
                finalAngleInDegree = roundf(finalAngleInDegree);
            }
            
            CGFloat finalAngleInRadian = IQDegreeToRadian(finalAngleInDegree);

            _invertLayerVerticalLine.affineTransform = _layerVerticalLine.affineTransform = CGAffineTransformMakeRotation(finalAngleInRadian);
        }
            break;
            
        case TapLocationHorizontalBegin:
        case TapLocationHorizontalEnd:
        {
            CGAffineTransform previousTransform = self.transform;
            self.transform = CGAffineTransformMakeTranslation(previousTransform.tx, previousTransform.ty);
            
            CGPoint touchPoint = [recognizer locationInView:self];
            
            CGFloat deltaAngle = 0;
            
            if (tapLocation == TapLocationHorizontalBegin)
            {
                deltaAngle = M_PI;
            }

            float ang = atan2(touchPoint.y-centerPoint.y, touchPoint.x-centerPoint.x);
            float angle = deltaAngle - ang;
            
            CGFloat finalAngleInDegree = IQRadianToDegree(angle);
            
            NSInteger minimumRotationAngle = 1;
            
            NSMutableArray *lockDegrees = [[NSMutableArray alloc] init];
            
            [lockDegrees addObject:@(0)];
            
            for (NSInteger i = 5; i< 360; i+= 5)
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
            
            if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
            {
                finalAngleInDegree = roundf(finalAngleInDegree);
            }
            
            CGFloat finalAngleInRadian = IQDegreeToRadian(finalAngleInDegree);

            CGAffineTransform transform = CGAffineTransformMakeRotation(-finalAngleInRadian);
            transform.tx = self.transform.tx;
            transform.ty = self.transform.ty;
            
            self.transform = transform;
        }
            break;
    }

    [self setNeedsLayout];
}

-(void)pinchRecognizer:(UIPinchGestureRecognizer*)recognizer
{
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        _beginBounds = self.bounds;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan ||
        [recognizer state] == UIGestureRecognizerStateChanged) {
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxWidth = 270.0;
        const CGFloat kMinWidth = 120.0;
        
        CGRect newRect = CGRectApplyAffineTransform(_beginBounds, CGAffineTransformMakeScale([recognizer scale], [recognizer scale]));
        
        newRect.origin = CGPointZero;
        if (newRect.size.width > kMaxWidth)
        {
            newRect.size.width = kMaxWidth;
            newRect.size.height = kMaxWidth;
        }
        else if (newRect.size.width < kMinWidth)
        {
            newRect.size.width = kMinWidth;
            newRect.size.height = kMinWidth;
        }
        
        self.bounds = newRect;
    }
}

-(void)longPressRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
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
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"enter_angle_title", nil) message:[NSString stringWithFormat:NSLocalizedString(@"enter_angle_description", nil),0,180,180] preferredStyle:UIAlertControllerStyleAlert];

            __weak typeof(UIAlertController) *weakAlertController = alertController;
            __weak typeof(self) weakSelf = self;
            
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                UITextField *textField = nil;
                
                for (UITextField *loopTextField in weakAlertController.textFields)
                {
                    textField = loopTextField;
                }

                CGFloat finalAngleInDegree = [textField.text floatValue];
                
                CGFloat finalAngleInRadian = fmodf(IQDegreeToRadian(finalAngleInDegree),M_PI);
                
                _invertLayerVerticalLine.affineTransform = _layerVerticalLine.affineTransform = CGAffineTransformMakeRotation(finalAngleInRadian);
                [self setNeedsLayout];
                
                [Answers logCustomEventWithName:@"AngleDone" customAttributes:@{@"angle":textField.text}];
            }];
            
            [alertController addAction:doneAction];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
                CGFloat radius = CGRectGetWidth(weakSelf.bounds)/4;
                CGPoint centerPoint = CGPointMake(CGRectGetMidX(weakSelf.bounds), CGRectGetMidY(weakSelf.bounds));
                CGPoint verticalStartPoint = IQPointWithDistance(centerPoint, weakSelf.verticalStartPoint, radius);
                CGFloat originalAngle = IQPointGetAngle(centerPoint, CGPointMake(centerPoint.x-10, centerPoint.y), verticalStartPoint);
                CGFloat verticalBeginAngle = fmodf(originalAngle, M_PI);
                
                CGFloat finalAngleInDegree = IQRadianToDegree(verticalBeginAngle);
                finalAngleInDegree = roundf(finalAngleInDegree*10)/10;
                NSInteger finalAngleInDegreeInteger = finalAngleInDegree;

                textField.placeholder = NSLocalizedString(@"enter_angle_title", nil);
                textField.text = [NSString stringWithFormat:(finalAngleInDegree == finalAngleInDegreeInteger?@"%.0f":@"%.1f"),finalAngleInDegree];
                textField.keyboardType = UIKeyboardTypeDecimalPad;
                
                
                if ([textField.text length] == 0 || [textField.text integerValue] > 360 || [textField.text integerValue] < -360)
                {
                    doneAction.enabled = NO;
                }
                else
                {
                    doneAction.enabled = YES;
                }

                
                [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                    
                    if ([textField.text length] == 0 || [textField.text integerValue] > 360 || [textField.text integerValue] < -360)
                    {
                        doneAction.enabled = NO;
                    }
                    else
                    {
                        doneAction.enabled = YES;
                    }
                }];
            }];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            alertController.popoverPresentationController.sourceView = recognizer.view;
            
            CGPoint touchPoint = [recognizer locationInView:recognizer.view];
            alertController.popoverPresentationController.sourceRect = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);
            
            [(UIViewController*)nextResponder presentViewController:alertController animated:YES completion:^{
            }];
        }
    }
}


#pragma mark - Gesture Recognizer Delegates

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    CGRect bounds = self.bounds;
    
    if (gestureRecognizer == _linePanRecognizer)
    {
        if ([_invertLayerVerticalLine hitTest:touchPoint]) {
            
            tapLocation = (touchPoint.y <= CGRectGetMidY(bounds))?TapLocationVerticalBegin:TapLocationVerticalEnd;
            
            return YES;
        } else if ([_invertLayerHorizontalLine hitTest:touchPoint]) {
            
            tapLocation = (touchPoint.x <= CGRectGetMidX(bounds))?TapLocationHorizontalBegin:TapLocationHorizontalEnd;
        } else {
            return NO;
        }
    }
    else if (gestureRecognizer == _panRecognizer || gestureRecognizer == _rotateRecognizer || gestureRecognizer == _pinchRecognizer || gestureRecognizer == _longPressRecognizer)
    {
        if ([_layerCircle hitTest:touchPoint]) {
            
            return YES;
        } else {
            return NO;
        }
    }

    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == _rotateRecognizer && otherGestureRecognizer == _pinchRecognizer) ||
        (gestureRecognizer == _pinchRecognizer && otherGestureRecognizer == _rotateRecognizer))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL pointInside = [super pointInside:point withEvent:event];
    
    if (pointInside == NO)
    {
        if ([_invertLayerVerticalLine hitTest:point] || [_invertLayerHorizontalLine hitTest:point])
        {
            pointInside = YES;
        }
    }
    
    return pointInside;

}

@end
