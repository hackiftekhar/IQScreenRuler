//
//  IQScrollContainerView.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQScrollContainerView.h"
#import "UIFont+AppFont.h"
#import "IQGeometry+AffineTransform.h"
#import "IQGeometry+Rect.h"

@interface IQScrollContainerView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    BOOL restoreToMinimumScale;
//    UISwipeGestureRecognizer *swipeRecognizer;
}

@property(nonatomic, strong, readonly) UIVisualEffectView *zoomInfoContainerView;
@property(nonatomic, strong, readonly) UIButton *zoomDecreaseButton;
@property(nonatomic, strong, readonly) UIButton *zoomInfoButton;
@property(nonatomic, strong, readonly) UIButton *zoomIncreaseButton;

@property (strong, nonatomic) UIRotationGestureRecognizer *rotationGestureRecognizer;

@end


@implementation IQScrollContainerView
@synthesize scrollView = _scrollView;

@synthesize zoomInfoContainerView = _zoomInfoContainerView;
@synthesize zoomDecreaseButton = _zoomDecreaseButton;
@synthesize zoomInfoButton = _zoomInfoButton;
@synthesize zoomIncreaseButton = _zoomIncreaseButton;

-(void)initialize
{
//    self.backgroundColor = [UIColor grayColor];
    _rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    _rotationGestureRecognizer.delaysTouchesEnded = NO;
    _rotationGestureRecognizer.delegate = self;
//    [self addGestureRecognizer:_rotationGestureRecognizer];
    
    [self insertSubview:self.zoomInfoContainerView aboveSubview:self.scrollView];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
}

#pragma mark - ScrollView

-(IQRulerScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        _scrollView = [[IQRulerScrollView alloc] initWithFrame:self.bounds];
//        _scrollView.backgroundColor = [UIColor purpleColor];
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = NO;
        _scrollView.layer.magnificationFilter = kCAFilterNearest;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scrollView];
    }
    
    return _scrollView;
}

-(UIImage *)image
{
    return self.scrollView.image;
}

-(void)setImage:(UIImage *)image
{
    restoreToMinimumScale = YES;

    self.scrollView.image = image;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.scrollView.doubleTapRecognizer.enabled = image != nil;
    self.scrollView.doubleTapTwoFingerRecognizer.enabled = image != nil;
    self.zoomInfoContainerView.hidden = image == nil;
}

-(SRLineImageView *)imageView
{
    return self.scrollView.imageView;
}

-(CGFloat)zoomScale
{
    return self.scrollView.zoomScale;
}

-(void)setZoomScale:(CGFloat)zoomScale
{
    self.scrollView.zoomScale = zoomScale;
}

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated
{
    [self.scrollView setZoomScale:scale animated:animated];
}

-(void)setMinimumZoomScale:(CGFloat)minimumZoomScale
{
    self.scrollView.minimumZoomScale = minimumZoomScale;
}

-(void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
    self.scrollView.maximumZoomScale = maximumZoomScale;
}

-(CGFloat)minimumZoomScale
{
    return self.scrollView.minimumZoomScale;
}

-(CGFloat)maximumZoomScale
{
    return self.scrollView.maximumZoomScale;
}

- (void)zoomToMinimumScaleAnimated:(BOOL)animated
{
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:animated];
}

- (void)zoomToOriginalScaleAnimated:(BOOL)animated
{
    [self.scrollView setZoomScale:1 animated:animated];
}

- (void)zoomToMaximumScaleAnimated:(BOOL)animated
{
    [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:animated];
}

-(CGPoint)contentOffset
{
    return self.scrollView.contentOffset;
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    self.scrollView.contentOffset = contentOffset;
}

-(void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [self.scrollView setContentOffset:contentOffset animated:animated];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.scrollView.contentView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
    {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
        [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidZoom:)])
    {
        [self.delegate scrollViewDidZoom:scrollView];
    }

    NSString *zoomText = [NSString localizedStringWithFormat:@"%.0f%%",(CGFloat)scrollView.zoomScale*100.0];
    [self.zoomInfoButton setTitle:zoomText forState:UIControlStateNormal];

    self.zoomDecreaseButton.enabled = !(scrollView.zoomScale <= scrollView.minimumZoomScale);
    self.zoomIncreaseButton.enabled = !(scrollView.zoomScale >= scrollView.maximumZoomScale);
}

