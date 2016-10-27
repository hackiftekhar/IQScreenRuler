//
//  IQAngleView.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQAngleView.h"
#import "IQGeometry+Point.h"
#import "IQGeometry+Angle.h"
#import "UIFont+AppFont.h"

@implementation IQAngleView
{
    UILabel *angleLabel;
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    angleLabel.textColor = textColor;
    
    [self setNeedsDisplay];
}

-(void)initialize
{
    angleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    angleLabel.text = [NSString localizedStringWithFormat:@"%d°",0];
    angleLabel.font = [UIFont kohinoorBanglaRegularWithSize:15.0];
    angleLabel.adjustsFontSizeToFitWidth = YES;
    angleLabel.minimumScaleFactor = 0.5;
    angleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:angleLabel];
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
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.width/2;
}

-(void)setAngle:(CGFloat)angle
{
    _angle = angle;
    
    CGFloat angleInDegree = IQRadianToDegree(angle);

    angleInDegree = fabs(angleInDegree);
    
    if (angleInDegree > 90)
    {
        angleInDegree = 180-angleInDegree;
    }

    angleLabel.text = [NSString localizedStringWithFormat:@"%.0f°",angleInDegree];
    angleLabel.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(angle));
}

- (void)drawRect:(CGRect)rect {

    CGPoint centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    for (NSInteger i = 0; i<48; i++)
    {
        CGFloat graduationLength = 2;
        
        if (i%6 == 0)
        {
            graduationLength = 5;
        }
        
        CGPoint P1 = CGPointMake(1, self.frame.size.width/2);
        P1 = IQPointRotate(centerPoint, P1, IQDegreeToRadian(i*(360/48.0)));
        CGPoint P2 = IQPointWithDistance(P1,centerPoint,graduationLength);

        CAShapeLayer  *shapeLayer = [CAShapeLayer layer];
        shapeLayer.contentsScale = [[UIScreen mainScreen] scale];
        UIBezierPath *path = [UIBezierPath bezierPath];
        shapeLayer.path = path.CGPath;
        [path setLineWidth:0.5];
        [path moveToPoint:P1];
        [path addLineToPoint:P2];
        path.lineCapStyle = kCGLineCapSquare;
        [_textColor set];

        [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

@end
