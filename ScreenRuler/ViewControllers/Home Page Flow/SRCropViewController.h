//
//  SRCropViewController.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>
#import "SRHomeViewController.h"

@interface SRCropViewController : UIViewController

@property(nonatomic, weak) id <ImageControllerDelegate> delegate;
@property(nonatomic, strong) UIImage* image;
@property(nonatomic, assign) CGFloat zoomScale;
@property(nonatomic, assign) CGPoint contentOffset;

@end
