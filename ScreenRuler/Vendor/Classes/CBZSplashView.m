//
//  CBZSplashView.m
//  MicroMessage
//
//  Created by Callum Boddy on 22/07/2014.
//  Copyright (c) 2014 Callum Boddy. All rights reserved.
//

#import "CBZSplashView.h"
#import "CBZRasterSplashView.h"
#import "CBZVectorSplashView.h"


@implementation CBZSplashView

#pragma mark - Factory methods

+ (instancetype)splashViewWithIcon:(UIImage *)icon backgroundColor:(UIColor *)backgroundColor
{
  /* This component is useless without an icon */
  NSParameterAssert(icon);
  
  return [[CBZRasterSplashView alloc] initWithIconImage:icon backgroundColor:backgroundColor];
}

+ (instancetype)splashViewWithBezierPath:(UIBezierPath *)bezier backgroundColor:(UIColor *)backgroundColor
{
  return [[CBZVectorSplashView alloc] initWithBezierPath:bezier backgroundColor:backgroundColor];
}

#pragma mark - Init & Dealloc

- (instancetype)init
{
  return [super initWithFrame:[[UIScreen mainScreen] bounds]];
}

#pragma mark - Public methods

- (void)startAnimation
{
  [self startAnimationWithCompletionHandler:nil];
}

- (void)startAnimationWithCompletionHandler:(void(^)(void))completionHandler;
{
  NSAssert(NO, @"Override me!");
}

#pragma mark - property getters

- (CGSize)iconStartSize
{
  if (!_iconStartSize.height) {
    _iconStartSize = CGSizeMake(60, 60);
  }
  return _iconStartSize;
}

- (CGFloat)animationDuration
{
  if (!_animationDuration) {
    _animationDuration = 1.0f;
  }
  return _animationDuration;
}

- (CAAnimation *)iconAnimation
{
  if (!_iconAnimation) {
      CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
      
      CATransform3D transform1 = CATransform3DMakeScale(1, 1, 1);
      CATransform3D transform2 = CATransform3DMakeScale(0.9, 0.9, 0.9);
      CATransform3D transform3 = CATransform3DTranslate(CATransform3DMakeScale(300, 300, 300), 0, -25, 0);

      scaleAnimation.values = @[[NSValue valueWithCATransform3D:transform1],
                                [NSValue valueWithCATransform3D:transform2],
                                [NSValue valueWithCATransform3D:transform3]];
      scaleAnimation.duration = self.animationDuration;
      scaleAnimation.removedOnCompletion = NO;
      scaleAnimation.fillMode = kCAFillModeForwards;
      scaleAnimation.keyTimes = @[@0, @0.4, @1];
      scaleAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
      
    _iconAnimation = scaleAnimation;
  }
  return _iconAnimation;
}

- (UIColor *)iconColor
{
  if (!_iconColor) {
    _iconColor = [UIColor whiteColor];
  }
  return _iconColor;
}

@end
