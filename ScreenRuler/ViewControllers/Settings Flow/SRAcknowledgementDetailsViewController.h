//
//  SRAcknowledgementDetailsViewController.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@interface SRAcknowledgementDetailsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) NSString *ackDescription;

@end
