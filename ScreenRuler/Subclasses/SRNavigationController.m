//
//  SRNavigationController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRNavigationController.h"
#import <objc/runtime.h>
#import "UIColor+ThemeColor.h"
#import "SRToolbar.h"
#import "SRNavigationBar.h"

@interface SRNavigationView : UIView
@end

@implementation SRNavigationView

@end

/************************************************/

@interface SRContainerView : UIView
@end

@implementation SRContainerView

@end

/************************************************/

@interface SRPushSegue : UIStoryboardSegue

@end

@implementation SRPushSegue

-(void)perform
{
    SRNavigationController *navController = (SRNavigationController*)[self sourceViewController];
    
    if ([navController isKindOfClass:[SRNavigationController class]] == NO)
    {
        navController = navController.navigationControllerSR;
    }
    
    UIViewController *destinationViewController = [self destinationViewController];
    [navController pushViewController:destinationViewController animated:YES];
}

@end

/************************************************/

@implementation UIViewController (SRNavigationControllerItem)

-(SRNavigationController *)navigationControllerSR
{
    return objc_getAssociatedObject(self, @selector(navigationControllerSR));
}

-(void)setNavigationControllerSR:(SRNavigationController * _Nullable)navigationControllerSR
{
    objc_setAssociatedObject(self, @selector(navigationControllerSR), navigationControllerSR, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end



@interface SRNavigationController ()<UIToolbarDelegate,UINavigationBarDelegate>

@property(nonatomic, strong) SRContainerView *containerView;

@property BOOL isPopping;
@property(nonatomic,readwrite,nonnull) UINavigationBar *navigationBar; // The navigation bar managed by the controller. Pushing, popping or setting navigation items on a managed navigation bar is not supported.

@property(null_resettable,nonatomic,readwrite) UIToolbar *toolbar NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED; // For use when presenting an action sheet.

@property(nonatomic, strong) NSArray *navigationPortraitConstraints;
@property(nonatomic, strong) NSArray *navigationLandscapeLeftConstraints;
@property(nonatomic, strong) NSArray *navigationLandscapeRightConstraints;

@property(nonatomic, strong) NSArray *toolbarPortraitConstraints;
@property(nonatomic, strong) NSArray *toolbarLandscapeLeftConstraints;
@property(nonatomic, strong) NSArray *toolbarLandscapeRightConstraints;

@end

@implementation SRNavigationController

-(void)loadView
{
    self.view = [[SRNavigationView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(SRContainerView *)containerView
{
    if (_containerView == nil)
    {
        CGRect rect = CGRectInset(self.view.bounds, 0, 44);
        _containerView = [[SRContainerView alloc] initWithFrame:rect];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_containerView atIndex:0];
    }
    
    return _containerView;
}

-(UINavigationBar *)navigationBar
{
    if (_navigationBar == nil)
    {
        _navigationBar = [[SRNavigationBar alloc] init];
        _navigationBar.delegate = self;
        _navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_navigationBar];

        //Portrait
        {
            //navigation bar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:22];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];

                _navigationPortraitConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }
        
        //landscape right
        {
            //navigation bar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:22];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

                _navigationLandscapeRightConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }
        
        //landscape left
        {
            //navigation bar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-22];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

                _navigationLandscapeLeftConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
       }
        
        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];

        [self.view addConstraint:constraintHeight];
        [self.view addConstraints:_navigationPortraitConstraints];
    }
    
    return _navigationBar;
}

-(UIToolbar *)toolbar
{
    if (_toolbar == nil)
    {
        _toolbar = [[SRToolbar alloc] init];
        _toolbar.delegate = self;
        _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_toolbar];

        //Portrait
        {
            //toolbar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-22];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];

                _toolbarPortraitConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }
        
        //landscape right
        {
            //toolbar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-22];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

                _toolbarLandscapeRightConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }
        
        //landscape left
        {
            //toolbar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:22];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

                _toolbarLandscapeLeftConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }

        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
        
        [self.view addConstraint:constraintHeight];

        [self.view addConstraints:_toolbarPortraitConstraints];
    }
    
    return _toolbar;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kRASettingsChangedNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _viewControllers = [[NSArray alloc] init];
    
    self.definesPresentationContext = YES;
    self.providesPresentationContextTransitionStyle = YES;

    [self performSegueWithIdentifier:@"SRPushSegue" sender:self];
}

-(UIViewController *)topViewController
{
    return [_viewControllers lastObject];
}

-(void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

-(void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
    _viewControllers = viewControllers;
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.navigationBar pushNavigationItem:viewController.navigationItem animated:animated];
    [self.toolbar setItems:viewController.toolbarItems animated:animated];
    
    viewController.navigationControllerSR = self;
    viewController.view.frame = self.containerView.bounds;
    [self addChildViewController:viewController];
    [viewController.view setNeedsLayout];
    [viewController.view layoutIfNeeded];
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    UIViewController *topController = [self topViewController];
    
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    [viewControllers addObject:viewController];
    _viewControllers = viewControllers;

    viewController.view.alpha = 0.0;
    [UIView animateWithDuration:animated?0.3:0 animations:^{
        viewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
        [topController willMoveToParentViewController:nil];
        [topController.view removeFromSuperview];
        [topController removeFromParentViewController];
    }];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *topController = [self topViewController];
    UIViewController *previousController = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
    
    _isPopping = YES;
    [self.navigationBar popNavigationItemAnimated:animated];
    _isPopping = NO;
    
    [self.toolbar setItems:previousController.toolbarItems animated:animated];
    
    previousController.view.frame = self.containerView.bounds;
    
    [previousController willMoveToParentViewController:self];
    [self addChildViewController:previousController];
    [self.containerView insertSubview:previousController.view belowSubview:topController.view];
    [previousController didMoveToParentViewController:self];
    
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    [viewControllers removeLastObject];
    _viewControllers = viewControllers;
    
    [topController willMoveToParentViewController:nil];
    [UIView animateWithDuration:animated?0.3:0 animations:^{
        topController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        topController.navigationControllerSR = nil;
        [topController removeFromParentViewController];
        [topController.view removeFromSuperview];
        [topController didMoveToParentViewController:nil];
    }];
    
    return topController;
}


//-(BOOL)isNavigationBarHidden
//{
//    return self.navigationBar.isHidden;
//}
//
//-(void)setNavigationBarHidden:(BOOL)navigationBarHidden
//{
//    [self setNavigationBarHidden:navigationBarHidden animated:NO];
//}
//
//-(void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
//{
//    [UIView animateWithDuration:animated?0.3:0 animations:^{
//        self.navigationBar.alpha = hidden?0.0:1.0;
//    } completion:^(BOOL finished) {
//        self.navigationBar.hidden = hidden;
//    }];
//}

//-(BOOL)isToolbarHidden
//{
//    return self.toolbar.isHidden;
//}
//
//-(void)setToolbarHidden:(BOOL)toolbarHidden
//{
//    [self setToolbarHidden:toolbarHidden animated:NO];
//}
//
//-(void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
//{
//    [UIView animateWithDuration:animated?0.3:0 animations:^{
//        self.toolbar.alpha = hidden?0.0:1.0;
//    } completion:^(BOOL finished) {
//        self.toolbar.hidden = hidden;
//    }];
//}

#pragma mark - Navigation Bar Delegates

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    if (bar == self.toolbar)
    {
        return UIToolbarPositionBottom;
    }
    else if (bar == self.navigationBar)
    {
        return UIBarPositionTop;
    }
    else
    {
        return UIToolbarPositionAny;
    }
}

