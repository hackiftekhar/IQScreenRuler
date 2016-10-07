//
//  SRAcknowledgementDetailsViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRAcknowledgementDetailsViewController.h"

@interface SRAcknowledgementDetailsViewController ()

@end

@implementation SRAcknowledgementDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelDescription.text=self.ackDescription;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}


@end
