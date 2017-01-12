//
//  SRNavigationController.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@interface SRNavigationController : UIViewController

- (void)pushViewController:( UIViewController * _Nonnull )viewController animated:(BOOL)animated; // Uses a horizontal slide transition. Has no effect if the view controller is already in the stack.
- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated; // Returns the popped controller.

@property(nonatomic,copy, nonnull) NSArray<__kindof  UIViewController *  > *viewControllers; // The current view controller stack.

- (void)setViewControllers:(NSArray<UIViewController *> * _Nonnull )viewControllers animated:(BOOL)animated NS_AVAILABLE_IOS(3_0); // If animated is YES, then simulate a push or pop depending on whether the new top view controller was previously in the stack.

@property(nullable, nonatomic,readonly,strong) UIViewController *topViewController; // The top view controller on the stack.

//@property(nonatomic,getter=isNavigationBarHidden) BOOL navigationBarHidden;
//- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated; // Hide or show the navigation bar. If animated, it will transition vertically using UINavigationControllerHideShowBarDuration.
@property(nonatomic,readonly,nonnull) UINavigationBar *navigationBar; // The navigation bar managed by the controller. Pushing, popping or setting navigation items on a managed navigation bar is not supported.

//@property(nonatomic,getter=isToolbarHidden) BOOL toolbarHidden NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED; // Defaults to YES, i.e. hidden.
//- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED; // Hide or show the toolbar at the bottom of the screen. If animated, it will transition vertically using UINavigationControllerHideShowBarDuration.
@property(null_resettable,nonatomic,readonly) UIToolbar *toolbar NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED; // For use when presenting an action sheet.


@end


//- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated; // Pops view controllers until the one specified is on top. Returns the popped controllers.
//- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated; // Pops until there's only a single view controller left on the stack. Returns the popped controllers.

//@property(nullable, nonatomic,readonly,strong) UIViewController *visibleViewController; // Return modal view controller if it exists. Otherwise the top view controller.

@interface UIViewController (SRNavigationControllerItem)

@property(nullable, nonatomic,readonly,strong) SRNavigationController *navigationControllerSR; // If this view controller has been pushed onto a navigation controller, return it.

@end
