//
//  UIImage+FloodFill.h
//  ImageFloodFilleDemo
//
//  Created by chintan on 15/07/13.
//  Copyright (c) 2013 ZWT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkedListStack.h"

@interface UIImage (FloodFill)

- (UIImage *) floodFillFromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor andTolerance:(int)tolerance;
- (UIImage *) floodFillFromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor andTolerance:(int)tolerance useAntiAlias:(BOOL)antiAlias;

@end