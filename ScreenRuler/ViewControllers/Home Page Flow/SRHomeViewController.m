//
//  ViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRHomeViewController.h"
#import "IQRulerView.h"
#import "SRToolbarButton.h"
#import "UIImage+Color.h"
#import "UIColor+HexColors.h"
#import <Photos/Photos.h>
#import "UIFont+AppFont.h"
#import "IQ_UIImage+Resizing.h"
#import "IQLineFrameView.h"
#import "ACMagnifyingGlass.h"
#import "MPCoachMarkView.h"
#import "IQGeometry+Rect.h"
#import "SREditOptionViewController.h"
#import "SRNavigationController.h"
#import "UIColor+ThemeColor.h"
#import <Social/Social.h>
#import "SRImagePickerController.h"
#import "IQScrollContainerView.h"
#import "SRScreenshotCollectionViewController.h"

//https://www.iconfinder.com/iconsets/hawcons-gesture-stroke

@interface SRHomeViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIToolbarDelegate,MPCoachMarksViewDelegate,ImageControllerDelegate,ScreenshotControllerDelegate>
{
    BOOL isLockedOrientation;
}

@property (nonatomic, strong) NSTimer *coachMarkTimer;

@property(nonatomic, strong) ACMagnifyingGlass *magnifyingGlass;

@property(nonatomic, strong) IQRulerView *freeRulerView;

@property (strong, nonatomic) IBOutlet IQLineFrameView *lineFrameView;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

@property (strong, nonatomic) IBOutlet IQScrollContainerView *scrollContainerView;

@property (strong, nonatomic) IBOutlet UIView *viewNoScreenshotInfo;
@property (strong, nonatomic) IBOutlet UILabel *labelNoScreenshotsTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelNoScreenshotsDiscription;
@property (strong, nonatomic) IBOutlet UIButton *noScreenshotActionButton;


@property (strong, nonatomic) IBOutlet SRToolbarButton *sideRulerButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sideRulerBarButton;
@property (strong, nonatomic) IBOutlet SRToolbarButton *freeHandButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *freeHandBarButton;
@property (strong, nonatomic) IBOutlet SRToolbarButton *straighenButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *straightenBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editOptionBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rationBarButon;
@property (strong, nonatomic) IBOutlet SRToolbarButton *ratioButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *libraryBarButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsMenuBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *optionBarButton;

@property (strong, nonatomic) IBOutlet UIView *topColorView;
@property (strong, nonatomic) IBOutlet UIView *viewColorLabelContainer;
@property (strong, nonatomic) IBOutlet UILabel *labelRed;
@property (strong, nonatomic) IBOutlet UILabel *labelGreen;
@property (strong, nonatomic) IBOutlet UILabel *labelBlue;
@property (strong, nonatomic) IBOutlet UILabel *labelColorLocation;

@end


