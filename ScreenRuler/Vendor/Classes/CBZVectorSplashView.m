//
//  CBZVectorSplashView.m
//  Telly
//
//  Created by Mazyad Alabduljaleel on 8/7/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "CBZVectorSplashView.h"

@interface CBZVectorSplashView ()<CAAnimationDelegate>

@property (nonatomic, copy) void(^animationCompletionHandler)(void);

@property (nonatomic, strong) CAShapeLayer *iconLayer;
@property (nonatomic, strong) UIColor *backgroundViewColor;

@end

@implementation CBZVectorSplashView

- (instancetype)initWithBezierPath:(UIBezierPath *)bezier backgroundColor:(UIColor *)backgroundColor
{
  self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
  if (self) {
    _backgroundViewColor = backgroundColor;
    _iconLayer = [self _createShapeLayerWithBezierPath:bezier];
    
    [self.layer addSublayer:_iconLayer];
    
    self.backgroundColor = self.iconColor;
  }
  return self;
}

- (CAShapeLayer *)_createShapeLayerWithBezierPath:(UIBezierPath *)bezier
{
  /* Expand the shape bounds, so when it scales down a bit in the beginning, we have some padding */
  CGRect shapeBounds = CGRectInset(self.bounds, -CGRectGetWidth(self.bounds), -CGRectGetHeight(self.bounds));
                                   
  CGMutablePathRef mutablePath = CGPathCreateMutable();
  CGPathAddRect(mutablePath, NULL, shapeBounds);
  
  /* Move the icon to the middle */
  CGPoint iconOffset = CGPointMake(CGRectGetMidX(self.bounds) - CGRectGetMidX(bezier.bounds),
                                   CGRectGetMidY(self.bounds) - CGRectGetMidY(bezier.bounds));
  
  CGAffineTransform iconTransform = CGAffineTransformMakeTranslation(iconOffset.x, iconOffset.y);
  
  CGPathAddPath(mutablePath, &iconTransform, bezier.CGPath);
  
  CAShapeLayer *shapeLayer = [CAShapeLayer layer];
  shapeLayer.bounds = shapeBounds;
  shapeLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  shapeLayer.path = mutablePath;
  shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
  shapeLayer.fillColor = self.backgroundViewColor.CGColor;
  
  CGPathRelease(mutablePath);
  
  return shapeLayer;
}

- (void)startAnimationWithCompletionHandler:(void (^)(void))completionHandler
{
  self.animationCompletionHandler = completionHandler;
  
  self.iconAnimation.delegate = self;
  [self.iconLayer addAnimation:self.iconAnimation forKey:@"CBZVectorSplashViewIconAnimation"];
  
  /* Reveal the content behind the mask view after the icon expands a bit */
  [self performSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor] afterDelay:self.animationDuration * 0.4];
}

#pragma mark - CAAnimation Delegate methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  if (self.animationCompletionHandler) {
    self.animationCompletionHandler();
  }
  
  [self removeFromSuperview];
}

@end