#pragma mark - UINavigationBar Delegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if (self.isPopping)
    {
        return YES;
    }
    else
    {
        [self popViewControllerAnimated:YES];
        return NO;
    }
}

//- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
//{
//    [self popViewControllerAnimated:YES];
//}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    __weak typeof(self) weakSelf = self;

//    self.topToolbar.alpha = 0.0;
//    self.bottomToolbar.alpha = 0.0;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

//        self.topToolbar.alpha = 1.0;
//        self.bottomToolbar.alpha = 1.0;

        {
            [weakSelf.view removeConstraints:weakSelf.navigationPortraitConstraints];
            [weakSelf.view removeConstraints:weakSelf.navigationLandscapeLeftConstraints];
            [weakSelf.view removeConstraints:weakSelf.navigationLandscapeRightConstraints];
            [weakSelf.view removeConstraints:weakSelf.toolbarPortraitConstraints];
            [weakSelf.view removeConstraints:weakSelf.toolbarLandscapeLeftConstraints];
            [weakSelf.view removeConstraints:weakSelf.toolbarLandscapeRightConstraints];
            
            switch (weakSelf.interfaceOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:
                {
                    CGRect rect = CGRectInset(weakSelf.view.bounds, 44, 0);
                    weakSelf.containerView.frame = rect;

                    [weakSelf.view addConstraints:weakSelf.navigationLandscapeLeftConstraints];
                    [weakSelf.view addConstraints:weakSelf.toolbarLandscapeLeftConstraints];
                    weakSelf.navigationBar.transform = CGAffineTransformMakeRotation(M_PI_2);
                    weakSelf.toolbar.transform = CGAffineTransformMakeRotation(M_PI_2);
                }
                    break;
                case UIInterfaceOrientationLandscapeRight:
                {
                    CGRect rect = CGRectInset(weakSelf.view.bounds, 44, 0);
                    weakSelf.containerView.frame = rect;

                    [weakSelf.view addConstraints:weakSelf.navigationLandscapeRightConstraints];
                    [weakSelf.view addConstraints:weakSelf.toolbarLandscapeRightConstraints];
                    weakSelf.navigationBar.transform = CGAffineTransformMakeRotation(-M_PI_2);
                    weakSelf.toolbar.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }
                    break;
                default:
                {
                    CGRect rect = CGRectInset(weakSelf.view.bounds, 0, 44);
                    weakSelf.containerView.frame = rect;

                    [weakSelf.view addConstraints:weakSelf.navigationPortraitConstraints];
                    [weakSelf.view addConstraints:weakSelf.toolbarPortraitConstraints];
                    weakSelf.navigationBar.transform = CGAffineTransformIdentity;
                    weakSelf.toolbar.transform = CGAffineTransformIdentity;
                }
                    break;
            }
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateTheme];
}

-(void)updateTheme
{
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        UIColor *themeColor = [UIColor themeColor];
        UIColor *textColor = [UIColor themeTextColor];
        UIColor *backgroundColor = [UIColor themeBackgroundColor];

        weakSelf.view.backgroundColor = backgroundColor;
        weakSelf.navigationBar.barTintColor = weakSelf.toolbar.barTintColor = themeColor;
        weakSelf.navigationBar.tintColor = weakSelf.toolbar.tintColor = textColor;
        weakSelf.navigationBar.barStyle = weakSelf.toolbar.barStyle = ![UIColor isThemeInverted];
    }];
}

-(BOOL)prefersStatusBarHidden
{
    return self.topViewController.prefersStatusBarHidden;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.topViewController.preferredStatusBarUpdateAnimation;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return (self.navigationBar.barStyle == UIBarStyleDefault)?UIStatusBarStyleDefault:UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
