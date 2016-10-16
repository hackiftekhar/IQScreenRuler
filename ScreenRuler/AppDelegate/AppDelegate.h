//
//  AppDelegate.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

extern NSNotificationName iVersionDidUpdateNotification;

extern const NSInteger kSRAppStoreID;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property BOOL shouldShowTouches;

@property BOOL isCheckingNewVersion;
@property NSString* updatedVersionString;

@end