@implementation SRHomeViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topColorView.translatesAutoresizingMaskIntoConstraints = YES;

    self.magnifyingGlass = [[ACMagnifyingGlass alloc] initWithFrame:CGRectMake(0, 0, 115, 115)];
    self.magnifyingGlass.viewToMagnify = self.scrollContainerView.imageView;

    BOOL shouldLineFrameShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"LineFrameShow"];
    BOOL shouldFreeHandRulerShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"FreeHandRulerShow"];
    BOOL shouldSideRulerShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"SideRulerShow"];

    {
        {
            self.sideRulerButton.layer.cornerRadius = 3.0;
            self.sideRulerButton.layer.masksToBounds = YES;
            self.sideRulerButton.selected = shouldSideRulerShow;
            self.sideRulerButton.frame = CGRectMake(0, 0, 35, 35);
        }
        
        {
            self.freeHandButton.layer.cornerRadius = 3.0;
            self.freeHandButton.layer.masksToBounds = YES;
            self.freeHandButton.selected = shouldFreeHandRulerShow;
            [self.freeHandButton addTarget:self action:@selector(freeRulerAction:) forControlEvents:UIControlEventTouchUpInside];
            self.freeHandButton.frame = CGRectMake(0, 0, 35, 35);
        }

        {
            self.straighenButton.layer.cornerRadius = 3.0;
            self.straighenButton.layer.masksToBounds = YES;
            self.straighenButton.selected = shouldLineFrameShow;
            [self.straighenButton addTarget:self action:@selector(straightenFrameAction:) forControlEvents:UIControlEventTouchUpInside];
            self.straighenButton.frame = CGRectMake(0, 0, 35, 35);
        }
    }
    
    {
        self.lineFrameView.respectiveView = self.scrollContainerView.imageView;
        self.lineFrameView.hideLine = !shouldLineFrameShow;
        self.lineFrameView.hideRuler = !shouldSideRulerShow;

        CGFloat width = sqrtf(powf(self.view.frame.size.width, 2)+powf(self.view.frame.size.height, 2));
        
        _freeRulerView = [[IQRulerView alloc] initWithFrame:CGRectMake(0, 0, width ,55)];
        _freeRulerView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        _freeRulerView.alpha = shouldFreeHandRulerShow?1.0:0.0;
        _freeRulerView.hidden = !shouldFreeHandRulerShow;
        _freeRulerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.view insertSubview:_freeRulerView belowSubview:self.lineFrameView];
    }
    
    {
        self.ratioButton.selected = YES;
        
        NSInteger selectedRatio = [[UIScreen mainScreen] scale];
        [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
        
        _freeRulerView.deviceScale = selectedRatio;
        _lineFrameView.deviceScale = selectedRatio;
    }
    
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
    _longPressRecognizer.minimumPressDuration = 1.0;
    _longPressRecognizer.delegate = self;
    _longPressRecognizer.enabled = NO;
    [self.scrollContainerView.scrollView addGestureRecognizer:_longPressRecognizer];
    
    [self openWithLatestScreenshot];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIColor *originalThemeColor = [UIColor originalThemeColor];
    UIColor *backgroundColor = [UIColor themeBackgroundColor];

    self.view.backgroundColor = backgroundColor;

    UIColor *shadeFactorColor = [originalThemeColor colorWithShadeFactor:0.9];
    
    //Free
    {
        self.freeRulerView.rulerColor = originalThemeColor;
        self.freeRulerView.lineColor = shadeFactorColor;
    }
    
    //Line
    {
        self.lineFrameView.rulerColor = shadeFactorColor;
        self.lineFrameView.lineColor = originalThemeColor;
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

-(void)setImage:(UIImage*)image
{
    if (image)
    {
        self.scrollContainerView.image = image;
        
        _freeRulerView.zoomScale = self.scrollContainerView.zoomScale;
        _lineFrameView.zoomScale = self.scrollContainerView.zoomScale;
        _lineFrameView.startingScalePoint = CGPointZero;
    }
    else
    {
        self.scrollContainerView.image = nil;
    }

    _longPressRecognizer.enabled = image != nil;
    _editOptionBarButton.enabled = image != nil;
    _sideRulerButton.enabled = image != nil;
    _sideRulerButton.selected = (image != nil && !_lineFrameView.hideRuler);
    _freeHandButton.enabled = image != nil;
    _freeHandButton.selected = (image != nil && _freeRulerView.alpha != 0.0);
    _straighenButton.enabled = image != nil;
    _straighenButton.selected = (image != nil && !_lineFrameView.hideLine);
    _optionBarButton.enabled = image != nil;

    _viewNoScreenshotInfo.hidden = image != nil;
    _lineFrameView.hidden = image == nil;
    _freeRulerView.hidden = image == nil;
}

- (IBAction)optionAction:(UIBarButtonItem *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[self.scrollContainerView.image] applicationActivities:nil];
        
        shareController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                             UIActivityTypeAddToReadingList,
                                             UIActivityTypeOpenInIBooks,
                                             UIActivityTypePostToTencentWeibo,
                                             UIActivityTypePostToVimeo,
                                             UIActivityTypePostToWeibo,
                                             UIActivityTypePostToFacebook,
                                             UIActivityTypePostToTwitter,
                                             UIActivityTypePostToFlickr,
                                             UIActivityTypePrint];

        shareController.popoverPresentationController.barButtonItem = sender;

        [self presentViewController:shareController animated:YES completion:^{
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Start Help Tour", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startHelpTour];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    alertController.popoverPresentationController.barButtonItem = sender;
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

-(void)startHelpTour
{
    {
        [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
        self.lineFrameView.hideLine = NO;
        self.straighenButton.selected = YES;
        
        self.lineFrameView.hideRuler = NO;
        self.sideRulerButton.selected = YES;
        
        self.freeHandButton.selected = NO;
        self.freeRulerView.alpha = 0.0;
    }
    
    CGRect rect = IQRectSetCenter(CGRectMake(0, 0, 160, 160), self.view.center);
    
    UIColor *originalThemeColor = [UIColor originalThemeColor];

    MPCoachMark *mark2 = [MPCoachMark markWithAttributes:@{
                                                           @"rect": [NSValue valueWithCGRect:rect],
                                                           @"caption": NSLocalizedString(@"double_tap_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"shape": @(SHAPE_CIRCLE),
                                                           @"position":@(LABEL_POSITION_TOP),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"DoubleTap"]
                                                           }];
    
    MPCoachMark *mark3 = [MPCoachMark markWithAttributes:@{
                                                           @"view": self.ratioButton,
                                                           @"caption": NSLocalizedString(@"device_scale_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsMake(-5, -5, -5, -5)],
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"arrow-top"]
                                                           }];
    
    MPCoachMark *mark4 = [MPCoachMark markWithAttributes:@{
                                                           @"rect": [NSValue valueWithCGRect:rect],
                                                           @"caption": NSLocalizedString(@"long_tap_color_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"shape": @(SHAPE_CIRCLE),
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsZero],
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"Press-and-Drag"]
                                                           }];
    
    MPCoachMark *mark5 = [MPCoachMark markWithAttributes:@{
                                                           @"view":_lineFrameView,
                                                           @"rect": [NSValue valueWithCGRect:CGRectMake(0, self.lineFrameView.frame.origin.y, 20, self.lineFrameView.frame.size.height)],
                                                           @"caption": NSLocalizedString(@"vertical_scale_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsZero],
                                                           @"shape": @(SHAPE_SQUARE),
                                                           @"position":@(LABEL_POSITION_RIGHT),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"Scroll-Vertical"]
                                                           }];
    
    MPCoachMark *mark6 = [MPCoachMark markWithAttributes:@{
                                                           @"view":_lineFrameView,
                                                           @"rect": [NSValue valueWithCGRect:CGRectMake(0, 0, self.lineFrameView.frame.size.width, 20)],
                                                           @"caption": NSLocalizedString(@"horizontal_scale_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsZero],
                                                           @"shape": @(SHAPE_SQUARE),
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"Scroll-Horizontal"]
                                                           }];
    
    MPCoachMark *mark7 = [MPCoachMark markWithAttributes:@{
                                                           @"view":_lineFrameView,
                                                           @"rect": [NSValue valueWithCGRect:CGRectMake(0, 0, self.lineFrameView.frame.size.width, 20)],
                                                           @"caption": NSLocalizedString(@"long_tap_scale_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsZero],
                                                           @"shape": @(SHAPE_SQUARE),
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"Press"]
                                                           }];
    // Show coach marks
    MPCoachMarkView *coachMark= [MPCoachMarkView startWithCoachMarks:@[mark2,mark3,mark4,mark5,mark6,mark7]];
    coachMark.delegate=self;
}

-(void)coachMarkTimer:(NSTimer*)timer
{
    MPCoachMarkView *coachMarksView = timer.userInfo[@"object"];
    
    switch (coachMarksView.markIndex)
    {
        case 0:
        {
            if (self.scrollContainerView.zoomScale == self.scrollContainerView.minimumZoomScale)
            {
                [self.scrollContainerView setZoomScale:self.scrollContainerView.minimumZoomScale*2 animated:YES];
            }
            else
            {
                [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
            }
        }
            break;
        case 1:
        {
            NSInteger currentRatio = [[[self.ratioButton titleForState:UIControlStateNormal] substringWithRange:NSMakeRange(1, 1)] integerValue];

            NSInteger selectedRatio = (currentRatio-1)%3+1;
            [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
            _freeRulerView.deviceScale = selectedRatio;
            _lineFrameView.deviceScale = selectedRatio;
            
            if (self.presentedViewController == nil)
            {
                [self.ratioButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
            }

        }
            break;
        case 2:
        {
            CGPoint point = self.view.center;
            point.x -= self.magnifyingGlass.touchPointOffset.x;
            point.y -= self.magnifyingGlass.touchPointOffset.y;

            CGPoint location = [self.view convertPoint:point toView:self.scrollContainerView.imageView];

            [self showRGBAtLocation:location];
        }
            break;

        case 3:
        {
            if (self.lineFrameView.startingScalePoint.y <= 0)
            {
                for (NSInteger i = 0; i<=200; i = i+3)
                {
                    CGPoint point = self.lineFrameView.startingScalePoint;
                    point.y = i;
                    
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        self.lineFrameView.startingScalePoint = point;
                    }];
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }
            else
            {
                for (NSInteger i = 200; i>=-2; i= i-3)
                {
                    CGPoint point = self.lineFrameView.startingScalePoint;
                    point.y = i;
                    
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        self.lineFrameView.startingScalePoint = point;
                    }];
                    
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }
        }
            break;
        case 4:
        {
            if (self.lineFrameView.startingScalePoint.x <= 0)
            {
                for (NSInteger i = 0; i<=200; i = i+3)
                {
                    CGPoint point = self.lineFrameView.startingScalePoint;
                    point.x = i;
                    
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        self.lineFrameView.startingScalePoint = point;
                    }];
                    
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }
            else
            {
                for (NSInteger i = 200; i>=-2; i= i-3)
                {
                    CGPoint point = self.lineFrameView.startingScalePoint;
                    point.x = i;
                    
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        self.lineFrameView.startingScalePoint = point;
                    }];
                    
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }
        }
            break;
        case 5:
        {
            if (self.presentedViewController == nil)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Set Scale point location", nil) preferredStyle:UIAlertControllerStyleActionSheet];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reset Scale to Original", nil) style:UIAlertActionStyleDestructive handler:nil]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Mark as Y reference", nil) style:UIAlertActionStyleDefault handler:nil]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                
                alertController.popoverPresentationController.sourceView = self.lineFrameView;
                
                CGPoint touchPoint = CGPointMake(CGRectGetMidX(self.lineFrameView.bounds), 10);
                alertController.popoverPresentationController.sourceRect = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);
                
                [self presentViewController:alertController animated:YES completion:^{
                }];
            }
            else
            {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
    }
}

