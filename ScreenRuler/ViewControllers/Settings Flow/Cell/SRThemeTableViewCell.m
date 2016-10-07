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

    self.labelTitle.text = NSLocalizedString(@"Color Theme", nil);
    [self.segmentControl setTitle:NSLocalizedString(@"Natural", nil) forSegmentAtIndex:0];
    [self.segmentControl setTitle:NSLocalizedString(@"Inverted", nil) forSegmentAtIndex:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
