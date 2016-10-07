//
//  UIFont+AppFont.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "UIFont+AppFont.h"

@implementation UIFont (AppFont)

+(UIFont*)kohinoorBanglaRegularWithSize:(CGFloat)size
{
    UIFont *font = [UIFont fontWithName:@"KohinoorBangla-Regular" size:size];
    
    if (font == nil)
    {
        font = [UIFont systemFontOfSize:size];
    }
    
    return font;
}

+(UIFont*)kohinoorBanglaSemiboldWithSize:(CGFloat)size
{
    UIFont *font = [UIFont fontWithName:@"KohinoorBangla-Semibold" size:size];
    
    if (font == nil)
    {
        font = [UIFont boldSystemFontOfSize:size];
    }
    
    return font;
}

@end
