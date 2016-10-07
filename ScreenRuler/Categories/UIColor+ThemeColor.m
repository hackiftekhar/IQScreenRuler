//
//  UIColor+ThemeColor.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "UIColor+ThemeColor.h"
#import "UIColor+HexColors.h"

NSString *const kRAThemeChangedNotification = @"kRAThemeChangedNotification";

@implementation UIColor (ThemeColor)

+(UIColor*)appOrangeColor
{
    return [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+(UIColor*)appGreenColor
{
    return [UIColor colorWithRed:52.0/255.0 green:191.0/255.0 blue:73.0/255.0 alpha:1.0];
}

+(UIColor*)appRedColor
{
    return [UIColor colorWithRed:240.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+(UIColor*)appBlueColor
{
    return [UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+(UIColor*)appPurpleColor
{
    return [UIColor colorWithRed:140.0/255.0 green:0.0/255.0 blue:240.0/255.0 alpha:1.0];
}

+(UIColor*)appPinkColor
{
    return [UIColor colorWithRed:255.0/255.0 green:20.0/255.0 blue:147.0/255.0 alpha:1.0];
}

+(UIColor*)originalThemeColor
{
    NSString *hexColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"ThemeColor"];
    
    if (hexColor)
    {
        return [UIColor colorWithHexString:hexColor];
    }
    else
    {
        return [UIColor appOrangeColor];
    }
}

+(UIColor*)themeColor
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ThemeInverted"])
    {
        return [UIColor whiteColor];
    }
    else
    {
        NSString *hexColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"ThemeColor"];
        if (hexColor)
        {
            return [UIColor colorWithHexString:hexColor];
        }
        else
        {
            return [UIColor appOrangeColor];
        }
    }
}

+(void)setThemeColor:(UIColor*)color
{
    NSString *colorHex = [color hexValue];
    
    [[NSUserDefaults standardUserDefaults] setObject:colorHex forKey:@"ThemeColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRAThemeChangedNotification object:color];
}

+(void)setThemeInverted:(BOOL)inverted
{
    [[NSUserDefaults standardUserDefaults] setBool:inverted forKey:@"ThemeInverted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRAThemeChangedNotification object:[self themeColor]];
}

+(BOOL)isThemeInverted
{
    return[[NSUserDefaults standardUserDefaults] boolForKey:@"ThemeInverted"];
}

+(UIColor*)themeTextColor
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ThemeInverted"])
    {
        NSString *hexColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"ThemeColor"];
        if (hexColor)
        {
            return [UIColor colorWithHexString:hexColor];
        }
        else
        {
            return [UIColor appOrangeColor];
        }
    }
    else
    {
        return [UIColor whiteColor];
    }
}

+(UIColor*)themeBackgroundColor
{
    return [[self themeColor] colorWithShadeFactor:0.97];
}

-(UIColor*)colorWithShadeFactor:(CGFloat)shadeFactor
{
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];;
    
    return [UIColor colorWithRed:MIN(1, red + 1*shadeFactor)
                           green:MIN(1, green + 1*shadeFactor)
                            blue:MIN(1, blue + 1*shadeFactor)
                           alpha:1.0];
}

@end
