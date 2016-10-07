//
//  SmoothedBIView.h
//  FreehandDrawingTut
//
//  Created by A Khan on 12/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IQ_SmoothedBIView : UIView

@property(nonatomic, strong, readonly) UIPanGestureRecognizer *panRecognizer;

@property(nonatomic, strong) UIColor *strokeColor;

@property(nonatomic, assign) CGFloat strokeWidth;

-(void)clear;

@end
