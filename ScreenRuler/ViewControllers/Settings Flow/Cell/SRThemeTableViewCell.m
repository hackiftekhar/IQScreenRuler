//
//  SRThemeTableViewCell.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRThemeTableViewCell.h"

@implementation SRThemeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.labelTitle.text = NSLocalizedString(@"color_theme", nil);
    [self.segmentControl setTitle:NSLocalizedString(@"natural", nil) forSegmentAtIndex:0];
    [self.segmentControl setTitle:NSLocalizedString(@"inverted", nil) forSegmentAtIndex:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
