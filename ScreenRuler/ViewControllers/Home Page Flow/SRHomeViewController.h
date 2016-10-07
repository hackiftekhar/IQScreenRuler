//
//  SRHomeViewController.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@protocol ImageControllerDelegate <NSObject>

-(void)controller:(UIViewController*)controller finishWithImage:(UIImage*)image zoomScale:(CGFloat)zoomScale contentOffset:(CGPoint)contentOffset;

@end

@interface SRHomeViewController : UIViewController

-(void)openWithLatestScreenshot;

@end

