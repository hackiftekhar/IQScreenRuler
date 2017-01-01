//
//  UIColor+ThemeColor.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

extern NSString *const kRASettingsChangedNotification;

@interface UIColor (ThemeColor)

+(UIColor*)originalThemeColor;

+(UIColor*)themeColor;
+(UIColor*)themeTextColor;
+(UIColor*)themeBackgroundColor;

+(void)setThemeColor:(UIColor*)color;
+(void)setThemeInverted:(BOOL)inverted;
+(BOOL)isThemeInverted;

-(UIColor*)colorWithShadeFactor:(CGFloat)shadeFactor;

@end