-(void)coachMarksView:(MPCoachMarkView *)coachMarksView willMoveFromIndex:(NSUInteger)index
{
    [self.coachMarkTimer invalidate];
    self.coachMarkTimer = nil;
    
    switch (coachMarksView.markIndex)
    {
        case 0:
        {
            [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
        }
            break;
        case 1:
        {
            NSInteger selectedRatio = [[UIScreen mainScreen] scale];
            [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
            _freeRulerView.deviceScale = selectedRatio;
            _lineFrameView.deviceScale = selectedRatio;
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case 2:
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self hideRGB];
            }];
        }
            break;
        case 3:
        {
            self.lineFrameView.startingScalePoint = CGPointZero;
            [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
        }
            break;
        case 4:
        {
            self.lineFrameView.startingScalePoint = CGPointZero;
            [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
        }
            break;
            
        case 5:
        {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
    }
}

-(void)coachMarksView:(MPCoachMarkView *)coachMarksView willNavigateToIndex:(NSUInteger)index
{
    switch (index)
    {
        case 0:
        {
            isLockedOrientation = YES;
        }
            break;
        case 3:
        {
            [self.scrollContainerView setZoomScale:self.scrollContainerView.minimumZoomScale*2 animated:YES];
            
            MPCoachMark *mark = [coachMarksView.coachMarks objectAtIndex:index];
            mark.rect = CGRectMake(0, 0, 20, self.lineFrameView.frame.size.height);
        }
            break;
        case 4:
        {
            [self.scrollContainerView setZoomScale:self.scrollContainerView.minimumZoomScale*3 animated:YES];

            MPCoachMark *mark = [coachMarksView.coachMarks objectAtIndex:index];
            mark.rect = CGRectMake(0, 0, self.lineFrameView.frame.size.width, 20);
        }
            break;
            
        default:
            break;
    }
}

- (void)coachMarksView:(MPCoachMarkView *)coachMarksView didNavigateToIndex:(NSUInteger)index
{
    if (index == 1 || index == 2 || index == 5)
    {
        self.coachMarkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(coachMarkTimer:) userInfo:@{@"object":coachMarksView} repeats:NO];
    }
    else if (index == 3 || index == 4)
    {
        self.coachMarkTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(coachMarkTimer:) userInfo:@{@"object":coachMarksView} repeats:YES];
    }
    else
    {
        self.coachMarkTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(coachMarkTimer:) userInfo:@{@"object":coachMarksView} repeats:YES];
    }
    
    [self.coachMarkTimer fire];
}

