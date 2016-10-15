//
//  SREditOptionViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SREditOptionViewController.h"
#import "IQScrollContainerView.h"
#import "IQ_UIImage+Resizing.h"
#import "SRCropViewController.h"
#import "SRDrawViewController.h"
#import "SRNavigationController.h"
#import "UIColor+ThemeColor.h"
#import <Crashlytics/Answers.h>

@interface SREditOptionViewController ()<SRImageControllerDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet IQScrollContainerView *scrollContainerView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *drawBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cropBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *resizeBarButtonItem;

@end

@implementation SREditOptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.image = self.image;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollContainerView.zoomScale = self.zoomScale;
    self.scrollContainerView.contentOffset = self.contentOffset;

    UIColor *backgroundColor = [UIColor themeBackgroundColor];
    
    self.view.backgroundColor = backgroundColor;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    self.scrollContainerView.image = self.image;
}

-(IBAction)cancelAction:(UIBarButtonItem*)item
{
    if ([self.delegate respondsToSelector:@selector(controller:finishWithImage:zoomScale:contentOffset:)]) {
        [self.delegate controller:self finishWithImage:self.scrollContainerView.image zoomScale:self.scrollContainerView.zoomScale contentOffset:self.scrollContainerView.contentOffset];
    }

    [self.navigationControllerSR popViewControllerAnimated:YES];
}

-(IBAction)resizeAction:(UIBarButtonItem*)item
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"resize", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    CGSize imageSize = self.scrollContainerView.image.size;
    
    BOOL hasMoreOptions = NO;
    
    __weak typeof(self) weakSelf = self;

    if (fmodf(imageSize.width,[[UIScreen mainScreen] bounds].size.width) == 0 &&
        fmodf(imageSize.height,[[UIScreen mainScreen] bounds].size.height) == 0)
    {
        hasMoreOptions = YES;
        
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%.0fx%.0f",[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            CGSize newSize = [[UIScreen mainScreen] bounds].size;
            
            [Answers logCustomEventWithName:@"resize" customAttributes:@{@"size":NSStringFromCGSize(newSize)}];

            UIImage *image = [weakSelf.scrollContainerView.image IQ_scaleToFillSize:newSize];
            weakSelf.image = image;
        }]];
    }
    
    if (fmodf(imageSize.height,[[UIScreen mainScreen] bounds].size.width) == 0 &&
        fmodf(imageSize.width,[[UIScreen mainScreen] bounds].size.height) == 0)
    {
        hasMoreOptions = YES;

        [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%.0fx%.0f",[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            CGSize newSize = CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
            
            [Answers logCustomEventWithName:@"Resize" customAttributes:@{@"size":NSStringFromCGSize(newSize)}];
            
            UIImage *image = [weakSelf.scrollContainerView.image IQ_scaleToFillSize:newSize];
            weakSelf.image = image;
        }]];
    }
    
    if (hasMoreOptions)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"custom", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf showCustomResizeAlertFromItem:item];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];

        alertController.popoverPresentationController.barButtonItem = item;
        [weakSelf presentViewController:alertController animated:YES completion:^{
        }];
    }
    else
    {
        [self showCustomResizeAlertFromItem:item];
    }
}

-(void)showCustomResizeAlertFromItem:(UIBarButtonItem*)item
{
    CGSize imageSize = self.scrollContainerView.image.size;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"resize_screenshot", nil) message:NSLocalizedString(@"enter_width_and_height", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(UIAlertController) *weakAlertController = alertController;
    
    __weak typeof(self) weakSelf = self;

    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *widthTextField = nil;
        UITextField *heightTextField = nil;
        
        for (UITextField *textField in alertController.textFields)
        {
            if (textField.tag == 1)
            {
                widthTextField = textField;
            }
            else
            {
                heightTextField = textField;
            }
        }
        
        NSInteger width = [widthTextField.text integerValue];
        NSInteger height = [heightTextField.text integerValue];
        
        CGSize newSize = CGSizeMake(width, height);
        
        [Answers logCustomEventWithName:@"Resize" customAttributes:@{@"size":NSStringFromCGSize(newSize)}];

        UIImage *image = [weakSelf.scrollContainerView.image IQ_scaleToFillSize:newSize];
        weakSelf.image = image;
    }];
    doneAction.enabled = NO;
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.tag = 1;
        textField.placeholder = NSLocalizedString(@"width", nil);
        textField.text = [NSString stringWithFormat:@"%.0f",imageSize.width];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            UITextField *heightTextField = nil;
            
            for (UITextField *loopTextField in weakAlertController.textFields)
            {
                if (textField != loopTextField)
                {
                    heightTextField = loopTextField;
                }
            }
            
            if ([textField.text length] == 0)
            {
                heightTextField.text = @"";
            }
            else
            {
                heightTextField.text = [NSString stringWithFormat:@"%.0f",[textField.text integerValue] * (imageSize.height/imageSize.width)];
            }
            
            if ([textField.text integerValue] == 0 ||
                [heightTextField.text integerValue] == 0 ||
                [textField.text integerValue] > 10000 ||
                [heightTextField.text integerValue] > 10000)
            {
                doneAction.enabled = NO;
            }
            else
            {
                doneAction.enabled = YES;
            }
        }];
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.tag = 2;
        textField.placeholder = NSLocalizedString(@"height", nil);
        textField.text = [NSString stringWithFormat:@"%.0f",imageSize.height];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            UITextField *widthTextField = nil;
            
            for (UITextField *loopTextField in weakAlertController.textFields)
            {
                if (textField != loopTextField)
                {
                    widthTextField = loopTextField;
                }
            }
            
            if ([textField.text length] == 0)
            {
                widthTextField.text = @"";
            }
            else
            {
                widthTextField.text = [NSString stringWithFormat:@"%.0f",[textField.text integerValue] * (imageSize.width/imageSize.height)];
            }
            
            if ([textField.text integerValue] == 0 ||
                [widthTextField.text integerValue] == 0 ||
                [textField.text integerValue] > 10000 ||
                [widthTextField.text integerValue] > 10000)
            {
                doneAction.enabled = NO;
            }
            else
            {
                doneAction.enabled = YES;
            }
        }];
    }];
    
    [alertController addAction:doneAction];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    alertController.popoverPresentationController.barButtonItem = item;
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SRCropViewController class]])
    {
        SRCropViewController *controller = (SRCropViewController*)segue.destinationViewController;
        controller.delegate = self;
        controller.image = self.scrollContainerView.image;
        controller.zoomScale = self.scrollContainerView.zoomScale;
        controller.contentOffset = self.scrollContainerView.contentOffset;
    }
    else if ([segue.destinationViewController isKindOfClass:[SRDrawViewController class]])
    {
        SRDrawViewController *controller = (SRDrawViewController*)segue.destinationViewController;
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

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

@end
