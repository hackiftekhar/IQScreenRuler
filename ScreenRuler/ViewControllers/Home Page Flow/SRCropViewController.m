//
//  SRCropViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRCropViewController.h"
#import "IQCropperView.h"
#import "UIImage+CropRotate.h"
#import "IQScrollContainerView.h"
#import "SRNavigationController.h"
#import "UIColor+ThemeColor.h"
#import <Crashlytics/Answers.h>


@interface SRCropViewController ()<IQCropViewDelegate>

@property (strong, nonatomic) IBOutlet IQCropperView *cropView;
@property (strong, nonatomic) IBOutlet UILabel *cropInfoLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonCrop;

@property (strong, nonatomic) IBOutlet IQScrollContainerView *scrollContainerView;

@end

@implementation SRCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.image = self.image;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.barButtonCrop.title = NSLocalizedString(@"Crop", nil);

    self.scrollContainerView.zoomScale = self.zoomScale;
    self.scrollContainerView.contentOffset = self.contentOffset;

    UIColor *textColor = [UIColor themeTextColor];
    UIColor *backgroundColor = [UIColor themeBackgroundColor];
    
    self.view.backgroundColor = backgroundColor;
    self.cropInfoLabel.textColor = textColor;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.scrollContainerView.image)
    {
        CGSize minimumSize = self.scrollContainerView.scrollView.minimumSize;
        CGRect cropViewBounds = self.cropView.bounds;
        
        CGFloat widthDiff = cropViewBounds.size.width-minimumSize.width;
        CGFloat heightDiff = cropViewBounds.size.height-minimumSize.height;
        
        _cropView.edgeInset = UIEdgeInsetsMake(heightDiff/2, widthDiff/2, heightDiff/2, widthDiff/2);
        _cropView.cropRect = cropViewBounds;
        [_cropView updateCropRectAnimated:NO];
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
    _image = image;

    self.scrollContainerView.image = image;

    {
        CGSize minimumSize = self.scrollContainerView.scrollView.minimumSize;
        CGRect cropViewBounds = self.cropView.bounds;
        
        CGFloat widthDiff = cropViewBounds.size.width-minimumSize.width;
        CGFloat heightDiff = cropViewBounds.size.height-minimumSize.height;
        
        _cropView.edgeInset = UIEdgeInsetsMake(heightDiff/2, widthDiff/2, heightDiff/2, widthDiff/2);
        _cropView.cropRect = cropViewBounds;
    }
}

-(IBAction)aspectRatioAction:(UIBarButtonItem*)item
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Aspect Ratio", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Original", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSizeOriginal;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"original"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Square", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSizeSquare;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"square"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",2,3] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize2x3;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"2x3"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",3,4] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize3x4;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"3x4"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",4,5] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize4x5;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"4x5"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",5,7] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize5x7;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"5x7"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",9,16] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize9x16;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"9x16"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",3,2] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize3x2;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"3x2"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",4,3] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize4x3;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"4x3"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",5,4] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize5x4;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"5x4"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",7,5] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize7x5;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"7x5"}];
    }]];
    
    [NSLocale currentLocale];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%d:%d",16,9] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.cropView.aspectSize = IQ_IQAspectSize16x9;
        
        [Answers logCustomEventWithName:@"Aspect Ratio" customAttributes:@{@"Ratio":@"16x9"}];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    alertController.popoverPresentationController.barButtonItem = item;
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCropInfo];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self updateCropInfo];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateCropInfo];
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
    [Answers logCustomEventWithName:@"Crop Done" customAttributes:nil];

    CGRect respectiveRect = [self.cropView convertRect:self.cropView.cropRect toView:self.scrollContainerView.imageView];
    UIImage *image = [self.scrollContainerView.image croppedImageWithFrame:respectiveRect angle:0];
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.cropView.alpha = 0.0;
        weakSelf.image = image;
    } completion:^(BOOL finished) {
        
        if ([weakSelf.delegate respondsToSelector:@selector(controller:finishWithImage:zoomScale:contentOffset:)]) {
            [weakSelf.delegate controller:weakSelf finishWithImage:weakSelf.scrollContainerView.image zoomScale:weakSelf.scrollContainerView.zoomScale contentOffset:weakSelf.scrollContainerView.contentOffset];
        }

        [weakSelf.navigationControllerSR popViewControllerAnimated:YES];
    }];
}


-(void)cropViewDidChangedCropRect:(IQCropperView *)view
{
    [self updateCropInfo];
}

-(void)updateCropInfo
{
    CGRect respectiveRect = [self.cropView convertRect:self.cropView.cropRect toView:self.scrollContainerView.imageView];
    self.cropInfoLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"x_y_width_height", nil),respectiveRect.origin.x,respectiveRect.origin.y,respectiveRect.size.width,respectiveRect.size.height];
}


-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak typeof(self) weakSelf = self;

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        {
            CGSize minimumSize = weakSelf.scrollContainerView.scrollView.minimumSize;
            CGRect cropViewBounds = weakSelf.cropView.bounds;
            
            CGFloat widthDiff = cropViewBounds.size.width-minimumSize.width;
            CGFloat heightDiff = cropViewBounds.size.height-minimumSize.height;
            
            weakSelf.cropView.edgeInset = UIEdgeInsetsMake(heightDiff/2, widthDiff/2, heightDiff/2, widthDiff/2);
            weakSelf.cropView.cropRect = weakSelf.cropView.bounds;
            [weakSelf.cropView updateCropRectAnimated:YES];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

@end