- (void)coachMarksViewWillCleanup:(MPCoachMarkView *)coachMarksView
{
    [self.coachMarkTimer invalidate];
    self.coachMarkTimer = nil;

    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)coachMarksViewDidCleanup:(MPCoachMarkView *)coachMarksView
{
    isLockedOrientation = NO;
    
    [UIViewController attemptRotationToDeviceOrientation];
}

- (IBAction)optionPhotoOptions:(id)sender {
    
    void (^loadWithAuthorizationStatus)(PHAuthorizationStatus status) = ^(PHAuthorizationStatus status){
        
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied)
        {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (status == PHAuthorizationStatusAuthorized)
        {
            SRScreenshotCollectionViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SRScreenshotCollectionViewController class])];
            controller.delegate = self;
            [controller presentOverViewController:self.navigationControllerSR completion:nil];
        }
    };
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                loadWithAuthorizationStatus(status);
            }];
        }];
    }
    else
    {
        loadWithAuthorizationStatus([PHPhotoLibrary authorizationStatus]);
    }
}

-(void)screenshotControllerDidSelectOpenPhotoLibrary:(SRScreenshotCollectionViewController*)controller
{
    [controller dismissViewControllerCompletion:^{
        if ([SRImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            SRImagePickerController *controller = [[SRImagePickerController alloc] init];
            controller.delegate = self;
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }];
}

-(void)screenshotControllerDidSelectOpenCamera:(SRScreenshotCollectionViewController*)controller
{
    [controller dismissViewControllerCompletion:^{
        if ([SRImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            SRImagePickerController *controller = [[SRImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }];
}

-(void)screenshotController:(SRScreenshotCollectionViewController*)controller didSelectScreenshot:(UIImage*)image
{
    [controller dismissViewControllerCompletion:^{
        self.image = image;
    }];
}

-(void)imagePickerController:(SRImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.image = image;
    [self.scrollContainerView zoomToMinimumScaleAnimated:YES];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)openWithLatestScreenshot
{
    void (^loadWithAuthorizationStatus)(PHAuthorizationStatus status) = ^(PHAuthorizationStatus status){
        
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied)
        {
            self.libraryBarButton.enabled = NO;
            [self.noScreenshotActionButton setImage:[UIImage imageNamed:@"photo_access"] forState:UIControlStateNormal];
            self.labelNoScreenshotsTitle.text = NSLocalizedString(@"photo_access_denied_title", nil);
            self.labelNoScreenshotsDiscription.text = NSLocalizedString(@"photo_access_denied_description", nil);
            self.image = nil;
        }
        else if (status == PHAuthorizationStatusAuthorized)
        {
            self.libraryBarButton.enabled = YES;
            [self.noScreenshotActionButton setImage:[UIImage imageNamed:@"iPhone-sceenshot"] forState:UIControlStateNormal];
            self.labelNoScreenshotsTitle.text = NSLocalizedString(@"no_screenshots_title", nil);
            self.labelNoScreenshotsDiscription.text = NSLocalizedString(@"no_screenshots_description", nil);
            
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityView.color = [UIColor lightGrayColor];
            activityView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
            [activityView startAnimating];
            [self.view addSubview:activityView];
            
            [self getLatestScreenshot:^(UIImage *image) {
                [activityView stopAnimating];
                [activityView removeFromSuperview];
                
                self.image = image;
                [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
            }];
        }
    };
    
    self.libraryBarButton.enabled = NO;
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                loadWithAuthorizationStatus(status);
            }];
        }];
    }
    else
    {
        loadWithAuthorizationStatus([PHPhotoLibrary authorizationStatus]);
    }
}

-(void)getLatestScreenshot:(void(^)(UIImage*))completionBlock
{
    [[NSOperationQueue new] addOperationWithBlock:^{

        PHFetchResult <PHAssetCollection *> *albums = nil;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_x_Max)
        {
            albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        }
        else
        {
            albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
        }
        
        PHAssetCollection *screenshotCollection = [albums firstObject];
        
        if (screenshotCollection)
        {
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            fetchOptions.fetchLimit = 1;
            
            PHAsset *asset = [[PHAsset fetchAssetsInAssetCollection:screenshotCollection options:fetchOptions] firstObject];
            
            if (asset)
            {
                PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];

                PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
                requestOptions.version = PHImageRequestOptionsVersionCurrent;
                requestOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
                
                [imageManager requestImageForAsset:asset
                                        targetSize:PHImageManagerMaximumSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:requestOptions
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         
                                         if (completionBlock)
                                         {
                                             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                 completionBlock(result);
                                             }];
                                         }
                                     }];
            }
            else
            {
                if (completionBlock)
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        completionBlock(nil);
                    }];
                }
            }
        }
        else
        {
            if (completionBlock)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(nil);
                }];
            }
        }
    }];
}