-(void)setShowZoomControls:(BOOL)showZoomControls
{
    _showZoomControls = showZoomControls;
    
    self.zoomInfoContainerView.alpha = showZoomControls?1.0:0.0;
}

#pragma mark - Zoom label

-(UIVisualEffectView *)zoomInfoContainerView
{
    if (_zoomInfoContainerView == nil)
    {
        CGRect rect = CGRectMake(0, 0, 168, 44);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            rect = CGRectMake(0, 0, 270, 70);
        }

        _zoomInfoContainerView = [[UIVisualEffectView alloc] initWithFrame:rect];
        _zoomInfoContainerView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _zoomInfoContainerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)-25);
        _zoomInfoContainerView.layer.cornerRadius = 22;
        _zoomInfoContainerView.layer.borderWidth = 1;
        _zoomInfoContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _zoomInfoContainerView.layer.masksToBounds = YES;
        _zoomInfoContainerView.hidden = YES;
        _zoomInfoContainerView.tintColor = [UIColor redColor];
        _zoomInfoContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        [_zoomInfoContainerView.contentView addSubview:self.zoomDecreaseButton];
        [_zoomInfoContainerView.contentView addSubview:self.zoomIncreaseButton];
        [_zoomInfoContainerView.contentView addSubview:self.zoomInfoButton];
    }
    
    return _zoomInfoContainerView;
}

-(UIButton *)zoomIncreaseButton
{
    if (_zoomIncreaseButton == nil)
    {
        _zoomIncreaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_zoomIncreaseButton setTitle:[NSString localizedStringWithFormat:@"+"] forState:UIControlStateNormal];
        [_zoomIncreaseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_zoomIncreaseButton setTitleColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            _zoomIncreaseButton.frame = CGRectMake(CGRectGetMaxX(self.zoomInfoButton.frame), 0, 70, 70);
            _zoomIncreaseButton.titleLabel.font = [UIFont kohinoorBanglaSemiboldWithSize:56];
        }
        else
        {
            _zoomIncreaseButton.frame = CGRectMake(CGRectGetMaxX(self.zoomInfoButton.frame), 0, 44, 44);
            _zoomIncreaseButton.titleLabel.font = [UIFont kohinoorBanglaSemiboldWithSize:35];
        }

        [_zoomIncreaseButton addTarget:self action:@selector(zoomIncreaseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomIncreaseButton;
}

-(void)zoomIncreaseAction:(UIButton*)button
{
    [self setZoomScale:MIN(self.zoomScale*2, self.maximumZoomScale) animated:YES];
}

-(UIButton *)zoomDecreaseButton
{
    if (_zoomDecreaseButton == nil)
    {
        _zoomDecreaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_zoomDecreaseButton setTitle:[NSString localizedStringWithFormat:@"-"] forState:UIControlStateNormal];
        [_zoomDecreaseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_zoomDecreaseButton setTitleColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            _zoomDecreaseButton.frame = CGRectMake(CGRectGetMinX(self.zoomInfoButton.frame)-70, 0, 70, 70);
            _zoomDecreaseButton.titleLabel.font = [UIFont kohinoorBanglaSemiboldWithSize:56];
        }
        else
        {
            _zoomDecreaseButton.frame = CGRectMake(CGRectGetMinX(self.zoomInfoButton.frame)-44, 0, 44, 44);
            _zoomDecreaseButton.titleLabel.font = [UIFont kohinoorBanglaSemiboldWithSize:35];
        }

        [_zoomDecreaseButton addTarget:self action:@selector(zoomDecreaseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomDecreaseButton;
}

-(void)zoomDecreaseAction:(UIButton*)button
{
    [self setZoomScale:MAX(self.zoomScale/2, self.minimumZoomScale) animated:YES];
}

-(UIButton *)zoomInfoButton
{
    if (_zoomInfoButton == nil)
    {
        _zoomInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zoomInfoButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_zoomInfoButton setTitleColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            _zoomInfoButton.frame = CGRectMake(0, 0, 110, 70);
            _zoomInfoButton.titleLabel.font = [UIFont kohinoorBanglaSemiboldWithSize:29];
        }
        else
        {
            _zoomInfoButton.frame = CGRectMake(0, 0, 70, 44);
            _zoomInfoButton.titleLabel.font = [UIFont kohinoorBanglaSemiboldWithSize:18];
        }

        _zoomInfoButton.center = CGPointMake(CGRectGetMidX(self.zoomInfoContainerView.bounds), CGRectGetMidY(self.zoomInfoContainerView.bounds));
        _zoomInfoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _zoomInfoButton.titleLabel.minimumScaleFactor = 0.5;
        [_zoomInfoButton addTarget:self action:@selector(zoomInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _zoomInfoButton;
}

-(void)zoomInfoAction:(UIButton*)button
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"zoom_scale", nil) preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak typeof(self) weakSelf = self;

        if (self.zoomScale != 1.0)
        {
            [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:NSLocalizedString(@"original_percent", nil),(CGFloat)100]  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf zoomToOriginalScaleAnimated:YES];
            }]];
        }
        
        if (self.zoomScale != self.minimumZoomScale)
        {
            CGFloat zoomPercent = self.minimumZoomScale*100.0;

            [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:NSLocalizedString(@"minimum_percent", nil),zoomPercent] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf zoomToMinimumScaleAnimated:YES];
            }]];
        }

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        alertController.popoverPresentationController.sourceView = button;
        
        [(UIViewController*)nextResponder presentViewController:alertController animated:YES completion:^{
        }];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
