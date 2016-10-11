//
//  SRScreenshotCollectionViewController.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@class SRScreenshotCollectionViewController;

@protocol SRScreenshotCollectionViewControllerDelegate <NSObject>

-(void)screenshotControllerDidSelectOpenCamera:(SRScreenshotCollectionViewController*)controller;

-(void)screenshotControllerDidSelectOpenPhotoLibrary:(SRScreenshotCollectionViewController*)controller;

-(void)screenshotController:(SRScreenshotCollectionViewController*)controller didSelectScreenshot:(UIImage*)image;

@end

@interface SRScreenshotCollectionViewController : UIViewController

@property(nonatomic, weak) id <SRScreenshotCollectionViewControllerDelegate> delegate;

-(void)presentOverViewController:(UIViewController*)controller completion:(void (^)(void))completion;
-(void)dismissViewControllerCompletion:(void (^)(void))completion;

@end
