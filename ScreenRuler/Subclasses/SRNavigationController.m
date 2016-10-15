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

-(NSArray<UIBarButtonItem *> *)topToolbarItems
{
    UIBarButtonItem *flexibleBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    NSMutableArray *topToolbarItems = [[NSMutableArray alloc] init];
    NSMutableArray *allToolbarItems = [[NSMutableArray alloc] initWithArray:self.navigationItem.leftBarButtonItems];
    [allToolbarItems addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    
    if (allToolbarItems.count == 1)
    {
        topToolbarItems = [@[flexibleBarButton,allToolbarItems[0],flexibleBarButton] mutableCopy];
    }
    else if (allToolbarItems.count > 1)
    {
        UIBarButtonItem *firstItem = allToolbarItems[0];
        [allToolbarItems removeObject:firstItem];
        [topToolbarItems addObject:firstItem];

        for (UIBarButtonItem *item in allToolbarItems)
        {
            [topToolbarItems addObject:flexibleBarButton];
            [topToolbarItems addObject:item];
        }
    }
    
    return topToolbarItems;
}

-(NSArray<UIBarButtonItem *> *)bottomToolbarItems
{
    return self.toolbarItems;
}

-(SRNavigationController *)navigationControllerSR
{
    return objc_getAssociatedObject(self, @selector(navigationControllerSR));
}

-(void)setNavigationControllerSR:(SRNavigationController * _Nullable)navigationControllerSR
{
    objc_setAssociatedObject(self, @selector(navigationControllerSR), navigationControllerSR, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end



@interface SRNavigationController ()<UIToolbarDelegate>

@property(nonatomic, strong) SRContainerView *containerView;

@property(nonatomic,readwrite,nonnull) SRToolbar *topToolbar; // The navigation bar managed by the controller. Pushing, popping or setting navigation items on a managed navigation bar is not supported.

@property(null_resettable,nonatomic,readwrite) SRToolbar *bottomToolbar NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED; // For use when presenting an action sheet.

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

-(SRToolbar *)topToolbar
{
    if (_topToolbar == nil)
    {
        _topToolbar = [[SRToolbar alloc] init];
        _topToolbar.delegate = self;
        _topToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_topToolbar];

        //Portrait
        {
            //navigation bar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:22];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];

                _navigationPortraitConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }
        
        //landscape right
        {
            //navigation bar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:22];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

                _navigationLandscapeRightConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }
        
        //landscape left
        {
            //navigation bar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-22];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

                _navigationLandscapeLeftConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
       }
        
        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:_topToolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];

        [self.view addConstraint:constraintHeight];
        [self.view addConstraints:_navigationPortraitConstraints];
    }
    
    return _topToolbar;
}

-(SRToolbar *)bottomToolbar
{
    if (_bottomToolbar == nil)
    {
        _bottomToolbar = [[SRToolbar alloc] init];
        _bottomToolbar.delegate = self;
        _bottomToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_bottomToolbar];

        //Portrait
        {
            //toolbar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-22];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];

                _toolbarPortraitConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }
        
        //landscape right
        {
            //toolbar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-22];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

                _toolbarLandscapeRightConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }
        
        //landscape left
        {
            //toolbar
            {
                NSLayoutConstraint *constraintXCenter = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:22];
                NSLayoutConstraint *constraintYCenter = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

                _toolbarLandscapeLeftConstraints = @[constraintXCenter,constraintYCenter,constraintWidth];
            }
        }

        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:_bottomToolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
        
        [self.view addConstraint:constraintHeight];

        [self.view addConstraints:_toolbarPortraitConstraints];
    }
    
    return _bottomToolbar;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChanged:) name:kRAThemeChangedNotification object:nil];
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
    [self.topToolbar setItems:viewController.topToolbarItems animated:animated];
    [self.bottomToolbar setItems:viewController.bottomToolbarItems animated:animated];
    
    viewController.navigationControllerSR = self;
    viewController.view.frame = self.containerView.bounds;
    [viewController willMoveToParentViewController:self];
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
        [topController removeFromParentViewController];
        [topController.view removeFromSuperview];
        [topController didMoveToParentViewController:nil];
    }];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *topController = [self topViewController];
    UIViewController *previousController = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
    
    [self.topToolbar setItems:previousController.topToolbarItems animated:animated];
    [self.bottomToolbar setItems:previousController.bottomToolbarItems animated:animated];
    
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
    if (bar == self.topToolbar)
    {
        return UIToolbarPositionTop;
    }
    else if (bar == self.bottomToolbar)
    {
        return UIToolbarPositionBottom;
    }
    else
    {
        return UIToolbarPositionAny;
    }
}

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
                    weakSelf.topToolbar.transform = CGAffineTransformMakeRotation(M_PI_2);
                    weakSelf.bottomToolbar.transform = CGAffineTransformMakeRotation(M_PI_2);
                }
                    break;
                case UIInterfaceOrientationLandscapeRight:
                {
                    CGRect rect = CGRectInset(weakSelf.view.bounds, 44, 0);
                    weakSelf.containerView.frame = rect;

                    [weakSelf.view addConstraints:weakSelf.navigationLandscapeRightConstraints];
                    [weakSelf.view addConstraints:weakSelf.toolbarLandscapeRightConstraints];
                    weakSelf.topToolbar.transform = CGAffineTransformMakeRotation(-M_PI_2);
                    weakSelf.bottomToolbar.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }
                    break;
                default:
                {
                    CGRect rect = CGRectInset(weakSelf.view.bounds, 0, 44);
                    weakSelf.containerView.frame = rect;

                    [weakSelf.view addConstraints:weakSelf.navigationPortraitConstraints];
                    [weakSelf.view addConstraints:weakSelf.toolbarPortraitConstraints];
                    weakSelf.topToolbar.transform = CGAffineTransformIdentity;
                    weakSelf.bottomToolbar.transform = CGAffineTransformIdentity;
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

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:animated?0.3:0 animations:^{
        
        UIColor *themeColor = [UIColor themeColor];
        UIColor *textColor = [UIColor themeTextColor];
        UIColor *backgroundColor = [UIColor themeBackgroundColor];

        weakSelf.view.backgroundColor = backgroundColor;
        weakSelf.topToolbar.barTintColor = weakSelf.bottomToolbar.barTintColor = themeColor;
        weakSelf.topToolbar.tintColor = weakSelf.bottomToolbar.tintColor = textColor;
        weakSelf.topToolbar.barStyle = weakSelf.bottomToolbar.barStyle = ![UIColor isThemeInverted];
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
    return (self.topToolbar.barStyle == UIBarStyleDefault)?UIStatusBarStyleDefault:UIStatusBarStyleLightContent;
}

-(void)themeDidChanged:(NSNotification*)notification
{
    UIColor *themeColor = [UIColor themeColor];
    UIColor *textColor = [UIColor themeTextColor];
    UIColor *backgroundColor = [UIColor themeBackgroundColor];

    self.view.backgroundColor = backgroundColor;
    self.topToolbar.barTintColor = self.bottomToolbar.barTintColor = themeColor;
    self.topToolbar.tintColor = self.bottomToolbar.tintColor = textColor;
    self.topToolbar.barStyle = self.bottomToolbar.barStyle = ![UIColor isThemeInverted];
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