//    [self layoutImageScrollView];
    
    CGFloat zoomScale = IQAspectScaleFit(self.image.size,self.bounds);
    self.minimumZoomScale = zoomScale;
    self.maximumZoomScale = [[UIScreen  mainScreen] bounds].size.width;
    
    CGFloat oldZoomScale = self.zoomScale;
    
    if (restoreToMinimumScale == YES)
    {
        oldZoomScale = zoomScale;
        restoreToMinimumScale = NO;
    }
    
    CGFloat neededZoomScale = MAX(self.minimumZoomScale, oldZoomScale);
    neededZoomScale = MIN(self.maximumZoomScale, neededZoomScale);
    
    if (neededZoomScale != self.zoomScale)
    {
        self.zoomScale = neededZoomScale;
    }

    self.zoomDecreaseButton.enabled = !(self.zoomScale <= self.minimumZoomScale);
    self.zoomIncreaseButton.enabled = !(self.zoomScale >= self.maximumZoomScale);
}

-(CGRect)contentRect
{
    if (self.image)
    {
        return IQRectAspectFit(self.image.size,self.bounds);
    }
    else
    {
        return self.bounds;
    }
}

#pragma mark - Rotation

- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer
{
    CGAffineTransform transform = CGAffineTransformRotate(self.scrollView.transform, gestureRecognizer.rotation);
    self.scrollView.transform = transform;

    gestureRecognizer.rotation = 0;
}

-(CGFloat)rotationAngle
{
    return IQAffineTransformGetAngle(self.scrollView.transform);
}

- (void)layoutImageScrollView
{
//    CGRect frame = self.contentRect;
//    frame.origin = CGPointZero;
//    
//    if (self.rotationAngle != 0.0)
//    {
//        // Step 1: Rotate the left edge of the initial rect of the image scroll view clockwise around the center by `rotationAngle`.
//        CGFloat rotationAngle = self.rotationAngle;
//        
//        frame = IQBoundAspectFitRectWithAngle(frame,rotationAngle);
//    }
//    
//    CGAffineTransform transform = self.scrollView.transform;
//    self.scrollView.transform = CGAffineTransformIdentity;
//    self.scrollView.bounds = frame;
//    self.scrollView.transform = transform;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


@end


@implementation UIView (IQScrollContainerViewHierarchy)

-(IQScrollContainerView *)scrollContainerView
{
    UIView *superview = self.superview;
    
    while (superview) {
        if ([superview isKindOfClass:[IQScrollContainerView class]]) {
            return (IQScrollContainerView*)superview;
            break;
        }
        else {
            superview = superview.superview;
        }
    }
    
    return nil;
}

@end

