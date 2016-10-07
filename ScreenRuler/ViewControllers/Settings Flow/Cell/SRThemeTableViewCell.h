//
//  SRThemeTableViewCell.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>
#import "HFColorButton.h"

@interface SRThemeTableViewCell : UITableViewCell

@property(nonatomic,strong) IBOutlet UILabel *labelTitle;
@property(nonatomic,strong) IBOutlet UISegmentedControl *segmentControl;

@property(nonatomic,strong) IBOutletCollection(HFColorButton) NSArray *themeColorButtons;

@end
