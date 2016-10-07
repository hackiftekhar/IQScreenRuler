//
//  SRImagePickerController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRImagePickerController.h"

@implementation SRImagePickerController


- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

//-(UIInterfaceOrientation)interfaceOrientation
//{
//    if ([self.presentedViewController isKindOfClass:[UIAlertController class]] == NO)
//    {
//        return self.presentedViewController.interfaceOrientation;
//    }
//    else
//    {
//        return [super interfaceOrientation];
//    }
//}

@end
