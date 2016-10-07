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
    self.lblCaption.backgroundColor = [UIColor blackColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.layer.masksToBounds = YES;
    self.lblCaption.layer.borderColor = originalThemeColor.CGColor;
    self.lblCaption.layer.borderWidth = 1.0;
    self.lblCaption.layer.cornerRadius = 5.0;
    self.lblCaption.font = [UIFont kohinoorBanglaSemiboldWithSize:17.0f];
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
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [self goToCoachMarkIndexed:0];
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
    MPCoachMark *markDef = [self.coachMarks objectAtIndex:index];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(markDef.beginInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        CGRect markRect = markDef.rect;
        
        if (markDef.view.superview)
        {
            if (CGRectIsEmpty(markDef.rect))
            {
                markRect = [markDef.view.superview convertRect:markDef.view.frame toView:self];
            }
            else
            {
                markRect = [markDef.view convertRect:markDef.rect toView:self];
            }
        }
        
        markRect = UIEdgeInsetsInsetRect(markRect, markDef.inset);
        
        if ([self.delegate respondsToSelector:@selector(coachMarksViewDidClicked:atIndex:)])
        {
            [currentView removeFromSuperview];
            currentView = [[UIView alloc] initWithFrame:markRect];
            currentView.backgroundColor = [UIColor clearColor];
            UITapGestureRecognizer *singleFingerTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [currentView addGestureRecognizer:singleFingerTap];
            [self addSubview:currentView];
        }
        
        [self.arrowImage removeFromSuperview];
        
        // Calculate the caption position and size
        self.lblCaption.alpha = 0.0f;
        self.lblCaption.frame = (CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}};
        self.lblCaption.text = markDef.caption;
        [self.lblCaption sizeToFit];
        self.lblCaption.frame = CGRectInset(self.lblCaption.frame, -10, -10);
        CGFloat y;
        CGFloat x;
        
        
        //Label Aligment and Position
        switch (markDef.alignment) {
            case LABEL_ALIGNMENT_RIGHT:
                x = floorf(self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin);
                break;
            case LABEL_ALIGNMENT_LEFT:
                x = kLabelMargin;
                break;
            default:
                x = floorf((self.bounds.size.width - self.lblCaption.frame.size.width) / 2.0f);
                break;
        }
        
        UIColor *originalThemeColor = [UIColor originalThemeColor];

        switch (markDef.position) {
            case LABEL_POSITION_TOP:
            {
                y = markRect.origin.y - self.lblCaption.frame.size.height - kLabelMargin;
                if(markDef.image)
                {
                    self.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    self.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = self.arrowImage.frame;
                    imageViewFrame.origin.x = x;
                    imageViewFrame.origin.y = y;
                    self.arrowImage.frame = imageViewFrame;
                    y -= (self.arrowImage.frame.size.height + kLabelMargin);
                    [self addSubview:self.arrowImage];
                }
            }
                break;
            case LABEL_POSITION_LEFT:
            {
                y = markRect.origin.y + markRect.size.height/2 - self.lblCaption.frame.size.height/2;
                x = self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin - markRect.size.width;
                if(markDef.image)
                {
                    self.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    self.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = self.arrowImage.frame;
                    imageViewFrame.origin.x = self.bounds.size.width - self.arrowImage.frame.size.width - kLabelMargin - markRect.size.width;
                    imageViewFrame.origin.y = y + self.lblCaption.frame.size.height/2 - imageViewFrame.size.height/2;
                    self.arrowImage.frame = imageViewFrame;
                    x -= (self.arrowImage.frame.size.width + kLabelMargin);
                    [self addSubview:self.arrowImage];
                }
            }
                break;
            case LABEL_POSITION_RIGHT:
            {
                y = markRect.origin.y + markRect.size.height/2 - self.lblCaption.frame.size.height/2;
                x = markRect.origin.x + markRect.size.width + kLabelMargin;
                if(markDef.image) {
                    self.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    self.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = self.arrowImage.frame;
                    imageViewFrame.origin.x = x;
                    imageViewFrame.origin.y = y;
                    self.arrowImage.frame = imageViewFrame;
                    y -= (self.arrowImage.frame.size.height + kLabelMargin);
                    [self addSubview:self.arrowImage];
                }
            }
                break;
            case LABEL_POSITION_RIGHT_BOTTOM:
            {
                y = markRect.origin.y + markRect.size.height + self.lblSpacing;
                CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
                if (bottomY > self.bounds.size.height) {
                    y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
                }
                x = markRect.origin.x + markRect.size.width + kLabelMargin;
                if(markDef.image)
                {
                    self.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    self.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = self.arrowImage.frame;
                    imageViewFrame.origin.x = x - markRect.size.width/2 - imageViewFrame.size.width/2;
                    imageViewFrame.origin.y = y - kLabelMargin; //self.lblCaption.frame.size.height/2
                    y += imageViewFrame.size.height/2;
                    self.arrowImage.frame = imageViewFrame;
                    [self addSubview:self.arrowImage];
                }
            }
                break;
            default: {
                y = markRect.origin.y + markRect.size.height + self.lblSpacing;
                CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
                if (bottomY > self.bounds.size.height) {
                    y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
                }
                if(markDef.image)
                {
                    self.arrowImage = [[UIImageView alloc] initWithImage:markDef.image];
                    self.arrowImage.tintColor = originalThemeColor;
                    CGRect imageViewFrame = self.arrowImage.frame;
                    imageViewFrame.origin.x = x;
                    imageViewFrame.origin.y = y;
                    self.arrowImage.frame = imageViewFrame;
                    y += (self.arrowImage.frame.size.height + kLabelMargin);
                    [self addSubview:self.arrowImage];
                }
            }
                break;
        }
        
        // Animate the caption label
        self.lblCaption.frame = (CGRect){{x, y}, self.lblCaption.frame.size};
        
        [UIView animateWithDuration:0.3f animations:^{
            self.lblCaption.alpha = 1.0f;
        }];
        
        // If first mark, set the cutout to the center of first mark
        if (self.markIndex == 0)
        {
            CGRect rect = markRect;
            
            CGFloat maxXDistance = MAX(CGRectGetMinX(rect), CGRectGetWidth(self.bounds)-CGRectGetMaxX(rect));
            CGFloat maxYDistance = MAX(CGRectGetMinY(rect), CGRectGetHeight(self.bounds)-CGRectGetMaxY(rect));
            CGFloat maxDistance = MAX(maxXDistance, maxYDistance);
            
            rect = CGRectInset(rect, -maxDistance, -maxDistance);
            
            [self setCutoutToRect:rect withShape:markDef.shape];
        }
        
        // Animate the cutout
        [self animateCutoutToRect:markRect withShape:markDef.shape];
        mask.strokeColor = markDef.borderColor.CGColor;
        
        CGFloat lblContinueWidth =  (self.enableContinueLabel?(self.enableSkipButton ? (70.0/100.0) * self.bounds.size.width : self.bounds.size.width):0);
        CGFloat btnSkipWidth = self.bounds.size.width - lblContinueWidth;
        
        // Show continue lbl if first mark
        if (self.enableContinueLabel) {
            if (self.markIndex == 0) {
                lblContinue = [[UILabel alloc] initWithFrame:(CGRect){{0, [self yOriginForContinueLabel]}, {lblContinueWidth, 30.0f}}];
                lblContinue.font = [UIFont kohinoorBanglaSemiboldWithSize:13.0f];
                lblContinue.textAlignment = NSTextAlignmentCenter;
                lblContinue.text = NSLocalizedString(@"Tap to continue", nil);
                lblContinue.alpha = 0.0f;
                lblContinue.backgroundColor = [UIColor whiteColor];
                [self addSubview:lblContinue];
                [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                    lblContinue.alpha = 1.0f;
                } completion:nil];
            } else if (self.markIndex > 0 && lblContinue != nil) {
                // Otherwise, remove the lbl
                [lblContinue removeFromSuperview];
                lblContinue = nil;
            }
        } else {
            
        }
        
        if (self.enableSkipButton) {
            btnSkipCoach = [UIButton buttonWithType:UIButtonTypeSystem];
            btnSkipCoach.frame = (CGRect){{lblContinueWidth, [self yOriginForContinueLabel]}, {btnSkipWidth, 30.0f}};
            [btnSkipCoach addTarget:self action:@selector(skipCoach) forControlEvents:UIControlEventTouchUpInside];
            [btnSkipCoach setTitle:NSLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
            btnSkipCoach.titleLabel.font = [UIFont kohinoorBanglaSemiboldWithSize:13.0f];
            btnSkipCoach.alpha = 0.0f;
            btnSkipCoach.tintColor = [UIColor whiteColor];
            [self addSubview:btnSkipCoach];
            [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                btnSkipCoach.alpha = 1.0f;
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
    
    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [self removeFromSuperview];
                         
                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [self.delegate coachMarksViewDidCleanup:self];
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

