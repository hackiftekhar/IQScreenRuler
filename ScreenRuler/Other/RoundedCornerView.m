//
//  RoundedCornerView.m
//  Screen Ruler
//
//  Created by IEMacBook01 on 15/10/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import "RoundedCornerView.h"

@implementation RoundedCornerView

-(void)layoutSubviews
{
    [super layoutSubviews];

    if (_cornerRadiusRatio > 0)
    {
        CGFloat widthHeight = MIN(self.frame.size.width, self.frame.size.height);
        
        self.layer.cornerRadius = widthHeight*_cornerRadiusRatio;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
