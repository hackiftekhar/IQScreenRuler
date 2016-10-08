//
//  AppDelegate.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "AppDelegate.h"
#import "UIFont+AppFont.h"
#import "UIColor+HexColors.h"
#import "SRNavigationController.h"
#import "SRHomeViewController.h"
#import "COSTouchVisualizerWindow.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()<COSTouchVisualizerWindowDelegate>

@end

@implementation AppDelegate

//#if DEBUG
//// Add this method to your AppDelegate method for touch visualization (Used when creating videos)
//- (COSTouchVisualizerWindow *)window {
//    static COSTouchVisualizerWindow *visWindow = nil;
//    if (!visWindow)
//    {
//        visWindow = [[COSTouchVisualizerWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        visWindow.touchVisualizerWindowDelegate = self;
//    }
//    return visWindow;
//}
//
//- (BOOL)touchVisualizerWindowShouldShowFingertip:(COSTouchVisualizerWindow *)window
//{
//    return YES;
//}
//
//- (BOOL)touchVisualizerWindowShouldAlwaysShowFingertip:(COSTouchVisualizerWindow *)window
//{
//    return YES;
//}
//
//#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont kohinoorBanglaSemiboldWithSize:16.0]} forState:UIControlStateNormal];
    
    UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
    
    [Fabric with:@[[Crashlytics class]]];

    if(shortcutItem){
        [self handleShortCutItem:shortcutItem completionHandler:^(BOOL success) {

        }];
        
        return NO;
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Quick Action Menu
- (void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler{
    
    if(shortcutItem)
    {
        [self handleShortCutItem:shortcutItem completionHandler:completionHandler];
    }
    else if (completionHandler)
    {
        completionHandler(NO);
    }

}

- (void)handleShortCutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler {
    
    SRNavigationController* navController = (SRNavigationController*)self.window.rootViewController;
    
    if([navController isKindOfClass:[SRNavigationController class]])
    {
        [navController dismissViewControllerAnimated:NO completion:nil];
        
        SRHomeViewController *homeController = [navController.viewControllers firstObject];
        
        if ([homeController isKindOfClass:[SRHomeViewController class]])
        {
            if([shortcutItem.type isEqualToString:@"com.infoenum.ruler.openlatestscreenshot"])
            {
                [homeController openWithLatestScreenshot];
                if (completionHandler)
                {
                    completionHandler(YES);
                }
                return;
            }
        }
    }

    if (completionHandler)
    {
        completionHandler(NO);
    }
}

@end
