//
//  UIImage+Color.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

-(UIImage*)imageWithColor:(UIColor*)color;

-(UIColor*)colorAtPoint:(CGPoint)point;

@end
