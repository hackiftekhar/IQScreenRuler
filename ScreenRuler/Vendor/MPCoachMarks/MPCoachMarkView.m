//
//  MPCoachMarks.m
//  Example
//
//  Created by marcelo.perretta@gmail.com on 7/8/15.
//  Copyright (c) 2015 MAWAPE. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MPCoachMarkView.h"
#import "UIColor+ThemeColor.h"
#import "UIFont+AppFont.h"

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 5.0f;
static const CGFloat kMaxLblWidth = 230.0f;
static const CGFloat kLblSpacing = 35.0f;
static const CGFloat kLabelMargin = 20.0f;
static const CGFloat kMaskAlpha = 0.5f;
static const BOOL kEnableContinueLabel = NO;
static const BOOL kEnableSkipButton = YES;

@interface MPCoachMarkView ()<CAAnimationDelegate>

@end

@implementation MPCoachMarkView {
    CAShapeLayer *mask;
    UIView *currentView;
}

#pragma mark - Properties

@synthesize delegate;
@synthesize coachMarks;
@synthesize lblCaption;
@synthesize lblContinue;
@synthesize btnSkipCoach;
@synthesize maskColor = _maskColor;
@synthesize animationDuration;
@synthesize cutoutRadius;
@synthesize maxLblWidth;
@synthesize lblSpacing;
@synthesize enableContinueLabel;
@synthesize enableSkipButton;
@synthesize arrowImage;
@synthesize continueLocation;

#pragma mark - Methods

- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks {
    self = [super initWithFrame:frame];
    if (self) {
        // Save the coach marks
        self.coachMarks = marks;
        
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (void)setup {
    // Default
    self.animationDuration = kAnimationDuration;
    self.cutoutRadius = kCutoutRadius;
    self.maxLblWidth = kMaxLblWidth;
    self.lblSpacing = kLblSpacing;
    self.enableContinueLabel = kEnableContinueLabel;
    self.enableSkipButton = kEnableSkipButton;
    
    // Shape layer mask
    mask = [CAShapeLayer layer];
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
//    mask.path = maskPath.CGPath;
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:kMaskAlpha] CGColor]];
    [self.layer addSublayer:mask];
    
    // Capture touches
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    UIColor *originalThemeColor = [UIColor originalThemeColor];

    // Captions
    self.lblCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}}];
    self.lblCaption.adjustsFontSizeToFitWidth = YES;
    self.lblCaption.minimumScaleFactor = 0.5;
    self.lblCaption.backgroundColor = [UIColor blackColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.layer.masksToBounds = YES;
    self.lblCaption.layer.borderColor = originalThemeColor.CGColor;
    self.lblCaption.layer.borderWidth = 1.0;
    self.lblCaption.layer.cornerRadius = 5.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.lblCaption.font = [UIFont kohinoorBanglaSemiboldWithSize:27.0f];
    }
    else
    {
        self.lblCaption.font = [UIFont kohinoorBanglaSemiboldWithSize:17.0f];
    }

    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.textAlignment = NSTextAlignmentCenter;
    self.lblCaption.alpha = 0.0f;
    [self addSubview:self.lblCaption];
    
    //Location Position
    self.continueLocation = LOCATION_BOTTOM;
    
    // Hide until unvoked
    self.hidden = YES;
}

#pragma mark - Cutout modify

- (void)setCutoutToRect:(CGRect)rect withShape:(MaskShape)shape{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if (shape == SHAPE_CIRCLE)
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    mask.path = maskPath.CGPath;
}

- (void)animateCutoutToRect:(CGRect)rect withShape:(MaskShape)shape{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if (shape == SHAPE_CIRCLE)
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    
    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}

#pragma mark - Mask color

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [mask setFillColor:[maskColor CGColor]];
}

#pragma mark - Touch handler

- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    
    // Go to the next coach mark
    
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willMoveFromIndex:)])
    {
        [self.delegate coachMarksView:self willMoveFromIndex:self.markIndex];
    }
    
    [self goToCoachMarkIndexed:(self.markIndex+1)];
}