#pragma mark - Ratio

- (IBAction)ratioAction:(UIButton *)sender
{
    NSInteger currentRatio = [[[sender titleForState:UIControlStateNormal] substringWithRange:NSMakeRange(1, 1)] integerValue];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Change Scale Multiplier", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (currentRatio != 1)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"@%dx",1] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSInteger selectedRatio = 1;
            [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
            _freeRulerView.deviceScale = selectedRatio;
            _lineFrameView.deviceScale = selectedRatio;
        }]];
    }
    
    if (currentRatio != 2)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"@%dx",2] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger selectedRatio = 2;
            [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
            _freeRulerView.deviceScale = selectedRatio;
            _lineFrameView.deviceScale = selectedRatio;
        }]];
    }
    
    if (currentRatio != 3)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"@%dx",3] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger selectedRatio = 3;
            [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
            _freeRulerView.deviceScale = selectedRatio;
            _lineFrameView.deviceScale = selectedRatio;
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    alertController.popoverPresentationController.barButtonItem = self.rationBarButon;
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

#pragma mark - Vertical Ruler

-(IBAction)verticalRulerAction:(UIButton*)button
{
    button.selected = !button.selected;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.lineFrameView.hideRuler = !self.lineFrameView.hideRuler;
        [[NSUserDefaults standardUserDefaults] setBool:!self.lineFrameView.hideRuler forKey:@"SideRulerShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

#pragma mark - Free Ruler

-(IBAction)freeRulerAction:(UIButton*)button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        self.freeRulerView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.freeRulerView.alpha = self.freeRulerView.alpha != 1.0?1.0:0.0;
        [[NSUserDefaults standardUserDefaults] setBool:self.freeRulerView.alpha forKey:@"FreeHandRulerShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } completion:^(BOOL finished) {

        if (!button.selected)
        {
            self.freeRulerView.hidden = YES;
        }
    }];
}

#pragma mark - Straighten

-(IBAction)straightenFrameAction:(UIButton*)button
{
    button.selected = !button.selected;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.lineFrameView.hideLine = !self.lineFrameView.hideLine;
        [[NSUserDefaults standardUserDefaults] setBool:!self.lineFrameView.hideLine forKey:@"LineFrameShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

#pragma mark - Gesture Recognizers

-(void)showRGBAtLocation:(CGPoint)location
{
    CGPoint originalLocation = location;
    
    location.x = ceilf(location.x);
    location.y = ceilf(location.y);
    
    if (self.magnifyingGlass.window == nil)
    {
        self.magnifyingGlass.touchPoint = originalLocation;
        self.topColorView.frame = CGRectMake(0, 0, self.navigationControllerSR.view.frame.size.width, 44);
        [self.navigationControllerSR.view insertSubview:self.topColorView aboveSubview:self.navigationControllerSR.bottomToolbar];
        [self.view insertSubview:self.magnifyingGlass aboveSubview:self.lineFrameView];
        [self.magnifyingGlass show];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.topColorView.alpha = 1.0;
        } completion:NULL];
    }
    else
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.magnifyingGlass.touchPoint = originalLocation;
        } completion:NULL];
    }
    
    UIImage *image = self.scrollContainerView.image;
    
    UIColor *color = [image colorAtPoint:location];
    
    NSInteger red = [color red]*255.0;
    NSInteger green = [color green]*255.0;
    NSInteger blue = [color blue]*255.0;
    
    self.magnifyingGlass.color = color;
    
    self.labelRed.text      = [NSString localizedStringWithFormat:@"%ld",(long)red];
    self.labelGreen.text    = [NSString localizedStringWithFormat:@"%ld",(long)green];
    self.labelBlue.text     = [NSString localizedStringWithFormat:@"%ld",(long)blue];
    
    if (location.x <= 0 || location.y <= 0 || location.x > image.size.width || location.y > image.size.height)
    {
        self.labelColorLocation.text = NSLocalizedString(@"X: NA, Y: NA", nil);
    }
    else
    {
        self.labelColorLocation.text = [NSString localizedStringWithFormat:@"X: %.0f, Y: %.0f",location.x,location.y];
    }
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        if (color)
        {
            self.topColorView.backgroundColor = color;
        }
        else
        {
            self.topColorView.backgroundColor = [UIColor originalThemeColor];
        }
        
        if ([color isDarkColor])
        {
            self.labelRed.textColor             = [UIColor blackColor];
            self.labelGreen.textColor           = [UIColor blackColor];
            self.labelBlue.textColor            = [UIColor blackColor];
            self.labelColorLocation.textColor   = [UIColor blackColor];
            self.viewColorLabelContainer.backgroundColor =  [UIColor colorWithWhite:1 alpha:0.9];
        }
        else
        {
            self.labelRed.textColor             = [UIColor whiteColor];
            self.labelGreen.textColor           = [UIColor whiteColor];
            self.labelBlue.textColor            = [UIColor whiteColor];
            self.labelColorLocation.textColor   = [UIColor whiteColor];
            self.viewColorLabelContainer.backgroundColor =  [UIColor colorWithWhite:0 alpha:0.7];
        }
        
    } completion:NULL];
}

