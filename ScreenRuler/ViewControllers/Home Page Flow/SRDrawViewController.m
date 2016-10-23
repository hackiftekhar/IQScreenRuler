//
//  SRDrawViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRDrawViewController.h"
#import "IQScrollContainerView.h"
#import "IQColorPickerButton.h"
#import "IQTextPickerButton.h"
#import "SRNavigationController.h"
#import "IQ_SmoothedBIView.h"
#import "UIColor+ThemeColor.h"
#import "UIImage+Color.h"
#import <Crashlytics/Answers.h>
#import "UIImage+FloodFill.h"


@interface SRDrawViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet IQScrollContainerView *scrollContainerView;

@property (strong, nonatomic) IBOutlet IQColorPickerButton *colorPickerButton;

@property (strong, nonatomic) IBOutlet IQTextPickerButton *sizePickerButton;

@property(nonatomic, strong) IQ_SmoothedBIView *drawView;

@end

@implementation SRDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *textArray = [[NSMutableArray alloc] init];
    
    NSInteger i = 1;
    while (i <= 100) {
        [textArray addObject:[NSString localizedStringWithFormat:@"%ld",(long)i]];
        i++;
    }
    
    _sizePickerButton.items = textArray;
    _sizePickerButton.selectedItem = [NSString localizedStringWithFormat:@"%d",5];
    _sizePickerButton.layer.cornerRadius = 3.0;
    _sizePickerButton.layer.masksToBounds = YES;

    self.image = self.image;
    
    self.drawView = [[IQ_SmoothedBIView alloc] init];
    [self.scrollContainerView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.drawView.panRecognizer];
    self.drawView.frame = self.scrollContainerView.scrollView.contentView.bounds;
    self.drawView.strokeColor = _colorPickerButton.color;
    self.drawView.strokeWidth = [_sizePickerButton.selectedItem floatValue];
    [self.scrollContainerView.scrollView.contentView addSubview:self.drawView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.scrollContainerView.showZoomControls = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowZoomOption"];

    self.scrollContainerView.zoomScale = self.zoomScale;
    self.scrollContainerView.contentOffset = self.contentOffset;

    UIColor *themeColor = [UIColor themeColor];
    UIColor *textColor = [UIColor themeTextColor];
    UIColor *backgroundColor = [UIColor themeBackgroundColor];
    
    UIImage *image = [[UIImage imageWithColor:textColor] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];

    self.view.backgroundColor = backgroundColor;
    [self.sizePickerButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.sizePickerButton setTitleColor:themeColor forState:UIControlStateNormal];
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
    _image = image;

    self.scrollContainerView.image = image;
}

- (IBAction)colorPickerChanged:(IQColorPickerButton *)sender {
    self.drawView.strokeColor = sender.color;

    [Answers logCustomEventWithName:@"Color Picker Color Changed" customAttributes:nil];
}

- (IBAction)sizePickerChanged:(IQTextPickerButton *)sender {
    self.drawView.strokeWidth = [sender.selectedItem floatValue];

    [Answers logCustomEventWithName:@"Size Picker Size Changed" customAttributes:nil];
}

-(IBAction)cancelAction:(UIBarButtonItem*)item
{
    if ([self.delegate respondsToSelector:@selector(controller:finishWithImage:zoomScale:contentOffset:)]) {
        [self.delegate controller:self finishWithImage:self.scrollContainerView.image zoomScale:self.scrollContainerView.zoomScale contentOffset:self.scrollContainerView.contentOffset];
    }

    [self.navigationControllerSR popViewControllerAnimated:YES];
}

-(IBAction)doneAction:(UIBarButtonItem*)item
{
    [Answers logCustomEventWithName:@"Draw Done" customAttributes:nil];

    UIGraphicsBeginImageContext(self.scrollContainerView.scrollView.image.size);
    [self.scrollContainerView.scrollView.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.image = capturedImage;
        
    } completion:^(BOOL finished) {
        
        if ([weakSelf.delegate respondsToSelector:@selector(controller:finishWithImage:zoomScale:contentOffset:)]) {
            [weakSelf.delegate controller:weakSelf finishWithImage:weakSelf.scrollContainerView.image zoomScale:weakSelf.scrollContainerView.zoomScale contentOffset:weakSelf.scrollContainerView.contentOffset];
        }

        [weakSelf.navigationControllerSR popViewControllerAnimated:YES];
    }];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

@end