#pragma mark - Navigation

- (void)start {
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         weakSelf.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [weakSelf goToCoachMarkIndexed:0];
                     }];
}

+ (instancetype)startWithCoachMarks:(NSArray*)marks
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    MPCoachMarkView *coachMarkView = [[MPCoachMarkView alloc] initWithFrame:window.frame coachMarks:marks];
    
    [window addSubview:coachMarkView];

    [coachMarkView start];
    
    return coachMarkView;
}

- (void)skipCoach {
    
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willMoveFromIndex:)])
    {
        [self.delegate coachMarksView:self willMoveFromIndex:self.markIndex];
    }
    
    [self goToCoachMarkIndexed:self.coachMarks.count];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate coachMarksViewDidClicked:self atIndex:self.markIndex];
    [self cleanup];
}

- (void)goToCoachMarkIndexed:(NSUInteger)index
{
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return;
    }
    
    // Current index
    _markIndex = index;
    
    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:self.markIndex];
    }
    
    // Coach mark definition
    __weak MPCoachMark *markDef = [self.coachMarks objectAtIndex:index];
    
    __weak typeof(self) weakSelf = self;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(markDef.beginInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        CGRect markRect = markDef.rect;
        
        if (markDef.view.superview)
        {
            if (CGRectIsEmpty(markDef.rect))
            {
                markRect = [markDef.view.superview convertRect:markDef.view.frame toView:weakSelf];
            }
            else
            {
                markRect = [markDef.view convertRect:markDef.rect toView:weakSelf];
            }
        }
        
        markRect = UIEdgeInsetsInsetRect(markRect, markDef.inset);
        
        if ([weakSelf.delegate respondsToSelector:@selector(coachMarksViewDidClicked:atIndex:)])
        {
            [currentView removeFromSuperview];
            currentView = [[UIView alloc] initWithFrame:markRect];
            currentView.backgroundColor = [UIColor clearColor];
            UITapGestureRecognizer *singleFingerTap =
            [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(handleSingleTap:)];
            [currentView addGestureRecognizer:singleFingerTap];
            [weakSelf addSubview:currentView];
        }
        
        [weakSelf.arrowImage removeFromSuperview];
        
        // Calculate the caption position and size
        weakSelf.lblCaption.alpha = 0.0f;
        weakSelf.lblCaption.frame = (CGRect){{0.0f, 0.0f}, {weakSelf.maxLblWidth, 0.0f}};
        weakSelf.lblCaption.text = markDef.caption;
        [weakSelf.lblCaption sizeToFit];
        weakSelf.lblCaption.frame = CGRectInset(weakSelf.lblCaption.frame, -10, -10);
        CGFloat y;
        CGFloat x;
        
        
        //Label Aligment and Position
        switch (markDef.alignment) {
            case LABEL_ALIGNMENT_RIGHT:
                x = floorf(weakSelf.bounds.size.width - weakSelf.lblCaption.frame.size.width - kLabelMargin);
                break;
            case LABEL_ALIGNMENT_LEFT:
                x = kLabelMargin;
                break;
            default:
                x = floorf((weakSelf.bounds.size.width - weakSelf.lblCaption.frame.size.width) / 2.0f);
                break;
        }
        
        UIColor *originalThemeColor = [UIColor originalThemeColor];

        switch (markDef.position) {
            case LABEL_POSITION_TOP:
            {
                y = markRect.origin.y - weakSelf.lblCaption.frame.size.height - kLabelMargin;
                if(markDef.image)
                {
                    weakSelf.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    weakSelf.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = weakSelf.arrowImage.frame;
                    imageViewFrame.origin.x = x;
                    imageViewFrame.origin.y = y;
                    weakSelf.arrowImage.frame = imageViewFrame;
                    y -= (weakSelf.arrowImage.frame.size.height + kLabelMargin);
                    [weakSelf addSubview:weakSelf.arrowImage];
                }
            }
                break;
            case LABEL_POSITION_LEFT:
            {
                y = markRect.origin.y + markRect.size.height/2 - weakSelf.lblCaption.frame.size.height/2;
                x = weakSelf.bounds.size.width - weakSelf.lblCaption.frame.size.width - kLabelMargin - markRect.size.width;
                if(markDef.image)
                {
                    weakSelf.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    weakSelf.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = weakSelf.arrowImage.frame;
                    imageViewFrame.origin.x = weakSelf.bounds.size.width - weakSelf.arrowImage.frame.size.width - kLabelMargin - markRect.size.width;
                    imageViewFrame.origin.y = y + weakSelf.lblCaption.frame.size.height/2 - imageViewFrame.size.height/2;
                    weakSelf.arrowImage.frame = imageViewFrame;
                    x -= (weakSelf.arrowImage.frame.size.width + kLabelMargin);
                    [weakSelf addSubview:weakSelf.arrowImage];
                }
            }
                break;
            case LABEL_POSITION_RIGHT:
            {
                y = markRect.origin.y + markRect.size.height/2 - weakSelf.lblCaption.frame.size.height/2;
                x = markRect.origin.x + markRect.size.width + kLabelMargin;
                if(markDef.image) {
                    weakSelf.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    weakSelf.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = weakSelf.arrowImage.frame;
                    imageViewFrame.origin.x = x;
                    imageViewFrame.origin.y = y;
                    weakSelf.arrowImage.frame = imageViewFrame;
                    y -= (weakSelf.arrowImage.frame.size.height + kLabelMargin);
                    [weakSelf addSubview:weakSelf.arrowImage];
                }
            }
                break;
            case LABEL_POSITION_RIGHT_BOTTOM:
            {
                y = markRect.origin.y + markRect.size.height + weakSelf.lblSpacing;
                CGFloat bottomY = y + weakSelf.lblCaption.frame.size.height + weakSelf.lblSpacing;
                if (bottomY > weakSelf.bounds.size.height) {
                    y = markRect.origin.y - weakSelf.lblSpacing - weakSelf.lblCaption.frame.size.height;
                }
                x = markRect.origin.x + markRect.size.width + kLabelMargin;
                if(markDef.image)
                {
                    weakSelf.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    weakSelf.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = weakSelf.arrowImage.frame;
                    imageViewFrame.origin.x = x - markRect.size.width/2 - imageViewFrame.size.width/2;
                    imageViewFrame.origin.y = y - kLabelMargin; //weakSelf.lblCaption.frame.size.height/2
                    y += imageViewFrame.size.height/2;
                    weakSelf.arrowImage.frame = imageViewFrame;
                    [weakSelf addSubview:weakSelf.arrowImage];
                }
            }
                break;
            default: {
                y = markRect.origin.y + markRect.size.height + weakSelf.lblSpacing;
                CGFloat bottomY = y + weakSelf.lblCaption.frame.size.height + weakSelf.lblSpacing;
                if (bottomY > weakSelf.bounds.size.height) {
                    y = markRect.origin.y - weakSelf.lblSpacing - weakSelf.lblCaption.frame.size.height;
                }
                if(markDef.image)
                {
                    weakSelf.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    weakSelf.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = weakSelf.arrowImage.frame;
                    imageViewFrame.origin.x = x;
                    imageViewFrame.origin.y = y;
                    weakSelf.arrowImage.frame = imageViewFrame;
                    y += (weakSelf.arrowImage.frame.size.height + kLabelMargin);
                    [weakSelf addSubview:weakSelf.arrowImage];
                }
            }
                break;
        }
        
        // Animate the caption label
        weakSelf.lblCaption.frame = (CGRect){{x, y}, weakSelf.lblCaption.frame.size};
        
        [UIView animateWithDuration:0.3f animations:^{
            weakSelf.lblCaption.alpha = 1.0f;
        }];
        
        // If first mark, set the cutout to the center of first mark
        if (weakSelf.markIndex == 0)
        {
            CGRect rect = markRect;
            
            CGFloat maxXDistance = MAX(CGRectGetMinX(rect), CGRectGetWidth(weakSelf.bounds)-CGRectGetMaxX(rect));
            CGFloat maxYDistance = MAX(CGRectGetMinY(rect), CGRectGetHeight(weakSelf.bounds)-CGRectGetMaxY(rect));
            CGFloat maxDistance = MAX(maxXDistance, maxYDistance);
            
            rect = CGRectInset(rect, -maxDistance, -maxDistance);
            
            [weakSelf setCutoutToRect:rect withShape:markDef.shape];
        }
        
        // Animate the cutout
        [weakSelf animateCutoutToRect:markRect withShape:markDef.shape];
        mask.strokeColor = markDef.borderColor.CGColor;
        
        CGFloat lblContinueWidth =  (weakSelf.enableContinueLabel?(weakSelf.enableSkipButton ? (70.0/100.0) * weakSelf.bounds.size.width : weakSelf.bounds.size.width):0);
        CGFloat btnSkipWidth = weakSelf.bounds.size.width - lblContinueWidth;
        
        // Show continue lbl if first mark
        if (weakSelf.enableContinueLabel) {
            if (weakSelf.markIndex == 0) {
                lblContinue = [[UILabel alloc] initWithFrame:(CGRect){{0, [weakSelf yOriginForContinueLabel]}, {lblContinueWidth, 30.0f}}];
                lblContinue.adjustsFontSizeToFitWidth = YES;
                lblContinue.minimumScaleFactor = 0.5;
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    lblContinue.font = [UIFont kohinoorBanglaSemiboldWithSize:21.0f];
                }
                else
                {
                    lblContinue.font = [UIFont kohinoorBanglaSemiboldWithSize:13.0f];
                }

                lblContinue.textAlignment = NSTextAlignmentCenter;
                lblContinue.text = NSLocalizedString(@"tap_to_continue", nil);
                lblContinue.alpha = 0.0f;
                lblContinue.backgroundColor = [UIColor whiteColor];
                [weakSelf addSubview:lblContinue];
                [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                    weakSelf.lblContinue.alpha = 1.0f;
                } completion:nil];
            } else if (weakSelf.markIndex > 0 && lblContinue != nil) {
                // Otherwise, remove the lbl
                [lblContinue removeFromSuperview];
                lblContinue = nil;
            }
        } else {
            
        }
        
        if (weakSelf.enableSkipButton) {
            btnSkipCoach = [UIButton buttonWithType:UIButtonTypeSystem];
            btnSkipCoach.frame = (CGRect){{lblContinueWidth, [weakSelf yOriginForContinueLabel]}, {btnSkipWidth, 30.0f}};
            [btnSkipCoach addTarget:weakSelf action:@selector(skipCoach) forControlEvents:UIControlEventTouchUpInside];
            [btnSkipCoach setTitle:NSLocalizedString(@"skip", nil) forState:UIControlStateNormal];
            btnSkipCoach.titleLabel.font = [UIFont kohinoorBanglaSemiboldWithSize:13.0f];
            btnSkipCoach.alpha = 0.0f;
            btnSkipCoach.tintColor = [UIColor whiteColor];
            [weakSelf addSubview:btnSkipCoach];
            [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                weakSelf.btnSkipCoach.alpha = 1.0f;
            } completion:nil];
        }
    });
}

- (CGFloat)yOriginForContinueLabel {
    switch (self.continueLocation) {
        case LOCATION_TOP:
            return 20.0f;
        case LOCATION_CENTER:
            return self.bounds.size.height / 2 - 15.0f;
        default:
            return self.bounds.size.height - 30.0f;
    }
}

#pragma mark - Cleanup

- (void)cleanup {
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }
    
    __weak typeof(self) weakSelf = self;

    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         weakSelf.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [weakSelf removeFromSuperview];
                         
                         // Delegate (coachMarksViewDidCleanup:)
                         if ([weakSelf.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [weakSelf.delegate coachMarksViewDidCleanup:weakSelf];
                         }
                     }];
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:self.markIndex];
    }
}

@end

