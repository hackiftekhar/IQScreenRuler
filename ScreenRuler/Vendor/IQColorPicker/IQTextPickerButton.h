//
//  IQTextPickerButton.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@interface IQTextPickerButton : UIButton

@property (nullable, readwrite, strong) UIView *inputView;
@property (nullable, readwrite, strong) UIView *inputAccessoryView;

@property(nullable,nonatomic, strong) NSString* selectedItem;

@property(nullable,nonatomic, strong) NSArray<NSString*> *items;

@end
