//
//  IQProtractorView.h
//  Screen Ruler
//
//  Created by IEMacBook02 on 24/12/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IQProtractorView : UIView

@property(strong, readonly) UIPanGestureRecognizer *panRecognizer;

@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIColor *protractorColor;

@end