-(void)hideRGB
{
    if (self.magnifyingGlass.window)
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.topColorView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_topColorView removeFromSuperview];
        }];
        [self.magnifyingGlass hide];
    }
}

-(void)longPressRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint location = [recognizer locationInView:self.scrollContainerView.imageView];
        
        [self showRGBAtLocation:location];
    }
    else
    {
        [self hideRGB];
    }
}

#pragma mark - ScrollView Delegates

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollContainerView.scrollView)
    {
        if (_freeRulerView.hidden == NO && _freeRulerView.alpha != 0.0)
        {
            _freeRulerView.zoomScale = scrollView.zoomScale;
        }
        
        if (_lineFrameView.hidden == NO && _lineFrameView.alpha != 0.0)
        {
            BOOL animated = !(scrollView.tracking || scrollView.decelerating);
            [_lineFrameView setZoomScale:scrollView.zoomScale animated:animated];
        }
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scrollView == self.scrollContainerView.scrollView)
    {
        _freeRulerView.zoomScale = scrollView.zoomScale;
        _lineFrameView.zoomScale = scrollView.zoomScale;
    }
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollContainerView.scrollView)
    {
        if (_freeRulerView.hidden == NO && _freeRulerView.alpha != 0.0)
        {
            _freeRulerView.zoomScale = scrollView.zoomScale;
        }
        
        if (_lineFrameView.hidden == NO && _lineFrameView.alpha != 0.0)
        {
            BOOL animated = !(scrollView.tracking || scrollView.decelerating);

            [_lineFrameView setZoomScale:scrollView.zoomScale animated:animated];
        }
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SREditOptionViewController class]])
    {
        SREditOptionViewController *controller = (SREditOptionViewController*)segue.destinationViewController;
        controller.delegate = self;
        controller.image = self.scrollContainerView.image;
        controller.zoomScale = self.scrollContainerView.zoomScale;
        controller.contentOffset = self.scrollContainerView.contentOffset;
    }
}

-(void)controller:(UIViewController*)controller finishWithImage:(UIImage*)image zoomScale:(CGFloat)zoomScale contentOffset:(CGPoint)contentOffset
{
    self.scrollContainerView.image = image;
    self.scrollContainerView.zoomScale = zoomScale;
    self.scrollContainerView.contentOffset = contentOffset;
}

#pragma mark - Orientation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGAffineTransform transform = _freeRulerView.transform;
    [UIView animateWithDuration:0.25 animations:^{
        _freeRulerView.transform = CGAffineTransformIdentity;
    }];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        _freeRulerView.transform = transform;
        
        [_lineFrameView updateUIAnimated:YES];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        [_lineFrameView updateUIAnimated:YES];
    }];
}

- (BOOL)shouldAutorotate
{
    return isLockedOrientation == NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (isLockedOrientation)
    {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            return UIInterfaceOrientationMaskPortrait;
        }
        else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            return UIInterfaceOrientationMaskLandscape;
        }
        else
        {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    else
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.interfaceOrientation;
}

-(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]] == NO)
    {
        return self.presentedViewController.interfaceOrientation;
    }
    else
    {
        return [super interfaceOrientation];
    }
}

@end
